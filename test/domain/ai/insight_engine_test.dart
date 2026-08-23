import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/ai/insight.dart';
import 'package:growcipher/domain/ai/insight_engine.dart';
import 'package:growcipher/domain/ai/local_inference.dart';
import 'package:growcipher/domain/gamification/completeness.dart';
import 'package:growcipher/domain/gamification/gamification_state.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';

const engine = InsightEngine();
final now = DateTime(2026, 6, 1, 12);

Plant plantFixture({
  String id = 'p1',
  PlantPhase phase = PlantPhase.vegetative,
  PlantStatus status = PlantStatus.active,
  DateTime? startDate,
  String? displayName = 'Alfa',
}) {
  return Plant(
    id: id,
    displayName: displayName,
    privacyCode: 'GC-0001',
    photoRef: 'photo',
    startingPoint: PlantStartingPoint.seed,
    origin: PlantOrigin.purchased,
    originDetails: 'loja',
    strain: 'Northern Lights',
    geneticType: PlantGeneticType.photoperiod,
    startDate: startDate ?? DateTime(2026, 3, 1),
    seedObtainedDate: DateTime(2026, 2, 20),
    environment: GrowingEnvironment.indoor,
    environmentPlace: EnvironmentPlace.growTent,
    environmentName: 'Tenda 1',
    growingMedium: GrowingMedium.coco,
    containerType: 'vaso têxtil',
    containerVolumeLiters: 11,
    irrigationMode: IrrigationMode.manual,
    irrigationSystem: IrrigationSystem.drip,
    phase: phase,
    status: status,
    createdAt: DateTime(2026, 3, 1),
    updatedAt: DateTime(2026, 3, 1),
  );
}

WateredEvent wateredAt(DateTime when, {String plantId = 'p1'}) => WateredEvent(
  id: 'w${when.millisecondsSinceEpoch}',
  plantId: plantId,
  occurredAt: when,
  createdAt: when,
);

MeasurementAddedEvent measuredAt(
  DateTime when, {
  String plantId = 'p1',
  required double ph,
}) => MeasurementAddedEvent(
  id: 'm${when.millisecondsSinceEpoch}$ph',
  plantId: plantId,
  occurredAt: when,
  createdAt: when,
  ph: ph,
);

PhaseChangedEvent phaseAt(
  DateTime when,
  PlantPhase from,
  PlantPhase to, {
  String plantId = 'p1',
}) => PhaseChangedEvent(
  id: 'f${when.millisecondsSinceEpoch}${to.name}$plantId',
  plantId: plantId,
  occurredAt: when,
  createdAt: when,
  previousPhase: from,
  newPhase: to,
);

Insight? firstOf(List<Insight> insights, InsightKind kind) {
  for (final insight in insights) {
    if (insight.kind == kind) return insight;
  }
  return null;
}

void main() {
  group('rega atrasada', () {
    test('dispara quando o intervalo passa da cadência da própria planta', () {
      final history = PlantHistory(
        plant: plantFixture(),
        events: [
          wateredAt(DateTime(2026, 5, 10)),
          wateredAt(DateTime(2026, 5, 13)),
          wateredAt(DateTime(2026, 5, 16)),
          wateredAt(DateTime(2026, 5, 19)),
        ],
      );

      final insight = firstOf(
        engine.analyze(histories: [history], now: now),
        InsightKind.wateringOverdue,
      );

      expect(insight, isNotNull);
      expect(insight!.severity, InsightSeverity.urgent);
      expect(insight.evidence['typicalIntervalDays'], 3);
      expect(insight.evidence['daysSinceLast'], greaterThan(12));
    });

    test('silencia quando a cadência está sendo respeitada', () {
      final history = PlantHistory(
        plant: plantFixture(),
        events: [
          wateredAt(now.subtract(const Duration(days: 9))),
          wateredAt(now.subtract(const Duration(days: 6))),
          wateredAt(now.subtract(const Duration(days: 3))),
          wateredAt(now.subtract(const Duration(days: 1))),
        ],
      );

      expect(
        firstOf(
          engine.analyze(histories: [history], now: now),
          InsightKind.wateringOverdue,
        ),
        isNull,
      );
    });

    test('sem histórico suficiente não inventa cadência', () {
      final history = PlantHistory(
        plant: plantFixture(),
        events: [wateredAt(DateTime(2026, 4, 1))],
      );

      expect(
        firstOf(
          engine.analyze(histories: [history], now: now),
          InsightKind.wateringOverdue,
        ),
        isNull,
        reason: 'a doutrina proíbe faixa universal; sem amostra, sem palpite',
      );
    });

    test('planta encerrada não gera insight', () {
      final history = PlantHistory(
        plant: plantFixture(status: PlantStatus.completed),
        events: [
          wateredAt(DateTime(2026, 5, 10)),
          wateredAt(DateTime(2026, 5, 13)),
          wateredAt(DateTime(2026, 5, 16)),
        ],
      );

      expect(engine.analyze(histories: [history], now: now), isEmpty);
    });
  });

  group('perfil incompleto', () {
    test('lista os campos faltantes', () {
      final bare = Plant(
        id: 'p9',
        privacyCode: 'GC-0009',
        startingPoint: PlantStartingPoint.seed,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 1),
      );

      final insight = firstOf(
        engine.analyze(
          histories: [PlantHistory(plant: bare, events: const [])],
          now: now,
        ),
        InsightKind.incompleteProfile,
      );

      expect(insight, isNotNull);
      expect(insight!.evidence['percent'], 0);
      expect(insight.missingFields, isNotEmpty);
      expect(insight.missingFields.length, lessThanOrEqualTo(3));
      expect(insight.missingFields, contains(CompletenessField.displayName));
    });

    test('perfil cheio não vira cobrança', () {
      expect(
        firstOf(
          engine.analyze(
            histories: [PlantHistory(plant: plantFixture(), events: const [])],
            now: now,
          ),
          InsightKind.incompleteProfile,
        ),
        isNull,
      );
    });
  });

  group('problema sem desfecho', () {
    ProblemReportedEvent problem(DateTime when) => ProblemReportedEvent(
      id: 'pr',
      plantId: 'p1',
      occurredAt: when,
      createdAt: when,
      category: ProblemCategory.pest,
    );

    test('cobra acompanhamento depois da carência', () {
      final history = PlantHistory(
        plant: plantFixture(),
        events: [problem(now.subtract(const Duration(days: 5)))],
      );

      final insight = firstOf(
        engine.analyze(histories: [history], now: now),
        InsightKind.problemWithoutFollowUp,
      );

      expect(insight, isNotNull);
      expect(insight!.subject, ProblemCategory.pest.name);
    });

    test('silencia quando houve acompanhamento', () {
      final when = now.subtract(const Duration(days: 5));
      final history = PlantHistory(
        plant: plantFixture(),
        events: [
          problem(when),
          ObservationAddedEvent(
            id: 'o1',
            plantId: 'p1',
            occurredAt: when.add(const Duration(days: 1)),
            createdAt: when.add(const Duration(days: 1)),
          ),
        ],
      );

      expect(
        firstOf(
          engine.analyze(histories: [history], now: now),
          InsightKind.problemWithoutFollowUp,
        ),
        isNull,
      );
    });
  });

  group('medição fora da linha de base', () {
    test('compara com o que o próprio usuário costuma medir', () {
      final events = <PlantEvent>[
        for (var day = 1; day <= 6; day++)
          measuredAt(DateTime(2026, 5, day), ph: 6.0 + (day.isEven ? 0.1 : 0)),
        measuredAt(DateTime(2026, 5, 20), ph: 4.2),
      ];

      final insight = firstOf(
        engine.analyze(
          histories: [PlantHistory(plant: plantFixture(), events: events)],
          now: now,
        ),
        InsightKind.measurementOutOfBaseline,
      );

      expect(insight, isNotNull);
      expect(insight!.subject, 'ph');
      expect(insight.evidence['value'], 4.2);
      expect(insight.evidence['sigmas'], greaterThan(2));
    });

    test('poucas amostras não viram linha de base', () {
      final events = <PlantEvent>[
        measuredAt(DateTime(2026, 5, 1), ph: 6.0),
        measuredAt(DateTime(2026, 5, 2), ph: 4.0),
      ];

      expect(
        firstOf(
          engine.analyze(
            histories: [PlantHistory(plant: plantFixture(), events: events)],
            now: now,
          ),
          InsightKind.measurementOutOfBaseline,
        ),
        isNull,
      );
    });
  });

  group('janela de colheita', () {
    test('projeta a partir dos ciclos que o usuário já fechou', () {
      PlantHistory finishedCycle(String id, int floweringDays) {
        final flowering = DateTime(2026, 1, 1);
        return PlantHistory(
          plant: plantFixture(
            id: id,
            status: PlantStatus.completed,
            phase: PlantPhase.harvest,
          ),
          events: [
            phaseAt(
              flowering,
              PlantPhase.vegetative,
              PlantPhase.flowering,
              plantId: id,
            ),
            HarvestedEvent(
              id: 'h$id',
              plantId: id,
              occurredAt: flowering.add(Duration(days: floweringDays)),
              createdAt: flowering.add(Duration(days: floweringDays)),
              dryWeight: 42,
            ),
          ],
        );
      }

      final current = PlantHistory(
        plant: plantFixture(id: 'now', phase: PlantPhase.flowering),
        events: [
          phaseAt(
            now.subtract(const Duration(days: 40)),
            PlantPhase.vegetative,
            PlantPhase.flowering,
            plantId: 'now',
          ),
        ],
      );

      final insight = firstOf(
        engine.analyze(
          histories: [finishedCycle('a', 60), finishedCycle('b', 64), current],
          now: now,
        ),
        InsightKind.harvestWindow,
      );

      expect(insight, isNotNull);
      expect(insight!.plantId, 'now');
      expect(insight.evidence['typicalFloweringDays'], 62);
      expect(insight.evidence['daysRemaining'], closeTo(22, 0.5));
    });
  });

  group('sequência em risco', () {
    test('avisa quando o último registro foi ontem', () {
      final insights = engine.analyze(
        histories: const [],
        now: now,
        progress: GamificationState(
          currentStreak: 6,
          longestStreak: 6,
          lastActivityDay: now.subtract(const Duration(days: 1)),
        ),
      );

      final insight = firstOf(insights, InsightKind.streakAtRisk);
      expect(insight, isNotNull);
      expect(insight!.evidence['streak'], 6);
    });

    test('quem já registrou hoje não é incomodado', () {
      final insights = engine.analyze(
        histories: const [],
        now: now,
        progress: GamificationState(
          currentStreak: 6,
          longestStreak: 6,
          lastActivityDay: now,
        ),
      );

      expect(firstOf(insights, InsightKind.streakAtRisk), isNull);
    });
  });

  group('ordenação e camadas opcionais', () {
    test('o mais grave vem primeiro', () {
      final history = PlantHistory(
        plant: plantFixture(),
        events: [
          wateredAt(DateTime(2026, 5, 1)),
          wateredAt(DateTime(2026, 5, 4)),
          wateredAt(DateTime(2026, 5, 7)),
        ],
      );

      final insights = engine.analyze(histories: [history], now: now);

      expect(insights, isNotEmpty);
      expect(insights.first.severity, InsightSeverity.urgent);
    });

    test('sem modelo instalado o app segue funcionando', () async {
      const inference = UnavailableLocalInference();

      expect(inference.isAvailable, isFalse);
      expect(inference.supports(LocalInferenceCapability.leafTriage), isFalse);
      expect(await inference.triageLeafPhoto('photo'), isEmpty);
      expect(
        await inference.answerFromDiary(question: 'como foi?', histories: []),
        isNull,
      );
    });
  });
}
