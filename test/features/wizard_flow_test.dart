import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';

import '../helpers/fake_plant_repository.dart';
import '../helpers/pump_app.dart';

Future<void> _tap(WidgetTester tester, String text) async {
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'criação a partir de semente percorre o fluxo completo em pt-BR',
    (tester) async {
      final repository = FakePlantRepository();
      await pumpApp(tester, repository);

      await _tap(tester, 'Adicionar planta');

      // Passo 1 — ponto de partida
      expect(find.text('O que você tem agora?'), findsOneWidget);
      expect(find.text('Muda'), findsOneWidget);
      expect(find.text('Planta em andamento'), findsOneWidget);
      await _tap(tester, 'Semente');

      // Passo 2 — identificação (código local + nome opcional)
      expect(find.text('Como você quer identificar a planta?'), findsOneWidget);
      expect(find.textContaining('GC-'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Nome da planta'),
        'Aurora',
      );
      await _tap(tester, 'Continuar');

      // Passo 3 — origem específica de semente
      expect(find.text('De onde ela veio?'), findsOneWidget);
      expect(find.text('Encontrada em uma flor'), findsOneWidget);
      await _tap(tester, 'Comprada');
      await _tap(tester, 'Continuar');

      // Passo 4 — genética desconhecida avança direto
      expect(find.text('Você conhece a genética?'), findsOneWidget);
      await _tap(tester, 'Não sei');

      // Passo 5 — datas de semente (germinação disponível)
      expect(find.text('Quando a semente foi plantada?'), findsOneWidget);
      expect(find.text('Data de germinação'), findsOneWidget);
      await _tap(tester, 'Hoje');
      await _tap(tester, 'Continuar');

      // Passo 6 — ambiente
      expect(find.text('Onde ela vai crescer?'), findsOneWidget);
      await _tap(tester, 'Indoor');
      await _tap(tester, 'Continuar');

      // Passo 7 — meio
      expect(find.text('Em que meio ela cresce?'), findsOneWidget);
      await _tap(tester, 'Solo');
      await _tap(tester, 'Continuar');

      // Passo 8 — fase sugerida a partir da semente
      expect(find.text('Em que fase ela está?'), findsOneWidget);
      await _tap(tester, 'Continuar');

      // Passo 9 — irrigação manual avança para a revisão
      expect(find.text('Como você rega?'), findsOneWidget);
      await _tap(tester, 'Manual');

      // Revisão
      expect(find.text('Revise sua planta'), findsOneWidget);
      expect(find.text('Aurora'), findsOneWidget);
      await _tap(tester, 'CRIAR PLANTA');

      // Sucesso
      expect(find.text('Planta criada'), findsOneWidget);
      expect(find.text('REGISTRAR PRIMEIRA ATIVIDADE'), findsOneWidget);
      expect(find.text('IR PARA A PLANTA'), findsOneWidget);

      final plant = repository.plants.values.single;
      expect(plant.displayName, 'Aurora');
      expect(plant.startingPoint, PlantStartingPoint.seed);
      expect(plant.origin, PlantOrigin.purchased);
      expect(plant.geneticType, PlantGeneticType.unknown);
      expect(plant.environment, GrowingEnvironment.indoor);
      expect(plant.growingMedium, GrowingMedium.soil);
      expect(plant.phase, PlantPhase.seed);
      expect(plant.irrigationMode, IrrigationMode.manual);
      expect(plant.startDate, isNotNull);
      expect(
        repository.events.whereType<PlantCreatedEvent>().where(
          (event) => event.plantId == plant.id,
        ),
        hasLength(1),
      );
    },
  );

  testWidgets('criação de clone não pergunta germinação', (tester) async {
    final repository = FakePlantRepository();
    await pumpApp(tester, repository);

    await _tap(tester, 'Adicionar planta');
    await _tap(tester, 'Clone');
    await _tap(tester, 'Continuar'); // identificação

    // Origem específica de clone, com concordância masculina.
    expect(find.text('Recebido'), findsOneWidget);
    expect(find.text('Comprado'), findsOneWidget);
    expect(find.text('Encontrada em uma flor'), findsNothing);
    await _tap(tester, 'Produção própria');
    await _tap(tester, 'Continuar');

    await _tap(tester, 'Não sei'); // genética

    // Datas de clone: sem germinação, com enraizamento.
    expect(find.text('Quando você recebeu o clone?'), findsOneWidget);
    expect(find.text('Data de germinação'), findsNothing);
    expect(find.text('Data de enraizamento'), findsOneWidget);
    await _tap(tester, 'Continuar');

    await _tap(tester, 'Continuar'); // ambiente
    await _tap(tester, 'Continuar'); // meio
    await _tap(tester, 'Continuar'); // fase
    await _tap(tester, 'Continuar'); // irrigação

    await _tap(tester, 'CRIAR PLANTA');
    expect(find.text('Planta criada'), findsOneWidget);

    final plant = repository.plants.values.single;
    expect(plant.startingPoint, PlantStartingPoint.clone);
    expect(plant.origin, PlantOrigin.ownProduction);
    expect(plant.phase, PlantPhase.seedling); // sugerida para clone
  });

  testWidgets('trocar o ponto de partida descarta as respostas dependentes', (
    tester,
  ) async {
    final repository = FakePlantRepository();
    await pumpApp(tester, repository);

    await _tap(tester, 'Adicionar planta');
    await _tap(tester, 'Semente');
    await _tap(tester, 'Continuar'); // identificação

    await _tap(tester, 'Comprada');
    await tester.enterText(
      find.widgetWithText(TextField, 'Detalhes da origem'),
      'Growshop da esquina',
    );
    await tester.pumpAndSettle();

    // Volta ao passo 1 e troca para clone.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    await _tap(tester, 'Clone');
    await _tap(tester, 'Continuar'); // identificação

    // A origem de semente sumiu junto com o detalhe digitado.
    expect(find.text('Encontrada em uma flor'), findsNothing);
    expect(find.text('Growshop da esquina'), findsNothing);

    // Origem em branco e os demais passos (genética, datas, ambiente, meio,
    // fase, irrigação) até a revisão.
    for (var i = 0; i < 7; i++) {
      await _tap(tester, 'Continuar');
    }
    await _tap(tester, 'CRIAR PLANTA');

    final plant = repository.plants.values.single;
    expect(plant.startingPoint, PlantStartingPoint.clone);
    expect(plant.origin, PlantOrigin.unknown);
    expect(plant.originDetails, isNull);
  });

  testWidgets('planta em andamento aceita tudo desconhecido', (tester) async {
    final repository = FakePlantRepository();
    await pumpApp(tester, repository);

    await _tap(tester, 'Adicionar planta');
    await _tap(tester, 'Planta em andamento');

    // Pula tudo: identificação, origem, genética, datas, ambiente, meio,
    // fase e irrigação.
    for (var i = 0; i < 8; i++) {
      await _tap(tester, 'Continuar');
    }

    await _tap(tester, 'CRIAR PLANTA');
    expect(find.text('Planta criada'), findsOneWidget);

    final plant = repository.plants.values.single;
    expect(plant.startingPoint, PlantStartingPoint.inProgress);
    expect(plant.origin, PlantOrigin.unknown);
    expect(plant.geneticType, PlantGeneticType.unknown);
    expect(plant.environment, GrowingEnvironment.unknown);
    expect(plant.growingMedium, GrowingMedium.unknown);
    expect(plant.irrigationMode, IrrigationMode.undefined);
    expect(plant.phase, PlantPhase.unknown);
    expect(plant.startDate, isNull);
    expect(plant.status, PlantStatus.active);
  });
}
