import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/identifiers.dart';
import 'package:growcipher/domain/models/plant_draft.dart';
import 'package:growcipher/domain/models/plant_enums.dart';

void main() {
  group('generatePrivacyCode', () {
    test('segue o formato GC-XXXX sem caracteres ambíguos', () {
      for (var i = 0; i < 50; i++) {
        final code = generatePrivacyCode();
        expect(code, matches(RegExp(r'^GC-[2-9A-HJ-KM-NP-Z]{4}$')));
        expect(code, isNot(contains('0')));
        expect(code, isNot(contains('O')));
        expect(code, isNot(contains('1')));
        expect(code, isNot(contains('I')));
        expect(code, isNot(contains('L')));
      }
    });

    test('não gera sequência previsível (códigos variam)', () {
      final codes = {for (var i = 0; i < 30; i++) generatePrivacyCode()};
      expect(codes.length, greaterThan(1));
    });
  });

  group('PlantDraft', () {
    test('só o ponto de partida é obrigatório', () {
      final draft = PlantDraft();
      expect(draft.canCreate, isFalse);

      draft.startingPoint = PlantStartingPoint.seed;
      expect(draft.canCreate, isTrue);
    });

    test('planta em andamento aceita tudo desconhecido', () {
      final draft = PlantDraft()
        ..startingPoint = PlantStartingPoint.inProgress
        ..startDateUnknown = true;

      final plant = draft.toPlant(id: 'p1', now: DateTime(2026, 8, 11));

      expect(plant.origin, PlantOrigin.unknown);
      expect(plant.geneticType, PlantGeneticType.unknown);
      expect(plant.environment, GrowingEnvironment.unknown);
      expect(plant.growingMedium, GrowingMedium.unknown);
      expect(plant.irrigationMode, IrrigationMode.undefined);
      expect(plant.phase, PlantPhase.unknown);
      expect(plant.startDate, isNull);
      expect(plant.startDateIsApproximate, isFalse);
      expect(plant.status, PlantStatus.active);
    });

    test('campos opcionais vazios não bloqueiam a criação', () {
      final draft = PlantDraft()
        ..startingPoint = PlantStartingPoint.seedling
        ..displayName = '   ';

      final plant = draft.toPlant(id: 'p2', now: DateTime(2026, 8, 11));

      expect(plant.displayName, isNull);
      expect(plant.displayLabel, plant.privacyCode);
    });

    test('fase é inferida do ponto de partida, mas pode ser alterada', () {
      final seed = PlantDraft()..startingPoint = PlantStartingPoint.seed;
      expect(seed.suggestedPhase, PlantPhase.seed);
      expect(
        seed.toPlant(id: 'p3', now: DateTime(2026, 8, 11)).phase,
        PlantPhase.seed,
      );

      final seedling = PlantDraft()
        ..startingPoint = PlantStartingPoint.seedling;
      expect(seedling.suggestedPhase, PlantPhase.seedling);

      final overridden = PlantDraft()
        ..startingPoint = PlantStartingPoint.seed
        ..phase = PlantPhase.vegetative;
      expect(
        overridden.toPlant(id: 'p4', now: DateTime(2026, 8, 11)).phase,
        PlantPhase.vegetative,
      );
    });

    test('genética só entra quando o usuário declarou conhecê-la', () {
      final draft = PlantDraft()
        ..startingPoint = PlantStartingPoint.clone
        ..knowsGenetics = false
        ..strain = 'Northern Lights'
        ..geneticType = PlantGeneticType.autoflower;

      final plant = draft.toPlant(id: 'p5', now: DateTime(2026, 8, 11));

      expect(plant.strain, isNull);
      expect(plant.geneticType, PlantGeneticType.unknown);
    });

    test('"não sei" na data limpa data e aproximação', () {
      final draft = PlantDraft()
        ..startingPoint = PlantStartingPoint.seed
        ..startDate = DateTime(2026, 8)
        ..startDateIsApproximate = true
        ..startDateUnknown = true;

      final plant = draft.toPlant(id: 'p6', now: DateTime(2026, 8, 11));

      expect(plant.startDate, isNull);
      expect(plant.startDateIsApproximate, isFalse);
    });
  });
}
