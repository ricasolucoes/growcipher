import '../models/plant.dart';
import '../models/plant_event.dart';
import 'achievements.dart';
import 'completeness.dart';
import 'gamification_state.dart';
import 'xp_rules.dart';

/// O que o chamador precisa saber sobre a planta tocada pelo evento.
///
/// Vem de fora para manter o motor puro: quem persiste sabe contar eventos
/// por planta e ler o ledger; o motor só aplica regra.
class PlantProgressSnapshot {
  const PlantProgressSnapshot({
    required this.completeness,
    required this.eventsOnPlant,
    required this.distinctPhasesOnPlant,
    this.claimedMilestones = const {},
  });

  final PlantCompleteness completeness;

  /// Total de eventos desta planta, incluindo o que está sendo registrado.
  final int eventsOnPlant;

  /// Quantas fases distintas já apareceram na linha do tempo desta planta.
  final int distinctPhasesOnPlant;

  /// Marcos de completude que esta planta já pagou.
  final Set<int> claimedMilestones;
}

class GamificationOutcome {
  const GamificationOutcome({
    required this.awards,
    required this.unlockedAchievements,
    required this.state,
  });

  final List<XpAward> awards;
  final List<Achievement> unlockedAchievements;

  /// Estado resultante, assumindo que toda concessão em [awards] é nova. A
  /// persistência é a autoridade final sobre o XP: concessões repetidas são
  /// ignoradas por chave e não contam de novo.
  final GamificationState state;

  int get xpGained => awards.fold(0, (sum, award) => sum + award.amount);
}

/// Motor da progressão: função pura de (evento, planta, estado) para
/// (concessões, conquistas, novo estado).
class GamificationEngine {
  const GamificationEngine();

  GamificationOutcome registerEvent({
    required PlantEvent event,
    required Plant plant,
    required GamificationState state,
    required PlantProgressSnapshot snapshot,
  }) {
    final awards = <XpAward>[...awardsForEvent(event)];
    final counters = Map<AchievementMetric, int>.from(state.counters);

    void bump(AchievementMetric metric, [int by = 1]) {
      counters[metric] = (counters[metric] ?? 0) + by;
    }

    void raiseTo(AchievementMetric metric, int value) {
      if (value > (counters[metric] ?? 0)) counters[metric] = value;
    }

    bump(AchievementMetric.eventsLogged);
    if (isFullyDetailed(event)) bump(AchievementMetric.detailedEvents);
    raiseTo(AchievementMetric.maxEventsOnOnePlant, snapshot.eventsOnPlant);
    raiseTo(
      AchievementMetric.maxPhasesOnOnePlant,
      snapshot.distinctPhasesOnPlant,
    );

    switch (event) {
      case PlantCreatedEvent():
        bump(AchievementMetric.plantsCreated);
      case PhotoAddedEvent():
        bump(AchievementMetric.photosAdded);
      case MeasurementAddedEvent():
        bump(AchievementMetric.measurementsAdded);
      case TreatmentAppliedEvent():
        bump(AchievementMetric.treatmentsApplied);
      case PhaseChangedEvent():
        bump(AchievementMetric.phaseChanges);
      case ProblemReportedEvent(:final photoRef):
        bump(AchievementMetric.problemsReported);
        if (photoRef != null) bump(AchievementMetric.problemsWithPhoto);
      case HarvestedEvent(:final dryWeight):
        bump(AchievementMetric.harvests);
        if (dryWeight != null) bump(AchievementMetric.harvestsWithDryWeight);
      case PlantEndedEvent():
        bump(AchievementMetric.cyclesEnded);
      case _:
        break;
    }

    // Marcos de completude do perfil, uma vez por planta.
    for (final milestone in snapshot.completeness.reachedMilestones) {
      if (snapshot.claimedMilestones.contains(milestone)) continue;
      awards.add(
        XpAward(
          key: 'plant:${plant.id}:completeness:$milestone',
          source: XpSource.profileCompleted,
          amount: xpByCompletenessMilestone[milestone] ?? 0,
          plantId: plant.id,
        ),
      );
      if (milestone == 100) bump(AchievementMetric.completedProfiles);
    }

    final streak = _advanceStreak(state, event.createdAt);
    if (streak.isNewDay) {
      awards.add(
        XpAward(
          key: 'day:${_dayKey(streak.day)}',
          source: XpSource.streakDay,
          amount: _streakXp(streak.currentStreak),
        ),
      );
    }
    if (streak.recovered) bump(AchievementMetric.streakRecovered);

    counters[AchievementMetric.currentStreak] = streak.currentStreak;
    counters[AchievementMetric.longestStreak] = streak.longestStreak;

    final unlocked = evaluateAchievements(
      counterOf: (metric) => counters[metric] ?? 0,
      unlockedIds: state.unlockedAchievementIds,
    );
    for (final achievement in unlocked) {
      awards.add(
        XpAward(
          key: 'achievement:${achievement.id}',
          source: XpSource.achievement,
          amount: achievement.xpReward,
        ),
      );
    }

    final gained = awards.fold(0, (sum, award) => sum + award.amount);

    return GamificationOutcome(
      awards: awards,
      unlockedAchievements: unlocked,
      state: state.copyWith(
        totalXp: state.totalXp + gained,
        currentStreak: streak.currentStreak,
        longestStreak: streak.longestStreak,
        lastActivityDay: streak.day,
        counters: counters,
        unlockedAchievementIds: {
          ...state.unlockedAchievementIds,
          ...unlocked.map((achievement) => achievement.id),
        },
      ),
    );
  }

  _StreakTransition _advanceStreak(GamificationState state, DateTime at) {
    final day = DateTime(at.year, at.month, at.day);
    final last = state.lastActivityDay;

    if (last == null) {
      return _StreakTransition(
        day: day,
        currentStreak: 1,
        longestStreak: state.longestStreak < 1 ? 1 : state.longestStreak,
        isNewDay: true,
        recovered: false,
      );
    }

    final lastDay = DateTime(last.year, last.month, last.day);
    // Aritmética em UTC para não escorregar em mudança de horário.
    final gap = DateTime.utc(day.year, day.month, day.day)
        .difference(DateTime.utc(lastDay.year, lastDay.month, lastDay.day))
        .inDays;

    if (gap <= 0) {
      // Mesmo dia (ou registro com data anterior): sequência não muda.
      return _StreakTransition(
        day: lastDay,
        currentStreak: state.currentStreak,
        longestStreak: state.longestStreak,
        isNewDay: false,
        recovered: false,
      );
    }

    final continued = gap == 1;
    final current = continued ? state.currentStreak + 1 : 1;

    return _StreakTransition(
      day: day,
      currentStreak: current,
      longestStreak: current > state.longestStreak
          ? current
          : state.longestStreak,
      isNewDay: true,
      // Recomeçar depois de ter mantido uma sequência que valeu a pena.
      recovered: !continued && state.longestStreak >= 3,
    );
  }

  int _streakXp(int currentStreak) {
    final xp = xpStreakBase + xpStreakPerDay * (currentStreak - 1);
    return xp > xpStreakCap ? xpStreakCap : xp;
  }

  String _dayKey(DateTime day) =>
      '${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';
}

class _StreakTransition {
  const _StreakTransition({
    required this.day,
    required this.currentStreak,
    required this.longestStreak,
    required this.isNewDay,
    required this.recovered,
  });

  final DateTime day;
  final int currentStreak;
  final int longestStreak;
  final bool isNewDay;
  final bool recovered;
}
