import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/data/app_database.dart';
import 'package:growcipher/data/sqlite_plant_repository.dart';
import 'package:growcipher/domain/identifiers.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_draft.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late Database db;
  late SqlitePlantRepository repository;

  setUp(() async {
    db = await AppDatabase(
      factory: databaseFactoryFfi,
    ).open(path: inMemoryDatabasePath);
    repository = SqlitePlantRepository(db);
  });

  tearDown(() => db.close());

  Plant buildPlant({PlantDraft? draft}) {
    final resolved =
        draft ?? (PlantDraft()..startingPoint = PlantStartingPoint.seed);
    return resolved.toPlant(id: generateLocalId(), now: DateTime.now());
  }

  group('criação', () {
    test(
      'criar a partir de semente persiste a planta e gera PlantCreated',
      () async {
        final draft = PlantDraft()
          ..startingPoint = PlantStartingPoint.seed
          ..displayName = 'Aurora'
          ..origin = PlantOrigin.purchased
          ..knowsGenetics = true
          ..strain = 'Northern Lights'
          ..geneticType = PlantGeneticType.autoflower
          ..startDate = DateTime(2026, 8, 1)
          ..environment = GrowingEnvironment.indoor
          ..environmentPlace = EnvironmentPlace.growTent
          ..growingMedium = GrowingMedium.soil
          ..containerVolumeLiters = 11
          ..irrigationMode = IrrigationMode.manual;

        final plant = await repository.createPlant(buildPlant(draft: draft));

        final stored = await repository.getPlant(plant.id);
        expect(stored, isNotNull);
        expect(stored!.displayName, 'Aurora');
        expect(stored.startingPoint, PlantStartingPoint.seed);
        expect(stored.strain, 'Northern Lights');
        expect(stored.geneticType, PlantGeneticType.autoflower);
        expect(stored.phase, PlantPhase.seed);
        expect(stored.containerVolumeLiters, 11);

        final events = await repository.getEvents(plant.id);
        expect(events, hasLength(1));
        expect(events.single, isA<PlantCreatedEvent>());
      },
    );

    test(
      'germinação informada no cadastro vira evento na mesma transação',
      () async {
        final draft = PlantDraft()
          ..startingPoint = PlantStartingPoint.seed
          ..germinationDate = DateTime(2026, 8, 5);
        final plant = buildPlant(draft: draft);

        await repository.createPlant(
          plant,
          extraEvents: [
            GerminatedEvent(
              id: generateLocalId(),
              plantId: plant.id,
              occurredAt: draft.germinationDate!,
              createdAt: DateTime.now(),
            ),
          ],
        );

        final events = await repository.getEvents(plant.id);
        expect(events.whereType<GerminatedEvent>(), hasLength(1));
        expect(events.whereType<PlantCreatedEvent>(), hasLength(1));
      },
    );

    test('criação mínima (só o ponto de partida) não é bloqueada', () async {
      final plant = await repository.createPlant(
        buildPlant(
          draft: PlantDraft()..startingPoint = PlantStartingPoint.inProgress,
        ),
      );

      final stored = await repository.getPlant(plant.id);
      expect(stored, isNotNull);
      expect(stored!.origin, PlantOrigin.unknown);
      expect(stored.geneticType, PlantGeneticType.unknown);
      expect(stored.growingMedium, GrowingMedium.unknown);
      expect(stored.startDate, isNull);
      expect(stored.status, PlantStatus.active);
    });
  });

  group('linha do tempo', () {
    test('rega gera Watered com payload preservado', () async {
      final plant = await repository.createPlant(buildPlant());

      await repository.addEvent(
        WateredEvent(
          id: generateLocalId(),
          plantId: plant.id,
          occurredAt: DateTime(2026, 8, 10, 8, 30),
          createdAt: DateTime.now(),
          amount: 500,
          unit: 'ml',
          solutionType: 'água pura',
          notes: 'manhã',
        ),
      );

      final events = await repository.getEvents(plant.id);
      final watered = events.whereType<WateredEvent>().single;
      expect(watered.amount, 500);
      expect(watered.unit, 'ml');
      expect(watered.solutionType, 'água pura');
      expect(watered.notes, 'manhã');
      expect(watered.type, PlantEventType.watered);
    });

    test('tratamento não é salvo como alimentação', () async {
      final plant = await repository.createPlant(buildPlant());

      await repository.addEvent(
        TreatmentAppliedEvent(
          id: generateLocalId(),
          plantId: plant.id,
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
          treatmentType: TreatmentType.pestControl,
          product: 'óleo de neem',
          method: 'pulverização foliar',
        ),
      );

      final events = await repository.getEvents(plant.id);
      expect(events.whereType<FedEvent>(), isEmpty);

      final treatment = events.whereType<TreatmentAppliedEvent>().single;
      expect(treatment.type, PlantEventType.treatmentApplied);
      expect(treatment.treatmentType, TreatmentType.pestControl);
      expect(treatment.product, 'óleo de neem');
    });

    test('medição aceita métricas parciais', () async {
      final plant = await repository.createPlant(buildPlant());

      await repository.addEvent(
        MeasurementAddedEvent(
          id: generateLocalId(),
          plantId: plant.id,
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
          ph: 6.2,
          ec: 1.8,
        ),
      );

      final measurement = (await repository.getEvents(
        plant.id,
      )).whereType<MeasurementAddedEvent>().single;
      expect(measurement.ph, 6.2);
      expect(measurement.ec, 1.8);
      expect(measurement.temperatureC, isNull);
      expect(measurement.dli, isNull);
    });
  });

  group('mudança de fase', () {
    test(
      'registra PhaseChanged com fase anterior e nova, além do snapshot',
      () async {
        final plant = await repository.createPlant(buildPlant());
        expect(plant.phase, PlantPhase.seed);

        final updated = await repository.changePhase(
          plantId: plant.id,
          newPhase: PlantPhase.vegetative,
          occurredAt: DateTime(2026, 8, 10),
        );

        expect(updated.phase, PlantPhase.vegetative);

        final stored = await repository.getPlant(plant.id);
        expect(stored!.phase, PlantPhase.vegetative);

        final change = (await repository.getEvents(
          plant.id,
        )).whereType<PhaseChangedEvent>().single;
        expect(change.previousPhase, PlantPhase.seed);
        expect(change.newPhase, PlantPhase.vegetative);
      },
    );
  });

  group('encerramento', () {
    test('morte gera PlantEnded com causa e não apaga a planta', () async {
      final plant = await repository.createPlant(buildPlant());
      await repository.addEvent(
        WateredEvent(
          id: generateLocalId(),
          plantId: plant.id,
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );

      final updated = await repository.endPlant(
        plantId: plant.id,
        reason: PlantEndReason.died,
        cause: PlantEndCause.pest,
        notes: 'ácaros',
      );

      expect(updated.status, PlantStatus.died);

      // A planta continua existindo, com todo o histórico.
      final stored = await repository.getPlant(plant.id);
      expect(stored, isNotNull);
      expect(stored!.status, PlantStatus.died);

      final events = await repository.getEvents(plant.id);
      expect(events.whereType<PlantCreatedEvent>(), hasLength(1));
      expect(events.whereType<WateredEvent>(), hasLength(1));

      final ended = events.whereType<PlantEndedEvent>().single;
      expect(ended.reason, PlantEndReason.died);
      expect(ended.cause, PlantEndCause.pest);
      expect(ended.notes, 'ácaros');
    });

    test('colheita pode encerrar o ciclo preservando o histórico', () async {
      final plant = await repository.createPlant(buildPlant());

      await repository.addEvent(
        HarvestedEvent(
          id: generateLocalId(),
          plantId: plant.id,
          occurredAt: DateTime(2026, 8, 10),
          createdAt: DateTime.now(),
          wetWeight: 320,
          unit: 'g',
        ),
      );
      await repository.endPlant(
        plantId: plant.id,
        reason: PlantEndReason.harvestCompleted,
        occurredAt: DateTime(2026, 8, 10),
      );

      final stored = await repository.getPlant(plant.id);
      expect(stored!.status, PlantStatus.completed);

      final events = await repository.getEvents(plant.id);
      expect(events.whereType<HarvestedEvent>().single.wetWeight, 320);
      expect(
        events.whereType<PlantEndedEvent>().single.reason,
        PlantEndReason.harvestCompleted,
      );
      expect(events.whereType<PlantCreatedEvent>(), hasLength(1));
    });
  });
}
