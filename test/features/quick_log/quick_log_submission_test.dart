import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';
import 'package:growcipher/features/quick_log/forms/end_plant_form.dart';
import 'package:growcipher/features/quick_log/forms/harvest_form.dart';
import 'package:growcipher/features/quick_log/forms/phase_change_form.dart';
import 'package:growcipher/features/quick_log/forms/quick_log_input.dart';
import 'package:growcipher/features/quick_log/forms/watered_form.dart';

import '../../helpers/fake_plant_repository.dart';

final _stamp = QuickLogStamp(
  plantId: 'plant-1',
  eventId: 'event-1',
  occurredAt: DateTime(2026, 8, 20, 21, 14),
  createdAt: DateTime(2026, 8, 23, 9),
);

Future<FakePlantRepository> _repositoryWithPlant() async {
  final repository = FakePlantRepository();
  final now = DateTime(2026, 8, 1);
  await repository.createPlant(
    Plant(
      id: 'plant-1',
      privacyCode: 'GC-TEST',
      startingPoint: PlantStartingPoint.seed,
      phase: PlantPhase.vegetative,
      createdAt: now,
      updatedAt: now,
    ),
  );
  return repository;
}

void main() {
  test('AddEvent só acrescenta à linha do tempo', () async {
    final repository = await _repositoryWithPlant();

    await const WateredInput(amount: '500').build(_stamp).apply(repository);

    expect(repository.events.whereType<WateredEvent>().single.amount, 500);
    expect(repository.plants['plant-1']!.phase, PlantPhase.vegetative);
    expect(repository.plants['plant-1']!.status, PlantStatus.active);
  });

  test('ChangePhase atualiza o snapshot e guarda a fase anterior', () async {
    final repository = await _repositoryWithPlant();

    await const PhaseChangeInput(
      newPhase: PlantPhase.flowering,
    ).build(_stamp).apply(repository);

    final change = repository.events.whereType<PhaseChangedEvent>().single;
    expect(change.previousPhase, PlantPhase.vegetative);
    expect(change.newPhase, PlantPhase.flowering);
    expect(change.occurredAt, _stamp.occurredAt);
    expect(repository.plants['plant-1']!.phase, PlantPhase.flowering);
  });

  test('encerrar não apaga a planta nem o histórico', () async {
    final repository = await _repositoryWithPlant();

    await const EndPlantInput(
      reason: PlantEndReason.died,
      cause: PlantEndCause.pest,
    ).build(_stamp).apply(repository);

    expect(repository.plants['plant-1'], isNotNull);
    expect(repository.plants['plant-1']!.status, PlantStatus.died);
    expect(repository.events.whereType<PlantCreatedEvent>(), hasLength(1));
  });

  test(
    'colheita que encerra o ciclo grava na ordem: colher, encerrar',
    () async {
      final repository = await _repositoryWithPlant();

      await const HarvestInput(
        dryWeight: '31',
        endCycle: true,
      ).build(_stamp).apply(repository);

      final quickLogged = repository.events
          .where((event) => event is! PlantCreatedEvent)
          .toList();
      expect(quickLogged.map((event) => event.type), [
        PlantEventType.harvested,
        PlantEventType.plantEnded,
      ]);

      final ended = repository.events.whereType<PlantEndedEvent>().single;
      expect(ended.reason, PlantEndReason.harvestCompleted);
      expect(repository.plants['plant-1']!.status, PlantStatus.completed);
    },
  );

  test('colheita sem encerrar mantém a planta ativa', () async {
    final repository = await _repositoryWithPlant();

    await const HarvestInput(dryWeight: '31').build(_stamp).apply(repository);

    expect(repository.events.whereType<PlantEndedEvent>(), isEmpty);
    expect(repository.plants['plant-1']!.status, PlantStatus.active);
  });
}
