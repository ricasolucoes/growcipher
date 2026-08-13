import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/data/app_database.dart';
import 'package:growcipher/data/gamified_plant_repository.dart';
import 'package:growcipher/data/sqlite_gamification_repository.dart';
import 'package:growcipher/data/sqlite_plant_repository.dart';
import 'package:growcipher/domain/gamification/achievements.dart';
import 'package:growcipher/domain/gamification/gamification_engine.dart';
import 'package:growcipher/domain/gamification/gamification_state.dart';
import 'package:growcipher/domain/identifiers.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_draft.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';
import 'package:growcipher/domain/repositories/gamification_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SqliteGamificationRepository gamification;
  late GamifiedPlantRepository plants;

  setUp(() async {
    db = await AppDatabase(
      factory: databaseFactoryFfi,
    ).open(path: inMemoryDatabasePath);
    gamification = SqliteGamificationRepository(db);
    plants = GamifiedPlantRepository(
      inner: SqlitePlantRepository(db),
      gamification: gamification,
    );
  });

  tearDown(() => db.close());

  Future<Plant> createPlant() {
    final draft = PlantDraft()..startingPoint = PlantStartingPoint.seed;
    return plants.createPlant(
      draft.toPlant(id: generateLocalId(), now: DateTime.now()),
    );
  }

  test('cadastrar planta já pontua o evento criado internamente', () async {
    await createPlant();

    final state = await gamification.getState();
    expect(state.totalXp, greaterThan(0));
    expect(state.counter(AchievementMetric.plantsCreated), 1);
    expect(state.unlockedAchievementIds, contains('first_plant'));
  });

  test('registro detalhado vale mais que registro vazio', () async {
    final plant = await createPlant();
    final before = (await gamification.getState()).totalXp;

    await plants.addEvent(
      WateredEvent(
        id: generateLocalId(),
        plantId: plant.id,
        occurredAt: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
    final afterEmpty = (await gamification.getState()).totalXp;

    await plants.addEvent(
      WateredEvent(
        id: generateLocalId(),
        plantId: plant.id,
        occurredAt: DateTime.now(),
        createdAt: DateTime.now(),
        amount: 1.5,
        unit: 'L',
        solutionType: 'água',
        notes: 'substrato ainda úmido em cima',
      ),
    );
    final afterDetailed = (await gamification.getState()).totalXp;

    expect(afterEmpty - before, greaterThan(0));
    expect(
      afterDetailed - afterEmpty,
      greaterThan(afterEmpty - before),
      reason: 'o bônus por detalhe é o incentivo central do pilar',
    );
  });

  test('mudança de fase e encerramento pontuam', () async {
    final plant = await createPlant();

    await plants.changePhase(
      plantId: plant.id,
      newPhase: PlantPhase.vegetative,
    );
    final afterPhase = await gamification.getState();
    expect(afterPhase.counter(AchievementMetric.phaseChanges), 1);
    expect(afterPhase.unlockedAchievementIds, contains('first_phase_change'));

    await plants.endPlant(
      plantId: plant.id,
      reason: PlantEndReason.harvestCompleted,
    );
    final afterEnd = await gamification.getState();
    expect(afterEnd.counter(AchievementMetric.cyclesEnded), 1);
  });

  test('cada evento pontua uma única vez', () async {
    final plant = await createPlant();
    await plants.changePhase(
      plantId: plant.id,
      newPhase: PlantPhase.vegetative,
    );

    final xp = (await gamification.getState()).totalXp;
    final events = await plants.getEvents(plant.id);
    for (final event in events) {
      await gamification.registerEvent(event: event, plant: plant);
    }

    expect((await gamification.getState()).totalXp, xp);
  });

  test('falha na progressão não derruba o registro de cultivo', () async {
    final errors = <Object>[];
    final fragile = GamifiedPlantRepository(
      inner: SqlitePlantRepository(db),
      gamification: _BrokenGamification(),
      onProgressError: (error, _) => errors.add(error),
    );

    final draft = PlantDraft()..startingPoint = PlantStartingPoint.seed;
    final plant = await fragile.createPlant(
      draft.toPlant(id: generateLocalId(), now: DateTime.now()),
    );

    expect(await fragile.getPlant(plant.id), isNotNull);
    expect(errors, isNotEmpty);
  });
}

/// Progressão que falha em tudo: o registro de cultivo tem que sobreviver.
class _BrokenGamification implements GamificationRepository {
  static Never _fail() => throw StateError('progressão indisponível');

  @override
  Future<GamificationState> getState() async => _fail();

  @override
  Future<List<UnlockedAchievement>> getUnlockedAchievements() async => _fail();

  @override
  Future<GamificationOutcome?> registerEvent({
    required PlantEvent event,
    required Plant plant,
  }) async => _fail();
}
