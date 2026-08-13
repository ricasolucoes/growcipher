import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/gamification/achievements.dart';
import '../domain/gamification/completeness.dart';
import '../domain/gamification/gamification_engine.dart';
import '../domain/gamification/gamification_state.dart';
import '../domain/models/plant.dart';
import '../domain/models/plant_enums.dart';
import '../domain/models/plant_event.dart';
import '../domain/repositories/gamification_repository.dart';

/// Implementação SQLite da progressão local.
///
/// A idempotência é do banco, não do motor: cada concessão entra por chave
/// primária com `INSERT OR IGNORE`, e só o que realmente entrou soma ao XP.
/// Assim, reprocessar um evento (ou tocar duas vezes no mesmo marco de
/// completude) não paga de novo.
class SqliteGamificationRepository implements GamificationRepository {
  SqliteGamificationRepository(
    this._db, [
    this._engine = const GamificationEngine(),
  ]);

  final Database _db;
  final GamificationEngine _engine;

  @override
  Future<GamificationState> getState() async {
    final stateRows = await _db.query('gamification_state', limit: 1);
    final counterRows = await _db.query('gamification_counters');
    final unlockRows = await _db.query('achievement_unlocks');

    if (stateRows.isEmpty) return GamificationState.empty;
    final row = stateRows.first;

    final counters = <AchievementMetric, int>{};
    for (final counterRow in counterRows) {
      final metric = _metricFromName(counterRow['metric'] as String?);
      if (metric != null) counters[metric] = counterRow['value'] as int;
    }

    final lastDay = row['last_activity_day'] as int?;

    return GamificationState(
      totalXp: row['total_xp'] as int? ?? 0,
      currentStreak: row['current_streak'] as int? ?? 0,
      longestStreak: row['longest_streak'] as int? ?? 0,
      lastActivityDay: lastDay == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastDay),
      counters: counters,
      unlockedAchievementIds: unlockRows
          .map((unlockRow) => unlockRow['id'] as String)
          .toSet(),
    );
  }

  @override
  Future<List<UnlockedAchievement>> getUnlockedAchievements() async {
    final rows = await _db.query(
      'achievement_unlocks',
      orderBy: 'unlocked_at DESC',
    );
    return rows
        .map(
          (row) => UnlockedAchievement(
            id: row['id'] as String,
            unlockedAt: DateTime.fromMillisecondsSinceEpoch(
              row['unlocked_at'] as int,
            ),
          ),
        )
        .toList();
  }

  @override
  Future<GamificationOutcome?> registerEvent({
    required PlantEvent event,
    required Plant plant,
  }) async {
    if (await _alreadyProcessed(event.id)) return null;

    final state = await getState();
    final snapshot = PlantProgressSnapshot(
      completeness: completenessOf(plant),
      eventsOnPlant: await _eventCountOf(plant.id),
      distinctPhasesOnPlant: await _distinctPhasesOf(plant),
      claimedMilestones: await _claimedMilestonesOf(plant.id),
    );

    final outcome = _engine.registerEvent(
      event: event,
      plant: plant,
      state: state,
      snapshot: snapshot,
    );

    final awardedAt = event.createdAt.millisecondsSinceEpoch;
    var xpActuallyGained = 0;

    await _db.transaction((txn) async {
      for (final award in outcome.awards) {
        final rowId = await txn.insert('xp_ledger', {
          'key': award.key,
          'source': award.source.name,
          'amount': award.amount,
          'plant_id': award.plantId,
          'awarded_at': awardedAt,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);

        // rowId 0 = chave já existia; a concessão não conta de novo.
        if (rowId != 0) xpActuallyGained += award.amount;
      }

      for (final achievement in outcome.unlockedAchievements) {
        await txn.insert('achievement_unlocks', {
          'id': achievement.id,
          'unlocked_at': awardedAt,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      for (final entry in outcome.state.counters.entries) {
        await txn.insert('gamification_counters', {
          'metric': entry.key.name,
          'value': entry.value,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await txn.update(
        'gamification_state',
        {
          'total_xp': state.totalXp + xpActuallyGained,
          'current_streak': outcome.state.currentStreak,
          'longest_streak': outcome.state.longestStreak,
          'last_activity_day':
              outcome.state.lastActivityDay?.millisecondsSinceEpoch,
          'updated_at': awardedAt,
        },
        where: 'id = 1',
      );
    });

    return GamificationOutcome(
      awards: outcome.awards,
      unlockedAchievements: outcome.unlockedAchievements,
      state: outcome.state.copyWith(totalXp: state.totalXp + xpActuallyGained),
    );
  }

  Future<bool> _alreadyProcessed(String eventId) async {
    final rows = await _db.query(
      'xp_ledger',
      columns: ['key'],
      where: 'key = ?',
      whereArgs: ['event:$eventId:base'],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  Future<int> _eventCountOf(String plantId) async {
    final rows = await _db.rawQuery(
      'SELECT COUNT(*) AS total FROM plant_events WHERE plant_id = ?',
      [plantId],
    );
    return (rows.first['total'] as int?) ?? 0;
  }

  /// Fases distintas que a planta já viveu: as registradas em `phaseChanged`
  /// mais o snapshot atual. `unknown` não conta como fase vivida.
  Future<int> _distinctPhasesOf(Plant plant) async {
    final rows = await _db.query(
      'plant_events',
      columns: ['payload'],
      where: 'plant_id = ? AND type = ?',
      whereArgs: [plant.id, PlantEventType.phaseChanged.name],
    );

    final phases = <String>{};
    if (plant.phase != PlantPhase.unknown) phases.add(plant.phase.name);

    for (final row in rows) {
      final payload = jsonDecode(row['payload'] as String? ?? '{}');
      if (payload is! Map) continue;
      for (final key in const ['previousPhase', 'newPhase']) {
        final value = payload[key];
        if (value is String && value != PlantPhase.unknown.name) {
          phases.add(value);
        }
      }
    }

    return phases.length;
  }

  Future<Set<int>> _claimedMilestonesOf(String plantId) async {
    final rows = await _db.query(
      'xp_ledger',
      columns: ['key'],
      where: 'key LIKE ?',
      whereArgs: ['plant:$plantId:completeness:%'],
    );

    return rows
        .map((row) => int.tryParse((row['key'] as String).split(':').last))
        .whereType<int>()
        .toSet();
  }

  AchievementMetric? _metricFromName(String? name) {
    if (name == null) return null;
    for (final metric in AchievementMetric.values) {
      if (metric.name == name) return metric;
    }
    // Contador gravado por versão futura do app: ignorado, nunca fatal.
    return null;
  }
}
