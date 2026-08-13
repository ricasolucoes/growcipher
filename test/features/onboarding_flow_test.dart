import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';

import '../helpers/fake_plant_repository.dart';
import '../helpers/pump_app.dart';

/// Celular pequeno comum (mesmo viewport lógico de um Galaxy J/A antigo).
const Size _smallPhone = Size(360, 640);

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

/// Vai da home até a tela de sucesso com o mínimo de respostas possível.
Future<void> _createMinimalPlant(
  WidgetTester tester, {
  required String startingPoint,
}) async {
  await _tap(tester, 'Adicionar planta');
  await _tap(tester, startingPoint);
  for (var i = 0; i < 8; i++) {
    await tester.ensureVisible(find.text('Continuar'));
    await _tap(tester, 'Continuar');
  }
  await tester.ensureVisible(find.text('CRIAR PLANTA'));
  await _tap(tester, 'CRIAR PLANTA');
}

void main() {
  testWidgets(
    'fluxo completo: criar planta, registrar primeira atividade e cair na timeline',
    (tester) async {
      final repository = FakePlantRepository();
      await pumpApp(tester, repository);

      await _createMinimalPlant(tester, startingPoint: 'Semente');
      expect(find.text('Planta criada'), findsOneWidget);

      // CTA primário abre o registro rápido da planta recém-criada.
      await _tap(tester, 'REGISTRAR PRIMEIRA ATIVIDADE');
      expect(find.text('O que aconteceu?'), findsOneWidget);

      await _tap(tester, 'Reguei');
      await _tap(tester, 'Salvar');

      // Após salvar, o usuário vai para o perfil da planta com a timeline.
      expect(find.text('Linha do tempo'), findsOneWidget);
      expect(find.text('Rega'), findsOneWidget);
      expect(find.text('Planta cadastrada'), findsOneWidget);

      final plant = repository.plants.values.single;
      expect(
        repository.events.whereType<WateredEvent>().single.plantId,
        plant.id,
      );
      expect(repository.events.whereType<PlantCreatedEvent>(), hasLength(1));
    },
  );

  testWidgets('wizard e revisão funcionam em tela pequena (360x640)', (
    tester,
  ) async {
    final repository = FakePlantRepository();
    await pumpApp(tester, repository, size: _smallPhone);

    await _createMinimalPlant(tester, startingPoint: 'Muda');

    expect(find.text('Planta criada'), findsOneWidget);
    expect(
      repository.plants.values.single.startingPoint,
      PlantStartingPoint.seedling,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu do registro rápido cabe em tela pequena (360x640)', (
    tester,
  ) async {
    final repository = FakePlantRepository();
    await pumpApp(tester, repository, size: _smallPhone);

    await _createMinimalPlant(tester, startingPoint: 'Clone');
    await _tap(tester, 'REGISTRAR PRIMEIRA ATIVIDADE');

    // Rótulo mais longo do menu, que quebra em duas linhas nessa largura.
    expect(find.text('Nutrientes / alimentação'), findsOneWidget);
    expect(find.text('Encerrar planta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('planta encerrada continua listada na home com o status', (
    tester,
  ) async {
    final repository = FakePlantRepository();
    await pumpApp(tester, repository);

    await _createMinimalPlant(tester, startingPoint: 'Planta em andamento');
    await _tap(tester, 'IR PARA A PLANTA');

    await _tap(tester, 'Registrar atividade');
    await _tap(tester, 'Encerrar planta');
    await _tap(tester, 'Morreu');
    await tester.ensureVisible(find.text('Salvar'));
    await _tap(tester, 'Salvar');

    // Timeline preserva a criação e ganha o encerramento.
    expect(find.text('Ciclo encerrado'), findsOneWidget);
    expect(find.text('Planta cadastrada'), findsOneWidget);

    // De volta à home, a planta continua lá — morrer não apaga nada.
    // (`pageBack` não serve: procura o tooltip "Back", que aqui é "Voltar".)
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Suas plantas'), findsOneWidget);
    expect(find.text('Morta'), findsOneWidget);
    expect(repository.plants.values.single.status, PlantStatus.died);
  });
}
