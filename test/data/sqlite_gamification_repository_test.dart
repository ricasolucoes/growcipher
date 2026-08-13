import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/data/app_database.dart';
import 'package:growcipher/data/sqlite_gamification_repository.dart';
import 'package:growcipher/data/sqlite_plant_repository.dart';
import 'package:growcipher/domain/gamification/achievements.dart';
import 'package:growcipher/domain/identifiers.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_draft.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SqlitePlantRepository plants;
  late SqliteGamificationRepository gamification;

  setUp(() async {
    db = await AppDatabase(
      factory: databaseFactoryFfi,
    ).open(path: inMemoryDatabasePath);
    plants = SqlitePlantRepository(db);
    gamification = SqliteGamificationRepository(db);
  });

  tearDown(() => db.close());

  Future<Plant> createPlant() async {
    final draft = PlantDraft()..startingPoint = PlantStartingPoint.seed;
    final plant = draft.toPlant(id: generateLocalId(), now: DateTime.now());
    return plants.createPlant(plant);
  }

  WateredEvent watering(String plantId, {DateTime? at, double? amount}) {
    final when = at ?? DateTime.now();
    return WateredEvent(
      id: generateLocalId(),
      plantId: plantId,
      occurredAt: when,
      createdAt: when,
      amount: amount,
      unit: amount == null ? null : 'L',
    );
  }

  test('estado nasce zerado', () async {
    final state = await gamification.getState();

    expect(state.totalXp, 0);
    expect(state.level.level, 1);
    expect(state.currentStreak, 0);
    expect(state.unlockedAchievementIds, isEmpty);
  });

  test('registrar evento acumula XP e persiste', () async {
    final plant = await createPlant();
    final event = watering(plant.id, amount: 1.5);

    final outcome = await gamification.registerEvent(
      event: event,
      plant: plant,
    );

    expect(outcome, isNotNull);
    final persisted = await gamification.getState();
    expect(persisted.totalXp, outcome!.state.totalXp);
    expect(persisted.totalXp, greaterThan(0));
    expect(persisted.currentStreak, 1);
  });

  test('reprocessar o mesmo evento não paga de novo', () async {
    final plant = await createPlant();
    final event = watering(plant.id, amount: 1);

    final first = await gamification.registerEvent(event: event, plant: plant);
    final second = await gamification.registerEvent(event: event, plant: plant);

    expect(second, isNull, reason: 'evento já processado');
    expect((await gamification.getState()).totalXp, first!.state.totalXp);
  });

  test('marco de completude paga uma única vez, mesmo em eventos seguidos',
      () async {
    final draft = PlantDraft()
      ..startingPoint = PlantStartingPoint.seed
      ..displayName = 'Alfa'
      ..strain = 'Northern Lights'
      ..geneticType = PlantGeneticType.photoperiod
      ..origin = PlantOrigin.purchased
      ..startDate = DateTime(2026, 3, 1)
      ..seedObtainedDate = DateTime(2026, 2, 20)
      ..environment = GrowingEnvironment.indoor
      ..environmentPlace = EnvironmentPlace.growTent
      ..growingMedium = GrowingMedium.coco
      ..phase = PlantPhase.vegetative;
    final plant = await plants.createPlant(
      draft.toPlant(id: generateLocalId(), now: DateTime.now()),
    );

    final first = await gamification.registerEvent(
      event: watering(plant.id, at: DateTime(2026, 5, 10)),
      plant: plant,
    );
    final milestoneKeys = first!.awards
        .map((award) => award.key)
        .where((key) => key.contains('completeness'))
        .toList();
    expect(milestoneKeys, isNotEmpty);

    final xpAfterFirst = (await gamification.getState()).totalXp;

    final second = await gamification.registerEvent(
      event: watering(plant.id, at: DateTime(2026, 5, 11)),
      plant: plant,
    );

    expect(
      second!.awards.any((award) => award.key.contains('completeness')),
      isFalse,
    );
    final xpAfterSecond = (await gamification.getState()).totalXp;
    expect(xpAfterSecond, greaterThan(xpAfterFirst));
  });

  test('conquistas ficam registradas e não se repetem', () async {
    final plant = await createPlant();

    await gamification.registerEvent(
      event: PlantCreatedEvent(
        id: generateLocalId(),
        plantId: plant.id,
        occurredAt: plant.createdAt,
        createdAt: plant.createdAt,
      ),
      plant: plant,
    );

    final unlocked = await gamification.getUnlockedAchievements();
    final ids = unlocked.map((achievement) => achievement.id).toSet();
    expect(ids, containsAll(<String>{'first_plant', 'first_log'}));

    await gamification.registerEvent(
      event: watering(plant.id),
      plant: plant,
    );

    final again = await gamification.getUnlockedAchievements();
    expect(
      again.where((achievement) => achievement.id == 'first_plant').length,
      1,
    );
  });

  test('contadores sobrevivem a releitura do banco', () async {
    final plant = await createPlant();

    for (var day = 1; day <= 3; day++) {
      await gamification.registerEvent(
        event: watering(plant.id, at: DateTime(2026, 4, day, 10)),
        plant: plant,
      );
    }

    final state = await gamification.getState();
    expect(state.counter(AchievementMetric.eventsLogged), 3);
    expect(state.counter(AchievementMetric.longestStreak), 3);
    expect(state.unlockedAchievementIds, contains('streak_3'));
  });

  test('fases distintas saem da linha do tempo real', () async {
    final plant = await createPlant();
    await plants.changePhase(
      plantId: plant.id,
      newPhase: PlantPhase.germination,
    );
    await plants.changePhase(plantId: plant.id, newPhase: PlantPhase.seedling);
    final updated = await plants.changePhase(
      plantId: plant.id,
      newPhase: PlantPhase.vegetative,
    );

    final outcome = await gamification.registerEvent(
      event: watering(updated.id),
      plant: updated,
    );

    expect(
      outcome!.state.counter(AchievementMetric.maxPhasesOnOnePlant),
      greaterThanOrEqualTo(3),
    );
  });
}
