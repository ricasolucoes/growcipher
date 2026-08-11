import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';

import '../helpers/fake_plant_repository.dart';
import '../helpers/pump_app.dart';

Future<FakePlantRepository> _repositoryWithPlant() async {
  final repository = FakePlantRepository();
  final now = DateTime.now();
  await repository.createPlant(
    Plant(
      id: 'plant-1',
      displayName: 'Aurora',
      privacyCode: 'GC-TEST',
      startingPoint: PlantStartingPoint.seed,
      phase: PlantPhase.vegetative,
      createdAt: now,
      updatedAt: now,
    ),
  );
  return repository;
}

Future<void> _openQuickLog(WidgetTester tester) async {
  await tester.tap(find.text('Aurora'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Registrar atividade'));
  await tester.pumpAndSettle();
  expect(find.text('O que aconteceu?'), findsOneWidget);
}

void main() {
  testWidgets('menu do registro rápido mostra todas as ações em português', (
    tester,
  ) async {
    await pumpApp(tester, await _repositoryWithPlant());
    await _openQuickLog(tester);

    for (final label in [
      'Reguei',
      'Nutrientes / alimentação',
      'Tratamento',
      'Medição',
      'Transplante',
      'Mudança de fase',
      'Foto',
      'Observação',
      'Problema',
      'Tarefa concluída',
      'Colheita',
      'Encerrar planta',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'faltou "$label"');
    }
  });

  testWidgets('rega salva apenas com data/hora e gera Watered', (tester) async {
    final repository = await _repositoryWithPlant();
    await pumpApp(tester, repository);
    await _openQuickLog(tester);

    await tester.tap(find.text('Reguei'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(find.text('Registro salvo'), findsOneWidget);
    final watered = repository.events.whereType<WateredEvent>().single;
    expect(watered.plantId, 'plant-1');
    expect(watered.amount, isNull);
  });

  testWidgets('tratamento gera TreatmentApplied, não Fed', (tester) async {
    final repository = await _repositoryWithPlant();
    await pumpApp(tester, repository);
    await _openQuickLog(tester);

    await tester.tap(find.text('Tratamento'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Controle de pragas'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repository.events.whereType<FedEvent>(), isEmpty);
    final treatment = repository.events
        .whereType<TreatmentAppliedEvent>()
        .single;
    expect(treatment.treatmentType, TreatmentType.pestControl);
  });

  testWidgets('mudança de fase registra PhaseChanged com fase anterior', (
    tester,
  ) async {
    final repository = await _repositoryWithPlant();
    await pumpApp(tester, repository);
    await _openQuickLog(tester);

    await tester.tap(find.text('Mudança de fase'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Floração'));
    await tester.pump();
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final change = repository.events.whereType<PhaseChangedEvent>().single;
    expect(change.previousPhase, PlantPhase.vegetative);
    expect(change.newPhase, PlantPhase.flowering);
    expect(repository.plants['plant-1']!.phase, PlantPhase.flowering);
  });

  testWidgets('encerrar por morte pede motivo, aceita causa e preserva tudo', (
    tester,
  ) async {
    final repository = await _repositoryWithPlant();
    await pumpApp(tester, repository);
    await _openQuickLog(tester);

    await tester.tap(find.text('Encerrar planta'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Morreu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Praga'));
    await tester.pump();
    await tester.ensureVisible(find.text('Salvar'));
    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    final ended = repository.events.whereType<PlantEndedEvent>().single;
    expect(ended.reason, PlantEndReason.died);
    expect(ended.cause, PlantEndCause.pest);

    // A planta não é apagada: continua na lista com o histórico completo.
    expect(repository.plants['plant-1'], isNotNull);
    expect(repository.plants['plant-1']!.status, PlantStatus.died);
    expect(repository.events.whereType<PlantCreatedEvent>(), hasLength(1));
  });

  testWidgets('foto aparece desabilitada até a galeria privada existir', (
    tester,
  ) async {
    await pumpApp(tester, await _repositoryWithPlant());
    await _openQuickLog(tester);

    expect(find.text('Chega com a galeria privada'), findsOneWidget);
    await tester.tap(find.text('Foto'));
    await tester.pumpAndSettle();

    // Continua no menu — a ação está desabilitada.
    expect(find.text('O que aconteceu?'), findsOneWidget);
  });
}
