import 'package:flutter_test/flutter_test.dart';
import 'package:growcipher/domain/models/plant_draft.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/features/plant_wizard/wizard_machine.dart';

/// Máquina posicionada num passo, como se o `PageView` já tivesse chegado
/// nele.
WizardMachine _at(WizardStep step, {PlantDraft? draft}) {
  final machine = WizardMachine(draft: draft);
  machine.syncToPage(machine.indexOf(step));
  return machine;
}

WizardMachine _from(PlantStartingPoint? point) {
  final draft = PlantDraft()..startingPoint = point;
  return WizardMachine(draft: draft);
}

void main() {
  group('navegação', () {
    test('começa no ponto de partida', () {
      final machine = WizardMachine();

      expect(machine.index, 0);
      expect(machine.step, WizardStep.start);
      expect(machine.canPop, isTrue);
      expect(machine.previousIndex, isNull, reason: 'voltar aqui fecha a tela');
    });

    test('o último passo não tem próximo', () {
      final machine = _at(WizardStep.review);

      expect(machine.nextIndex, isNull);
      expect(machine.previousIndex, machine.indexOf(WizardStep.irrigation));
      expect(machine.canPop, isFalse);
    });

    test('a revisão não conta como pergunta no rótulo de progresso', () {
      expect(WizardMachine.steps, hasLength(10));
      expect(_at(WizardStep.start).questionNumber, 1);
      expect(_at(WizardStep.start).questionCount, 9);
      expect(_at(WizardStep.irrigation).questionNumber, 9);
    });

    test('a barra de progresso do topo inclui a revisão', () {
      expect(_at(WizardStep.start).progress, 0.1);
      expect(_at(WizardStep.review).progress, 1.0);
    });

    test('a barra inferior some no primeiro passo e na revisão', () {
      expect(_at(WizardStep.start).showsBottomBar, isFalse);
      expect(_at(WizardStep.review).showsBottomBar, isFalse);
      for (final step in WizardStep.values) {
        if (step == WizardStep.start || step == WizardStep.review) continue;
        expect(
          _at(step).showsBottomBar,
          isTrue,
          reason: '$step deveria ter Continuar',
        );
      }
    });

    test('a revisão volta para qualquer passo pelo índice', () {
      final machine = _at(WizardStep.review);

      machine.syncToPage(machine.indexOf(WizardStep.dates));
      expect(machine.step, WizardStep.dates);
    });
  });

  group('"Pular" só aparece em passo sem resposta', () {
    test('identificação e fase nunca ficam sem resposta', () {
      // O código local já vem sorteado e a fase já vem sugerida.
      expect(_at(WizardStep.identity).currentStepHasAnswer, isTrue);
      expect(_at(WizardStep.phase).currentStepHasAnswer, isTrue);
    });

    test(
      'origem, genética, ambiente, meio e irrigação começam sem resposta',
      () {
        for (final step in [
          WizardStep.origin,
          WizardStep.genetics,
          WizardStep.environment,
          WizardStep.medium,
          WizardStep.irrigation,
        ]) {
          expect(_at(step).currentStepHasAnswer, isFalse, reason: '$step');
        }
      },
    );

    test('"não sei" na data conta como resposta', () {
      final machine = _at(WizardStep.dates);
      expect(machine.currentStepHasAnswer, isFalse);

      machine.setStartDateUnknown();
      expect(machine.currentStepHasAnswer, isTrue);
    });

    test('responder o passo esconde o "Pular"', () {
      final origin = _at(WizardStep.origin)..selectOrigin(PlantOrigin.unknown);
      expect(origin.currentStepHasAnswer, isTrue);

      final medium = _at(WizardStep.medium)..selectMedium(GrowingMedium.soil);
      expect(medium.currentStepHasAnswer, isTrue);
    });
  });

  group('caminhos de entrada', () {
    test('semente oferece "encontrada em uma flor"', () {
      final options = _from(PlantStartingPoint.seed).originOptions;

      expect(options, contains(PlantOrigin.foundSeed));
      expect(options, isNot(contains(PlantOrigin.receivedClone)));
    });

    test('clone oferece "recebido" e não a semente encontrada', () {
      final options = _from(PlantStartingPoint.clone).originOptions;

      expect(options, contains(PlantOrigin.receivedClone));
      expect(options, isNot(contains(PlantOrigin.foundSeed)));
      expect(options.first, PlantOrigin.ownProduction);
    });

    test('muda, cultivo em andamento e sem resposta usam a lista genérica', () {
      const generic = [
        PlantOrigin.purchased,
        PlantOrigin.ownProduction,
        PlantOrigin.giftOrTrade,
        PlantOrigin.other,
        PlantOrigin.unknown,
      ];

      expect(_from(PlantStartingPoint.seedling).originOptions, generic);
      expect(_from(PlantStartingPoint.inProgress).originOptions, generic);
      expect(_from(null).originOptions, generic);
    });

    test('cada caminho abre a sua pergunta de data', () {
      expect(
        _from(PlantStartingPoint.seed).datesQuestion,
        WizardDatesQuestion.seed,
      );
      expect(
        _from(PlantStartingPoint.seedling).datesQuestion,
        WizardDatesQuestion.seedling,
      );
      expect(
        _from(PlantStartingPoint.clone).datesQuestion,
        WizardDatesQuestion.clone,
      );
      expect(
        _from(PlantStartingPoint.inProgress).datesQuestion,
        WizardDatesQuestion.inProgress,
      );
      expect(_from(null).datesQuestion, WizardDatesQuestion.inProgress);
    });

    test('clone não germina e semente não enraíza', () {
      expect(_from(PlantStartingPoint.seed).extraDates, [
        WizardExtraDate.seedObtained,
        WizardExtraDate.germination,
      ]);
      expect(_from(PlantStartingPoint.seedling).extraDates, [
        WizardExtraDate.germination,
      ]);
      expect(_from(PlantStartingPoint.clone).extraDates, [
        WizardExtraDate.rooted,
      ]);
      expect(_from(PlantStartingPoint.inProgress).extraDates, isEmpty);
    });

    test('trocar o ponto de partida descarta as respostas dependentes', () {
      final machine = WizardMachine();
      machine.selectStartingPoint(PlantStartingPoint.seed);
      machine
        ..selectOrigin(PlantOrigin.foundSeed)
        ..selectPhase(PlantPhase.vegetative)
        ..setExtraDate(WizardExtraDate.germination, DateTime(2026, 8, 1))
        ..setExtraDate(WizardExtraDate.seedObtained, DateTime(2026, 7, 1));
      machine.draft.originDetails = 'Growshop da esquina';

      machine.selectStartingPoint(PlantStartingPoint.clone);

      final draft = machine.draft;
      expect(draft.startingPoint, PlantStartingPoint.clone);
      expect(draft.origin, isNull, reason: 'a origem escolhida saiu da lista');
      expect(draft.originDetails, isNull);
      expect(draft.germinationDate, isNull);
      expect(draft.seedObtainedDate, isNull);
      expect(draft.rootedDate, isNull);
      expect(draft.phase, isNull);
      expect(machine.selectedPhase, PlantPhase.seedling, reason: 'sugerida');
    });

    test('reescolher o mesmo ponto de partida não apaga nada', () {
      final machine = WizardMachine();
      machine.selectStartingPoint(PlantStartingPoint.seed);
      machine.selectOrigin(PlantOrigin.foundSeed);

      machine.selectStartingPoint(PlantStartingPoint.seed);

      expect(machine.draft.origin, PlantOrigin.foundSeed);
    });

    test('respostas independentes sobrevivem à troca de caminho', () {
      final machine = WizardMachine();
      machine.selectStartingPoint(PlantStartingPoint.seed);
      machine
        ..selectEnvironment(GrowingEnvironment.indoor)
        ..selectMedium(GrowingMedium.coco)
        ..answerGenetics(true);
      machine.draft.displayName = 'Aurora';

      machine.selectStartingPoint(PlantStartingPoint.inProgress);

      expect(machine.draft.environment, GrowingEnvironment.indoor);
      expect(machine.draft.growingMedium, GrowingMedium.coco);
      expect(machine.draft.knowsGenetics, isTrue);
      expect(machine.draft.displayName, 'Aurora');
    });
  });

  group('respostas que encerram o passo sozinhas', () {
    test('escolher o ponto de partida sempre avança', () {
      final machine = WizardMachine();

      expect(
        machine.selectStartingPoint(PlantStartingPoint.seed),
        WizardNavigation.advance,
      );
      expect(
        machine.selectStartingPoint(PlantStartingPoint.seed),
        WizardNavigation.advance,
        reason: 'mesmo repetindo a escolha',
      );
    });

    test('"não sei" na genética avança; conhecer abre os campos', () {
      final machine = WizardMachine();

      expect(machine.answerGenetics(false), WizardNavigation.advance);
      expect(machine.answerGenetics(true), WizardNavigation.stay);
      expect(machine.draft.knowsGenetics, isTrue);
    });

    test('rega manual e indefinida avançam sem pedir sistema', () {
      for (final mode in [IrrigationMode.manual, IrrigationMode.undefined]) {
        final machine = WizardMachine();
        machine.selectIrrigationSystem(IrrigationSystem.drip);

        expect(machine.selectIrrigationMode(mode), WizardNavigation.advance);
        expect(machine.draft.irrigationSystem, isNull, reason: '$mode');
      }
    });

    test('rega automática e mista ficam para escolher o sistema', () {
      for (final mode in [IrrigationMode.automatic, IrrigationMode.mixed]) {
        final machine = WizardMachine();

        expect(machine.selectIrrigationMode(mode), WizardNavigation.stay);
        machine.selectIrrigationSystem(IrrigationSystem.reservoir);
        expect(machine.draft.irrigationSystem, IrrigationSystem.reservoir);
      }
    });

    test('as demais respostas esperam o "Continuar"', () {
      final machine = WizardMachine();

      expect(
        machine.selectOrigin(PlantOrigin.purchased),
        WizardNavigation.stay,
      );
      expect(machine.selectMedium(GrowingMedium.soil), WizardNavigation.stay);
      expect(machine.selectPhase(PlantPhase.vegetative), WizardNavigation.stay);
      expect(
        machine.selectEnvironment(GrowingEnvironment.indoor),
        WizardNavigation.stay,
      );
      expect(
        machine.setStartDate(DateTime(2026, 8, 20)),
        WizardNavigation.stay,
      );
    });
  });

  group('ambiente', () {
    test('cada ambiente oferece os seus espaços', () {
      final indoor = WizardMachine()
        ..selectEnvironment(GrowingEnvironment.indoor);
      expect(indoor.environmentPlaces, contains(EnvironmentPlace.room));
      expect(
        indoor.environmentPlaces,
        isNot(contains(EnvironmentPlace.soilGround)),
      );

      final outdoor = WizardMachine()
        ..selectEnvironment(GrowingEnvironment.outdoor);
      expect(outdoor.environmentPlaces, contains(EnvironmentPlace.soilGround));
      expect(outdoor.environmentPlaces, isNot(contains(EnvironmentPlace.room)));

      final mixed = WizardMachine()
        ..selectEnvironment(GrowingEnvironment.mixed);
      expect(mixed.environmentPlaces, EnvironmentPlace.values);
    });

    test('trocar de ambiente descarta o espaço, que era de outra lista', () {
      final machine = WizardMachine()
        ..selectEnvironment(GrowingEnvironment.indoor)
        ..selectEnvironmentPlace(EnvironmentPlace.room);

      machine.selectEnvironment(GrowingEnvironment.outdoor);
      expect(machine.draft.environmentPlace, isNull);
    });

    test('reescolher o mesmo ambiente mantém o espaço', () {
      final machine = WizardMachine()
        ..selectEnvironment(GrowingEnvironment.indoor)
        ..selectEnvironmentPlace(EnvironmentPlace.growTent);

      machine.selectEnvironment(GrowingEnvironment.indoor);
      expect(machine.draft.environmentPlace, EnvironmentPlace.growTent);
    });
  });

  group('data de início', () {
    final today = DateTime(2026, 8, 23);
    final yesterday = DateTime(2026, 8, 22);

    test('sem resposta, nenhum chip fica marcado', () {
      expect(WizardMachine().startDateChoice(today), WizardDateChoice.none);
    });

    test('hoje, ontem e uma data qualquer são chips diferentes', () {
      final machine = WizardMachine();

      machine.setStartDate(today);
      expect(machine.startDateChoice(today), WizardDateChoice.today);

      machine.setStartDate(yesterday);
      expect(machine.startDateChoice(today), WizardDateChoice.yesterday);

      machine.setStartDate(DateTime(2026, 5, 4));
      expect(machine.startDateChoice(today), WizardDateChoice.picked);
    });

    test('a hora não muda o chip: só o dia importa', () {
      final machine = WizardMachine()
        ..setStartDate(DateTime(2026, 8, 23, 21, 14));

      expect(machine.startDateChoice(today), WizardDateChoice.today);
    });

    test('aproximada vence a comparação com hoje', () {
      final machine = WizardMachine()..setStartDate(today, approximate: true);

      expect(machine.startDateChoice(today), WizardDateChoice.approximate);
      expect(machine.draft.startDateIsApproximate, isTrue);
    });

    test('escolher data exata depois de aproximada limpa a marca', () {
      final machine = WizardMachine()..setStartDate(today, approximate: true);

      machine.setStartDate(yesterday);
      expect(machine.draft.startDateIsApproximate, isFalse);
      expect(machine.startDateChoice(today), WizardDateChoice.yesterday);
    });

    test('"não sei" apaga data e aproximação', () {
      final machine = WizardMachine()..setStartDate(today, approximate: true);

      machine.setStartDateUnknown();
      expect(machine.draft.startDate, isNull);
      expect(machine.draft.startDateIsApproximate, isFalse);
      expect(machine.draft.startDateUnknown, isTrue);
      expect(machine.startDateChoice(today), WizardDateChoice.unknown);
    });

    test('responder uma data depois do "não sei" desfaz o "não sei"', () {
      final machine = WizardMachine()..setStartDateUnknown();

      machine.setStartDate(today);
      expect(machine.draft.startDateUnknown, isFalse);
      expect(machine.startDateChoice(today), WizardDateChoice.today);
    });

    test('cada data extra vai para o seu campo e volta', () {
      final machine = WizardMachine();
      final date = DateTime(2026, 7, 15);

      for (final extra in WizardExtraDate.values) {
        expect(machine.extraDate(extra), isNull);
        machine.setExtraDate(extra, date);
        expect(machine.extraDate(extra), date, reason: '$extra');
        machine.setExtraDate(extra, null);
        expect(machine.extraDate(extra), isNull);
      }
    });
  });

  group('identificação', () {
    test('o código local pode ser sorteado de novo', () {
      final machine = WizardMachine();
      final first = machine.draft.privacyCode;

      // Em 31^4 possibilidades, repetir várias vezes seguidas é desprezível.
      var changed = false;
      for (var i = 0; i < 10 && !changed; i++) {
        machine.regeneratePrivacyCode();
        changed = machine.draft.privacyCode != first;
      }

      expect(changed, isTrue);
      expect(
        machine.draft.privacyCode,
        matches(RegExp(r'^GC-[2-9A-HJ-KM-NP-Z]{4}$')),
      );
    });
  });

  group('criação', () {
    test('só o ponto de partida libera o "CRIAR PLANTA"', () {
      final machine = WizardMachine();
      expect(machine.canCreate, isFalse);

      machine.selectStartingPoint(PlantStartingPoint.inProgress);
      expect(machine.canCreate, isTrue);
    });

    test(
      'a fase mostrada é a escolhida, ou a sugerida enquanto não houver',
      () {
        final machine = WizardMachine();
        machine.selectStartingPoint(PlantStartingPoint.seed);
        expect(machine.selectedPhase, PlantPhase.seed);

        machine.selectPhase(PlantPhase.flowering);
        expect(machine.selectedPhase, PlantPhase.flowering);
      },
    );
  });
}
