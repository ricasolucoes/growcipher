import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/data/app_database.dart';
import 'package:growcipher/data/sqlite_plant_repository.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Garante que nada se perde entre modelo e banco: toda coluna de [Plant] e
/// todo payload dos 14 tipos de [PlantEvent] voltam iguais depois de gravar.
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

  test(
    'plant com todos os campos preenchidos sobrevive ao roundtrip',
    () async {
      final created = DateTime.fromMillisecondsSinceEpoch(1770000000000);
      final plant = Plant(
        id: 'plant-full',
        displayName: 'Aurora',
        privacyCode: 'GC-7F2A',
        photoRef: 'photo-ref-1',
        startingPoint: PlantStartingPoint.clone,
        origin: PlantOrigin.giftOrTrade,
        originDetails: 'troca com o vizinho',
        strain: 'Northern Lights',
        geneticType: PlantGeneticType.photoperiod,
        startDate: DateTime(2026, 3, 15),
        startDateIsApproximate: true,
        seedObtainedDate: DateTime(2026, 3, 1),
        rootedDate: DateTime(2026, 3, 20),
        environment: GrowingEnvironment.mixed,
        environmentPlace: EnvironmentPlace.greenhouse,
        environmentName: 'Estufa dos fundos',
        growingMedium: GrowingMedium.coco,
        containerType: 'vaso de tecido',
        containerVolumeLiters: 18.5,
        irrigationMode: IrrigationMode.mixed,
        irrigationSystem: IrrigationSystem.drip,
        phase: PlantPhase.flowering,
        status: PlantStatus.active,
        createdAt: created,
        updatedAt: created,
      );

      await repository.createPlant(plant);
      final stored = (await repository.getPlant('plant-full'))!;

      expect(stored.displayName, 'Aurora');
      expect(stored.privacyCode, 'GC-7F2A');
      expect(stored.photoRef, 'photo-ref-1');
      expect(stored.startingPoint, PlantStartingPoint.clone);
      expect(stored.origin, PlantOrigin.giftOrTrade);
      expect(stored.originDetails, 'troca com o vizinho');
      expect(stored.strain, 'Northern Lights');
      expect(stored.geneticType, PlantGeneticType.photoperiod);
      expect(stored.startDate, DateTime(2026, 3, 15));
      expect(stored.startDateIsApproximate, isTrue);
      expect(stored.seedObtainedDate, DateTime(2026, 3, 1));
      expect(stored.rootedDate, DateTime(2026, 3, 20));
      expect(stored.environment, GrowingEnvironment.mixed);
      expect(stored.environmentPlace, EnvironmentPlace.greenhouse);
      expect(stored.environmentName, 'Estufa dos fundos');
      expect(stored.growingMedium, GrowingMedium.coco);
      expect(stored.containerType, 'vaso de tecido');
      expect(stored.containerVolumeLiters, 18.5);
      expect(stored.irrigationMode, IrrigationMode.mixed);
      expect(stored.irrigationSystem, IrrigationSystem.drip);
      expect(stored.phase, PlantPhase.flowering);
      expect(stored.status, PlantStatus.active);
      expect(stored.createdAt, created);
      expect(stored.updatedAt, created);
    },
  );

  test(
    'os 14 tipos de evento sobrevivem ao roundtrip com payload completo',
    () async {
      final now = DateTime.fromMillisecondsSinceEpoch(1770000000000);
      final plant = Plant(
        id: 'p1',
        privacyCode: 'GC-XXXX',
        startingPoint: PlantStartingPoint.seed,
        createdAt: now,
        updatedAt: now,
      );
      await repository.createPlant(plant);

      PlantEvent tag(String id, PlantEvent Function(String id) build) =>
          build(id);

      final events = <PlantEvent>[
        tag(
          'e-germinated',
          (id) => GerminatedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            notes: 'brotou',
          ),
        ),
        tag(
          'e-watered',
          (id) => WateredEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            amount: 750.5,
            unit: 'ml',
            solutionType: 'água filtrada',
            notes: 'rega da manhã',
          ),
        ),
        tag(
          'e-fed',
          (id) => FedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            product: 'bio grow',
            amount: 2,
            unit: 'ml/L',
            notes: 'meia dose',
          ),
        ),
        tag(
          'e-treatment',
          (id) => TreatmentAppliedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            treatmentType: TreatmentType.fungusControl,
            product: 'bicarbonato',
            amount: 5,
            unit: 'g/L',
            method: 'pulverização',
            notes: 'oídio nas folhas baixas',
          ),
        ),
        tag(
          'e-measurement',
          (id) => MeasurementAddedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            temperatureC: 24.5,
            humidityPercent: 60,
            ph: 6.2,
            ec: 1.4,
            vpd: 1.1,
            dli: 38.7,
            notes: 'medição da tarde',
          ),
        ),
        tag(
          'e-transplant',
          (id) => TransplantedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            containerType: 'vaso 11L',
            containerVolumeLiters: 11,
            notes: 'raízes ocupando tudo',
          ),
        ),
        tag(
          'e-phase',
          (id) => PhaseChangedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            previousPhase: PlantPhase.vegetative,
            newPhase: PlantPhase.flowering,
            notes: 'virou o fotoperíodo',
          ),
        ),
        tag(
          'e-photo',
          (id) => PhotoAddedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            photoRef: 'ref-42',
            notes: 'semana 4',
          ),
        ),
        tag(
          'e-observation',
          (id) => ObservationAddedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            notes: 'cheiro forte começando',
          ),
        ),
        tag(
          'e-problem',
          (id) => ProblemReportedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            category: ProblemCategory.deficiency,
            photoRef: 'ref-43',
            notes: 'folhas amareladas',
          ),
        ),
        tag(
          'e-task',
          (id) => TaskCompletedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            taskDescription: 'podar folhas baixas',
            notes: 'feito',
          ),
        ),
        tag(
          'e-harvest',
          (id) => HarvestedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            wetWeight: 420.5,
            dryWeight: 96.25,
            unit: 'g',
            notes: 'secagem em 12 dias',
          ),
        ),
        tag(
          'e-ended',
          (id) => PlantEndedEvent(
            id: id,
            plantId: 'p1',
            occurredAt: now,
            createdAt: now,
            reason: PlantEndReason.died,
            cause: PlantEndCause.watering,
            notes: 'afoguei',
          ),
        ),
      ];

      for (final event in events) {
        await repository.addEvent(event);
      }

      final stored = {
        for (final event in await repository.getEvents('p1')) event.id: event,
      };

      // plantCreated (o 14º tipo) nasce da própria criação da planta.
      expect(stored.values.whereType<PlantCreatedEvent>(), hasLength(1));
      expect(stored.length, events.length + 1);

      for (final original in events) {
        final back = stored[original.id];
        expect(back, isNotNull, reason: 'evento ${original.id} sumiu');
        expect(back!.type, original.type);
        expect(back.plantId, original.plantId);
        expect(back.occurredAt, original.occurredAt);
        expect(back.createdAt, original.createdAt);
        expect(back.notes, original.notes);
        expect(
          back.payloadToMap(),
          original.payloadToMap(),
          reason: 'payload divergente em ${original.id}',
        );
      }

      // Amostragem tipada: o subtipo certo é reconstruído, não só o payload.
      expect(
        (stored['e-treatment']! as TreatmentAppliedEvent).treatmentType,
        TreatmentType.fungusControl,
      );
      expect((stored['e-harvest']! as HarvestedEvent).dryWeight, 96.25);
      expect(
        (stored['e-ended']! as PlantEndedEvent).cause,
        PlantEndCause.watering,
      );
      expect(
        (stored['e-phase']! as PhaseChangedEvent).previousPhase,
        PlantPhase.vegetative,
      );
    },
  );

  test('payload vazio e enum desconhecido não quebram a leitura', () async {
    final now = DateTime.now();
    await repository.createPlant(
      Plant(
        id: 'p2',
        privacyCode: 'GC-YYYY',
        startingPoint: PlantStartingPoint.seed,
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Simula registro gravado por uma versão futura do app.
    await db.insert('plant_events', {
      'id': 'e-futuro',
      'plant_id': 'p2',
      'type': 'somethingFromTheFuture',
      'occurred_at': now.millisecondsSinceEpoch,
      'created_at': now.millisecondsSinceEpoch,
      'notes': null,
      'payload': '{}',
    });

    final events = await repository.getEvents('p2');
    expect(events, hasLength(2));
    // Cai no fallback em vez de estourar.
    expect(
      events.firstWhere((e) => e.id == 'e-futuro'),
      isA<ObservationAddedEvent>(),
    );
  });

  test(
    'migration cria o esquema na versão corrente sem recriar dados',
    () async {
      final version = await db.getVersion();
      expect(version, AppDatabase.version);

      final tables = await db.query(
        'sqlite_master',
        columns: ['name'],
        where: 'type = ?',
        whereArgs: ['table'],
      );
      final names = tables.map((row) => row['name']).toSet();
      expect(names, containsAll(<String>['plants', 'plant_events']));
    },
  );
}
