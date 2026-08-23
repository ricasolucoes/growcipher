import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/gamification/achievements.dart';
import 'package:growcipher/domain/gamification/completeness.dart';
import 'package:growcipher/domain/gamification/gamification_engine.dart';
import 'package:growcipher/domain/gamification/gamification_state.dart';
import 'package:growcipher/domain/gamification/level.dart';
import 'package:growcipher/domain/gamification/xp_rules.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';

const engine = GamificationEngine();

Plant plantFixture({
  String id = 'p1',
  String? displayName,
  PlantPhase phase = PlantPhase.unknown,
}) {
  final now = DateTime(2026, 5, 10);
  return Plant(
    id: id,
    displayName: displayName,
    privacyCode: 'GC-0001',
    startingPoint: PlantStartingPoint.seed,
    phase: phase,
    createdAt: now,
    updatedAt: now,
  );
}

PlantProgressSnapshot snapshotFixture({
  Plant? plant,
  int eventsOnPlant = 1,
  int distinctPhasesOnPlant = 1,
  Set<int> claimedMilestones = const {},
}) {
  return PlantProgressSnapshot(
    completeness: completenessOf(plant ?? plantFixture()),
    eventsOnPlant: eventsOnPlant,
    distinctPhasesOnPlant: distinctPhasesOnPlant,
    claimedMilestones: claimedMilestones,
  );
}

WateredEvent watering({
  String id = 'e1',
  DateTime? at,
  double? amount,
  String? unit,
  String? solutionType,
  String? notes,
}) {
  final when = at ?? DateTime(2026, 5, 10, 9);
  return WateredEvent(
    id: id,
    plantId: 'p1',
    occurredAt: when,
    createdAt: when,
    amount: amount,
    unit: unit,
    solutionType: solutionType,
    notes: notes,
  );
}

void main() {
  group('XP por detalhe', () {
    test('registro vazio paga só a base do tipo', () {
      final outcome = engine.registerEvent(
        event: watering(),
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      final base = outcome.awards
          .where((award) => award.source == XpSource.eventLogged)
          .single;
      expect(base.amount, baseXpByEventType[PlantEventType.watered]);
      expect(
        outcome.awards.any((award) => award.source == XpSource.fieldDetail),
        isFalse,
      );
    });

    test('cada campo opcional preenchido soma XP', () {
      final outcome = engine.registerEvent(
        event: watering(amount: 1.5, unit: 'L', solutionType: 'água'),
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      final detail = outcome.awards
          .where((award) => award.source == XpSource.fieldDetail)
          .single;
      expect(detail.amount, 3 * xpPerFilledField);
    });

    test('nota escrita paga à parte', () {
      final outcome = engine.registerEvent(
        event: watering(notes: 'folhas caídas pela manhã'),
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      expect(
        outcome.awards
            .where((award) => award.source == XpSource.noteWritten)
            .single
            .amount,
        xpPerNote,
      );
    });

    test('nota só de espaços não conta', () {
      final outcome = engine.registerEvent(
        event: watering(notes: '   '),
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      expect(
        outcome.awards.any((award) => award.source == XpSource.noteWritten),
        isFalse,
      );
    });

    test('campo obrigatório do tipo não conta como detalhe', () {
      final event = PhaseChangedEvent(
        id: 'e9',
        plantId: 'p1',
        occurredAt: DateTime(2026, 5, 10),
        createdAt: DateTime(2026, 5, 10),
        previousPhase: PlantPhase.seedling,
        newPhase: PlantPhase.vegetative,
      );

      final outcome = engine.registerEvent(
        event: event,
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      expect(
        outcome.awards.any((award) => award.source == XpSource.fieldDetail),
        isFalse,
      );
    });

    test('medição completa vale três vezes a vazia', () {
      DateTime when = DateTime(2026, 5, 10, 8);
      final empty = MeasurementAddedEvent(
        id: 'm1',
        plantId: 'p1',
        occurredAt: when,
        createdAt: when,
      );
      final full = MeasurementAddedEvent(
        id: 'm2',
        plantId: 'p1',
        occurredAt: when,
        createdAt: when,
        temperatureC: 24,
        humidityPercent: 55,
        ph: 6.2,
        ec: 1.4,
        vpd: 1.1,
        dli: 32,
      );

      int xpOf(PlantEvent event) =>
          awardsForEvent(event).fold(0, (sum, award) => sum + award.amount);

      expect(xpOf(empty), 12);
      expect(xpOf(full), 36);
    });
  });

  group('sequência de dias', () {
    test('dias consecutivos aumentam a sequência', () {
      var state = GamificationState.empty;
      for (var day = 10; day <= 12; day++) {
        state = engine
            .registerEvent(
              event: watering(id: 'e$day', at: DateTime(2026, 5, day, 9)),
              plant: plantFixture(),
              state: state,
              snapshot: snapshotFixture(),
            )
            .state;
      }

      expect(state.currentStreak, 3);
      expect(state.longestStreak, 3);
    });

    test('segundo registro no mesmo dia não paga sequência de novo', () {
      final first = engine.registerEvent(
        event: watering(id: 'a', at: DateTime(2026, 5, 10, 9)),
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );
      final second = engine.registerEvent(
        event: watering(id: 'b', at: DateTime(2026, 5, 10, 21)),
        plant: plantFixture(),
        state: first.state,
        snapshot: snapshotFixture(),
      );

      expect(
        second.awards.any((award) => award.source == XpSource.streakDay),
        isFalse,
      );
      expect(second.state.currentStreak, 1);
    });

    test('lacuna reinicia a sequência mas preserva a melhor marca', () {
      var state = GamificationState.empty;
      for (var day = 1; day <= 4; day++) {
        state = engine
            .registerEvent(
              event: watering(id: 'e$day', at: DateTime(2026, 5, day, 9)),
              plant: plantFixture(),
              state: state,
              snapshot: snapshotFixture(),
            )
            .state;
      }

      final afterGap = engine.registerEvent(
        event: watering(id: 'later', at: DateTime(2026, 5, 20, 9)),
        plant: plantFixture(),
        state: state,
        snapshot: snapshotFixture(),
      );

      expect(afterGap.state.currentStreak, 1);
      expect(afterGap.state.longestStreak, 4);
      expect(
        afterGap.state.counter(AchievementMetric.streakRecovered),
        1,
        reason: 'recomeçar depois de uma sequência ≥ 3 é conquista',
      );
    });

    test('XP de sequência tem teto', () {
      var state = GamificationState.empty;
      var lastStreakAward = 0;
      for (var day = 1; day <= 40; day++) {
        final outcome = engine.registerEvent(
          event: watering(id: 'e$day', at: DateTime(2026, 3, day, 9)),
          plant: plantFixture(),
          state: state,
          snapshot: snapshotFixture(),
        );
        state = outcome.state;
        lastStreakAward = outcome.awards
            .where((award) => award.source == XpSource.streakDay)
            .single
            .amount;
      }

      expect(state.currentStreak, 40);
      expect(lastStreakAward, xpStreakCap);
    });
  });

  group('conquistas', () {
    test('primeiro cadastro destrava as conquistas de entrada', () {
      final event = PlantCreatedEvent(
        id: 'c1',
        plantId: 'p1',
        occurredAt: DateTime(2026, 5, 10),
        createdAt: DateTime(2026, 5, 10),
      );

      final outcome = engine.registerEvent(
        event: event,
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      final ids = outcome.unlockedAchievements
          .map((achievement) => achievement.id)
          .toSet();
      expect(ids, containsAll(<String>{'first_plant', 'first_log'}));
    });

    test('conquista já destravada não volta a pagar', () {
      final event = PlantCreatedEvent(
        id: 'c1',
        plantId: 'p1',
        occurredAt: DateTime(2026, 5, 10),
        createdAt: DateTime(2026, 5, 10),
      );
      final first = engine.registerEvent(
        event: event,
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      final second = engine.registerEvent(
        event: watering(id: 'w1', at: DateTime(2026, 5, 11, 9)),
        plant: plantFixture(),
        state: first.state,
        snapshot: snapshotFixture(eventsOnPlant: 2),
      );

      expect(
        second.unlockedAchievements.any(
          (achievement) => achievement.id == 'first_plant',
        ),
        isFalse,
      );
    });

    test('sequência quebrada não remove conquista de sequência', () {
      var state = GamificationState.empty;
      for (var day = 1; day <= 3; day++) {
        state = engine
            .registerEvent(
              event: watering(id: 'e$day', at: DateTime(2026, 5, day, 9)),
              plant: plantFixture(),
              state: state,
              snapshot: snapshotFixture(),
            )
            .state;
      }
      expect(state.unlockedAchievementIds, contains('streak_3'));

      final afterGap = engine.registerEvent(
        event: watering(id: 'gap', at: DateTime(2026, 6, 1, 9)),
        plant: plantFixture(),
        state: state,
        snapshot: snapshotFixture(),
      );

      expect(afterGap.state.currentStreak, 1);
      expect(afterGap.state.unlockedAchievementIds, contains('streak_3'));
    });

    test('problema com foto destrava curadoria', () {
      final event = ProblemReportedEvent(
        id: 'pr1',
        plantId: 'p1',
        occurredAt: DateTime(2026, 5, 10),
        createdAt: DateTime(2026, 5, 10),
        category: ProblemCategory.pest,
        photoRef: 'photo-1',
      );

      final outcome = engine.registerEvent(
        event: event,
        plant: plantFixture(),
        state: GamificationState.empty,
        snapshot: snapshotFixture(),
      );

      expect(
        outcome.unlockedAchievements.map((a) => a.id),
        contains('problem_documented'),
      );
    });
  });

  group('marcos de completude', () {
    test('perfil completo paga os três marcos uma única vez', () {
      final complete = Plant(
        id: 'p2',
        displayName: 'Alfa',
        privacyCode: 'GC-0002',
        photoRef: 'photo',
        startingPoint: PlantStartingPoint.seed,
        origin: PlantOrigin.purchased,
        originDetails: 'loja',
        strain: 'Northern Lights',
        geneticType: PlantGeneticType.photoperiod,
        startDate: DateTime(2026, 3, 1),
        seedObtainedDate: DateTime(2026, 2, 20),
        environment: GrowingEnvironment.indoor,
        environmentPlace: EnvironmentPlace.growTent,
        environmentName: 'Tenda 1',
        growingMedium: GrowingMedium.coco,
        containerType: 'vaso têxtil',
        containerVolumeLiters: 11,
        irrigationMode: IrrigationMode.manual,
        irrigationSystem: IrrigationSystem.drip,
        phase: PlantPhase.vegetative,
        createdAt: DateTime(2026, 5, 10),
        updatedAt: DateTime(2026, 5, 10),
      );

      expect(completenessOf(complete).isComplete, isTrue);

      final first = engine.registerEvent(
        event: watering(id: 'w1', at: DateTime(2026, 5, 10, 9)),
        plant: complete,
        state: GamificationState.empty,
        snapshot: snapshotFixture(plant: complete),
      );

      final milestones = first.awards
          .where((award) => award.source == XpSource.profileCompleted)
          .map((award) => award.key)
          .toList();
      expect(milestones, [
        'plant:p2:completeness:50',
        'plant:p2:completeness:80',
        'plant:p2:completeness:100',
      ]);
      expect(
        first.unlockedAchievements.map((a) => a.id),
        contains('profile_complete_1'),
      );

      final second = engine.registerEvent(
        event: watering(id: 'w2', at: DateTime(2026, 5, 11, 9)),
        plant: complete,
        state: first.state,
        snapshot: snapshotFixture(
          plant: complete,
          claimedMilestones: const {50, 80, 100},
        ),
      );

      expect(
        second.awards.any((award) => award.source == XpSource.profileCompleted),
        isFalse,
      );
    });

    test('perfil vazio lista o que falta', () {
      final completeness = completenessOf(plantFixture());

      expect(completeness.percent, 0);
      expect(completeness.missing, contains(CompletenessField.strain));
      expect(completeness.missing, contains(CompletenessField.photo));
      expect(
        completeness.missing,
        isNot(contains(CompletenessField.rootedDate)),
        reason: 'data de enraizamento não se aplica a quem plantou semente',
      );
    });
  });

  group('curva de nível', () {
    test('limiares batem com a tabela publicada', () {
      expect(xpForLevel(1), 0);
      expect(xpForLevel(2), 50);
      expect(xpForLevel(3), 150);
      expect(xpForLevel(5), 500);
      expect(xpForLevel(10), 2250);
    });

    test('nível é a inversa exata da curva', () {
      for (var level = 1; level <= 60; level++) {
        final floor = xpForLevel(level);
        expect(levelForXp(floor), level);
        if (level > 1) expect(levelForXp(floor - 1), level - 1);
      }
    });

    test('progresso dentro do nível', () {
      final progress = LevelProgress.fromXp(100);

      expect(progress.level, 2);
      expect(progress.xpIntoLevel, 50);
      expect(progress.xpForNextLevel, 100);
      expect(progress.fraction, 0.5);
      expect(progress.xpRemaining, 50);
    });

    test('XP negativo não quebra a curva', () {
      expect(LevelProgress.fromXp(-10).level, 1);
    });
  });
}
