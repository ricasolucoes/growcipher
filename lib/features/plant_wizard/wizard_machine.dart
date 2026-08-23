/// Máquina de estados do wizard de criação de planta.
///
/// Guarda o passo atual e as respostas ([PlantDraft]), e concentra tudo que
/// decide o que a tela mostra: quais origens são oferecidas, quais datas
/// extras existem, qual pergunta abre o passo de datas, e quais respostas
/// avançam sozinhas para o próximo passo.
///
/// Os quatro caminhos de entrada — semente, muda, clone e cultivo em
/// andamento — vivem aqui como transições explícitas, não como condicionais
/// espalhadas pela interface.
///
/// Nada neste arquivo importa Flutter: a navegação do wizard pode ser testada
/// sem subir uma árvore de widgets.
library;

import '../../domain/identifiers.dart';
import '../../domain/models/plant_draft.dart';
import '../../domain/models/plant_enums.dart';

/// Passos do wizard, na ordem fixa em que aparecem.
enum WizardStep {
  start,
  identity,
  origin,
  genetics,
  dates,
  environment,
  medium,
  phase,
  irrigation,
  review,
}

/// A pergunta que abre o passo de datas, escolhida pelo ponto de partida.
enum WizardDatesQuestion { seed, seedling, clone, inProgress }

/// Data adicional oferecida no passo de datas. Cada caminho de entrada tem
/// as suas: semente ganha obtenção e germinação, clone ganha enraizamento.
enum WizardExtraDate { seedObtained, germination, rooted }

/// Como a data de início foi respondida — controla qual chip fica marcado.
enum WizardDateChoice { none, today, yesterday, picked, approximate, unknown }

/// O que a tela faz depois de uma transição: fica no passo ou avança.
///
/// Algumas respostas encerram o passo sozinhas (escolher o ponto de partida,
/// dizer que não conhece a genética, regar na mão); as demais esperam o
/// "Continuar".
enum WizardNavigation { stay, advance }

class WizardMachine {
  WizardMachine({PlantDraft? draft}) : draft = draft ?? PlantDraft();

  static const List<WizardStep> steps = WizardStep.values;

  /// Respostas em memória. Nada é persistido antes do "CRIAR PLANTA".
  final PlantDraft draft;

  int _index = 0;

  int get index => _index;

  WizardStep get step => steps[_index];

  int indexOf(WizardStep step) => steps.indexOf(step);

  /// Sincroniza com a página realmente exibida (a animação do `PageView`
  /// termina depois da transição que a pediu).
  void syncToPage(int index) => _index = index;

  // --- navegação ---

  /// Índice do próximo passo, ou `null` se este já é o último.
  int? get nextIndex => _index < steps.length - 1 ? _index + 1 : null;

  /// Índice do passo anterior, ou `null` quando "voltar" significa fechar o
  /// wizard.
  int? get previousIndex => _index > 0 ? _index - 1 : null;

  /// No primeiro passo o gesto de voltar do sistema fecha a tela.
  bool get canPop => _index == 0;

  /// A barra inferior não aparece no primeiro passo (a escolha já avança)
  /// nem na revisão (que tem o próprio botão).
  bool get showsBottomBar =>
      step != WizardStep.start && step != WizardStep.review;

  /// Numerador do rótulo "passo X de Y". A revisão não conta como pergunta.
  int get questionNumber => _index + 1;

  int get questionCount => steps.length - 1;

  /// Barra de progresso do topo, essa sim incluindo a revisão.
  double get progress => (_index + 1) / steps.length;

  /// O passo atual já foi respondido? Só isso decide a exibição do "Pular".
  bool get currentStepHasAnswer => switch (step) {
    WizardStep.origin => draft.origin != null,
    WizardStep.genetics => draft.knowsGenetics != null,
    WizardStep.dates => draft.startDate != null || draft.startDateUnknown,
    WizardStep.environment => draft.environment != null,
    WizardStep.medium => draft.growingMedium != null,
    WizardStep.irrigation => draft.irrigationMode != null,
    // Identificação sempre tem o código; fase sempre tem sugestão.
    _ => true,
  };

  bool get canCreate => draft.canCreate;

  // --- caminhos de entrada ---

  /// Origens oferecidas no passo 3. Semente pode ter sido encontrada numa
  /// flor; clone pode ter sido recebido — e nenhuma das duas faz sentido no
  /// lugar da outra.
  List<PlantOrigin> get originOptions => switch (draft.startingPoint) {
    PlantStartingPoint.seed => const [
      PlantOrigin.purchased,
      PlantOrigin.ownProduction,
      PlantOrigin.giftOrTrade,
      PlantOrigin.foundSeed,
      PlantOrigin.other,
      PlantOrigin.unknown,
    ],
    PlantStartingPoint.clone => const [
      PlantOrigin.ownProduction,
      PlantOrigin.receivedClone,
      PlantOrigin.purchased,
      PlantOrigin.other,
      PlantOrigin.unknown,
    ],
    _ => const [
      PlantOrigin.purchased,
      PlantOrigin.ownProduction,
      PlantOrigin.giftOrTrade,
      PlantOrigin.other,
      PlantOrigin.unknown,
    ],
  };

  /// Pergunta do passo de datas ("Quando a semente foi plantada?", "Quando
  /// você recebeu o clone?"…).
  WizardDatesQuestion get datesQuestion => switch (draft.startingPoint) {
    PlantStartingPoint.seed => WizardDatesQuestion.seed,
    PlantStartingPoint.seedling => WizardDatesQuestion.seedling,
    PlantStartingPoint.clone => WizardDatesQuestion.clone,
    PlantStartingPoint.inProgress || null => WizardDatesQuestion.inProgress,
  };

  /// Datas extras do passo 5. Clone não germina; semente não enraíza.
  List<WizardExtraDate> get extraDates => switch (draft.startingPoint) {
    PlantStartingPoint.seed => const [
      WizardExtraDate.seedObtained,
      WizardExtraDate.germination,
    ],
    PlantStartingPoint.seedling => const [WizardExtraDate.germination],
    PlantStartingPoint.clone => const [WizardExtraDate.rooted],
    PlantStartingPoint.inProgress || null => const [],
  };

  /// Espaços oferecidos no detalhe do ambiente. Indoor não tem "no solo";
  /// outdoor não tem "quarto".
  List<EnvironmentPlace> get environmentPlaces => switch (draft.environment) {
    GrowingEnvironment.indoor => const [
      EnvironmentPlace.growTent,
      EnvironmentPlace.room,
      EnvironmentPlace.greenhouse,
      EnvironmentPlace.other,
    ],
    GrowingEnvironment.outdoor => const [
      EnvironmentPlace.pot,
      EnvironmentPlace.soilGround,
      EnvironmentPlace.greenhouse,
      EnvironmentPlace.other,
    ],
    _ => EnvironmentPlace.values,
  };

  /// Fase marcada no passo 8: a escolhida ou, enquanto não houver escolha, a
  /// sugerida pelo ponto de partida.
  PlantPhase get selectedPhase => draft.phase ?? draft.suggestedPhase;

  // --- transições ---

  /// Passo 1. Trocar o ponto de partida invalida as respostas que dependem
  /// dele: a origem escolhida some da lista, as datas extras deixam de
  /// existir e a fase sugerida muda.
  WizardNavigation selectStartingPoint(PlantStartingPoint value) {
    if (draft.startingPoint != value) {
      draft.startingPoint = value;
      draft.origin = null;
      draft.originDetails = null;
      draft.seedObtainedDate = null;
      draft.germinationDate = null;
      draft.rootedDate = null;
      draft.phase = null;
    }
    return WizardNavigation.advance;
  }

  /// Passo 2. Sorteia outro código local quando o atual não agrada.
  WizardNavigation regeneratePrivacyCode() {
    draft.privacyCode = generatePrivacyCode();
    return WizardNavigation.stay;
  }

  WizardNavigation selectOrigin(PlantOrigin value) {
    draft.origin = value;
    return WizardNavigation.stay;
  }

  /// Passo 4. "Não sei" encerra o passo; "conheço" abre os campos abaixo.
  WizardNavigation answerGenetics(bool knows) {
    draft.knowsGenetics = knows;
    return knows ? WizardNavigation.stay : WizardNavigation.advance;
  }

  WizardNavigation selectGeneticType(PlantGeneticType value) {
    draft.geneticType = value;
    return WizardNavigation.stay;
  }

  /// Passo 5. Data exata escolhida ("Hoje", "Ontem" ou no calendário).
  WizardNavigation setStartDate(DateTime date, {bool approximate = false}) {
    draft.startDate = date;
    draft.startDateIsApproximate = approximate;
    draft.startDateUnknown = false;
    return WizardNavigation.stay;
  }

  /// "Não sei" é resposta, não ausência de resposta: limpa a data e a marca
  /// de aproximada para não sobrar sujeira de uma escolha anterior.
  WizardNavigation setStartDateUnknown() {
    draft.startDate = null;
    draft.startDateIsApproximate = false;
    draft.startDateUnknown = true;
    return WizardNavigation.stay;
  }

  /// Qual chip do passo de datas está marcado, dado o dia de hoje (sem hora).
  WizardDateChoice startDateChoice(DateTime today) {
    if (draft.startDateUnknown) return WizardDateChoice.unknown;
    final date = draft.startDate;
    if (date == null) return WizardDateChoice.none;
    if (draft.startDateIsApproximate) return WizardDateChoice.approximate;
    if (_isSameDay(date, today)) return WizardDateChoice.today;
    if (_isSameDay(date, today.subtract(const Duration(days: 1)))) {
      return WizardDateChoice.yesterday;
    }
    return WizardDateChoice.picked;
  }

  DateTime? extraDate(WizardExtraDate which) => switch (which) {
    WizardExtraDate.seedObtained => draft.seedObtainedDate,
    WizardExtraDate.germination => draft.germinationDate,
    WizardExtraDate.rooted => draft.rootedDate,
  };

  WizardNavigation setExtraDate(WizardExtraDate which, DateTime? value) {
    switch (which) {
      case WizardExtraDate.seedObtained:
        draft.seedObtainedDate = value;
      case WizardExtraDate.germination:
        draft.germinationDate = value;
      case WizardExtraDate.rooted:
        draft.rootedDate = value;
    }
    return WizardNavigation.stay;
  }

  /// Passo 6. Trocar de ambiente descarta o espaço, que é uma lista própria
  /// de cada ambiente.
  WizardNavigation selectEnvironment(GrowingEnvironment value) {
    if (draft.environment != value) {
      draft.environment = value;
      draft.environmentPlace = null;
    }
    return WizardNavigation.stay;
  }

  WizardNavigation selectEnvironmentPlace(EnvironmentPlace? value) {
    draft.environmentPlace = value;
    return WizardNavigation.stay;
  }

  WizardNavigation selectMedium(GrowingMedium value) {
    draft.growingMedium = value;
    return WizardNavigation.stay;
  }

  WizardNavigation selectPhase(PlantPhase value) {
    draft.phase = value;
    return WizardNavigation.stay;
  }

  /// Passo 9. Rega manual (ou indefinida) não tem sistema para escolher, e
  /// por isso encerra o passo sozinha.
  WizardNavigation selectIrrigationMode(IrrigationMode value) {
    draft.irrigationMode = value;
    final withoutSystem =
        value == IrrigationMode.manual || value == IrrigationMode.undefined;
    if (withoutSystem) draft.irrigationSystem = null;
    return withoutSystem ? WizardNavigation.advance : WizardNavigation.stay;
  }

  WizardNavigation selectIrrigationSystem(IrrigationSystem? value) {
    draft.irrigationSystem = value;
    return WizardNavigation.stay;
  }

  static bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
