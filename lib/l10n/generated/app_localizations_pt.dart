// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'GrowCipher';

  @override
  String get actionContinue => 'Continuar';

  @override
  String get actionSkip => 'Pular';

  @override
  String get actionBack => 'Voltar';

  @override
  String get actionSave => 'Salvar';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get dontKnow => 'Não sei';

  @override
  String get optionalTag => 'opcional';

  @override
  String get homeTagline => 'Seu cultivo. Seus dados. Suas decisões.';

  @override
  String get homeEmptyTitle => 'Vamos cadastrar sua planta';

  @override
  String get homeEmptyBody =>
      'Registre sua primeira planta e acompanhe cada etapa do cultivo — tudo offline, só no seu aparelho.';

  @override
  String get addPlant => 'Adicionar planta';

  @override
  String get homePlantsSection => 'Suas plantas';

  @override
  String plantAgeDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String stepProgress(int current, int total) {
    return 'Passo $current de $total';
  }

  @override
  String get wizardTitle => 'Nova planta';

  @override
  String get wizardStartTitle => 'O que você tem agora?';

  @override
  String get startingPointSeed => 'Semente';

  @override
  String get startingPointSeedDesc =>
      'Vou germinar e acompanhar desde o início';

  @override
  String get startingPointSeedling => 'Muda';

  @override
  String get startingPointSeedlingDesc => 'Uma planta jovem, já germinada';

  @override
  String get startingPointClone => 'Clone';

  @override
  String get startingPointCloneDesc => 'Corte tirado de outra planta';

  @override
  String get startingPointInProgress => 'Planta em andamento';

  @override
  String get startingPointInProgressDesc =>
      'Cultivo que já começou e quero registrar aqui';

  @override
  String get wizardIdentityTitle => 'Como você quer identificar a planta?';

  @override
  String get plantNameLabel => 'Nome da planta';

  @override
  String get plantNameHelper => 'Opcional — você pode usar só o código';

  @override
  String get privacyCodeLabel => 'Código local';

  @override
  String get privacyCodeHelper =>
      'Gerado no aparelho, sem identificação nominal.';

  @override
  String get regeneratePrivacyCode => 'Gerar outro código';

  @override
  String get photoLabel => 'Foto';

  @override
  String get photoComingSoon =>
      'A galeria privada chega em uma próxima versão.';

  @override
  String get wizardOriginTitle => 'De onde ela veio?';

  @override
  String get originPurchasedF => 'Comprada';

  @override
  String get originPurchasedM => 'Comprado';

  @override
  String get originOwnProduction => 'Produção própria';

  @override
  String get originGiftOrTrade => 'Presente ou troca';

  @override
  String get originFoundSeed => 'Encontrada em uma flor';

  @override
  String get originReceivedClone => 'Recebido';

  @override
  String get originOtherF => 'Outra';

  @override
  String get originOtherM => 'Outro';

  @override
  String get originDetailsLabel => 'Detalhes da origem';

  @override
  String get originDetailsHelper =>
      'Fornecedor, produtor, lote, referência… (opcional)';

  @override
  String get wizardGeneticsTitle => 'Você conhece a genética?';

  @override
  String get geneticsKnown => 'Sim, eu sei qual é';

  @override
  String get strainLabel => 'Variedade / genética';

  @override
  String get strainHelper => 'Ex.: nome da variedade ou cruzamento';

  @override
  String get geneticTypeQuestion => 'Ela é autoflorescente ou fotoperiódica?';

  @override
  String get geneticTypeAutoflower => 'Autoflorescente';

  @override
  String get geneticTypePhotoperiod => 'Fotoperiódica';

  @override
  String get datesTitleSeed => 'Quando a semente foi plantada?';

  @override
  String get datesTitleSeedling => 'Quando a muda começou?';

  @override
  String get datesTitleClone => 'Quando você recebeu o clone?';

  @override
  String get datesTitleInProgress => 'Quando o cultivo começou, mais ou menos?';

  @override
  String get dateToday => 'Hoje';

  @override
  String get dateYesterday => 'Ontem';

  @override
  String get datePick => 'Escolher data';

  @override
  String get dateApproximate => 'Data aproximada';

  @override
  String get approximateTag => 'aproximada';

  @override
  String get extraDatesLabel => 'Outras datas, se você souber';

  @override
  String get extraDateSeedObtained => 'Data da semente';

  @override
  String get extraDateGermination => 'Data de germinação';

  @override
  String get extraDateRooted => 'Data de enraizamento';

  @override
  String get wizardEnvironmentTitle => 'Onde ela vai crescer?';

  @override
  String get environmentIndoor => 'Indoor';

  @override
  String get environmentOutdoor => 'Outdoor';

  @override
  String get environmentMixed => 'Misto';

  @override
  String get environmentDetailLabel => 'Quer detalhar o espaço?';

  @override
  String get envGrowTent => 'Grow tent';

  @override
  String get envRoom => 'Quarto';

  @override
  String get envGreenhouse => 'Estufa';

  @override
  String get envPot => 'Vaso';

  @override
  String get envSoil => 'Solo';

  @override
  String get envOther => 'Outro';

  @override
  String get environmentNameLabel => 'Nome do espaço';

  @override
  String get environmentNameHelper => 'Ex.: “Tenda 1”, “Quintal” (opcional)';

  @override
  String get wizardMediumTitle => 'Em que meio ela cresce?';

  @override
  String get mediumSoil => 'Solo';

  @override
  String get mediumCoco => 'Coco';

  @override
  String get mediumHydroponic => 'Hidroponia';

  @override
  String get mediumAeroponic => 'Aeroponia';

  @override
  String get mediumOther => 'Outro';

  @override
  String get containerTypeLabel => 'Recipiente';

  @override
  String get containerTypeHelper =>
      'Ex.: vaso de tecido, vaso plástico (opcional)';

  @override
  String get containerVolumeLabel => 'Volume do recipiente (L)';

  @override
  String get containerVolumeHelper => 'Em litros (opcional)';

  @override
  String get wizardPhaseTitle => 'Em que fase ela está?';

  @override
  String get phaseSuggestedHint =>
      'Sugerida a partir da sua primeira resposta — pode mudar.';

  @override
  String get phaseSeed => 'Semente';

  @override
  String get phaseGermination => 'Germinação';

  @override
  String get phaseSeedling => 'Muda';

  @override
  String get phaseVegetative => 'Vegetativo';

  @override
  String get phaseFlowering => 'Floração';

  @override
  String get phaseHarvest => 'Finalização / Colheita';

  @override
  String get wizardIrrigationTitle => 'Como você rega?';

  @override
  String get irrigationManual => 'Manual';

  @override
  String get irrigationAutomatic => 'Automática';

  @override
  String get irrigationMixed => 'As duas';

  @override
  String get irrigationUndefined => 'Ainda não definida';

  @override
  String get irrigationSystemLabel => 'Qual sistema?';

  @override
  String get irrigationDrip => 'Gotejamento';

  @override
  String get irrigationReservoir => 'Reservatório';

  @override
  String get irrigationScheduled => 'Programada';

  @override
  String get reviewTitle => 'Revise sua planta';

  @override
  String get reviewHint => 'Toque em uma seção para voltar e editar.';

  @override
  String get createPlantCta => 'CRIAR PLANTA';

  @override
  String get reviewSectionStart => 'Ponto de partida';

  @override
  String get reviewSectionIdentity => 'Identificação';

  @override
  String get reviewSectionOrigin => 'Origem';

  @override
  String get reviewSectionGenetics => 'Genética';

  @override
  String get reviewSectionDates => 'Datas';

  @override
  String get reviewSectionEnvironment => 'Ambiente';

  @override
  String get reviewSectionMedium => 'Meio de cultivo';

  @override
  String get reviewSectionPhase => 'Fase';

  @override
  String get reviewSectionIrrigation => 'Irrigação';

  @override
  String get successTitle => 'Planta criada';

  @override
  String get successSubtitle =>
      'Tudo salvo no seu aparelho, sem internet e sem conta.';

  @override
  String get registerFirstActivity => 'REGISTRAR PRIMEIRA ATIVIDADE';

  @override
  String get goToPlant => 'IR PARA A PLANTA';

  @override
  String get quickLogTitle => 'O que aconteceu?';

  @override
  String get quickLogWatered => 'Reguei';

  @override
  String get quickLogFed => 'Nutrientes / alimentação';

  @override
  String get quickLogTreatment => 'Tratamento';

  @override
  String get quickLogMeasurement => 'Medição';

  @override
  String get quickLogTransplant => 'Transplante';

  @override
  String get quickLogPhaseChange => 'Mudança de fase';

  @override
  String get quickLogPhoto => 'Foto';

  @override
  String get quickLogPhotoComingSoon => 'Chega com a galeria privada';

  @override
  String get quickLogObservation => 'Observação';

  @override
  String get quickLogProblem => 'Problema';

  @override
  String get quickLogTaskDone => 'Tarefa concluída';

  @override
  String get quickLogHarvest => 'Colheita';

  @override
  String get quickLogEndPlant => 'Encerrar planta';

  @override
  String get eventSaved => 'Registro salvo';

  @override
  String get occurredAtLabel => 'Quando aconteceu?';

  @override
  String get occurredAtNow => 'Agora';

  @override
  String get notesLabel => 'Anotação (opcional)';

  @override
  String get amountLabel => 'Quantidade';

  @override
  String get unitLabel => 'Unidade';

  @override
  String get volumeUnitHelper => 'Ex.: ml, L (opcional)';

  @override
  String get solutionTypeLabel => 'Tipo de solução';

  @override
  String get solutionTypeHelper =>
      'Ex.: água pura, água com nutrientes (opcional)';

  @override
  String get productLabel => 'Produto';

  @override
  String get productHelper => 'Ex.: nome do fertilizante (opcional)';

  @override
  String get treatmentTypeLabel => 'Tipo de tratamento';

  @override
  String get treatmentPestControl => 'Controle de pragas';

  @override
  String get treatmentFungusControl => 'Controle de fungos';

  @override
  String get treatmentGeneric => 'Tratamento geral';

  @override
  String get treatmentCorrection => 'Correção';

  @override
  String get treatmentSupplement => 'Suplemento';

  @override
  String get methodLabel => 'Método';

  @override
  String get methodHelper => 'Ex.: pulverização foliar, rega (opcional)';

  @override
  String get measurementHint => 'Preencha só o que você mediu.';

  @override
  String get measureTemperature => 'Temperatura (°C)';

  @override
  String get measureHumidity => 'Umidade (%)';

  @override
  String get measurePh => 'pH';

  @override
  String get measureEc => 'EC (mS/cm)';

  @override
  String get measureVpd => 'VPD (kPa)';

  @override
  String get measureDli => 'DLI (mol/m²·dia)';

  @override
  String get newPhaseLabel => 'Nova fase';

  @override
  String currentPhaseLabel(String phase) {
    return 'Fase atual: $phase';
  }

  @override
  String phaseTransition(String from, String to) {
    return '$from → $to';
  }

  @override
  String get observationFieldLabel => 'O que você observou?';

  @override
  String get problemCategoryLabel => 'Categoria';

  @override
  String get problemPest => 'Praga';

  @override
  String get problemDisease => 'Doença';

  @override
  String get problemDeficiency => 'Deficiência';

  @override
  String get problemExcess => 'Excesso';

  @override
  String get problemWatering => 'Rega';

  @override
  String get problemTemperature => 'Temperatura';

  @override
  String get problemHumidity => 'Umidade';

  @override
  String get problemLighting => 'Iluminação';

  @override
  String get problemPhysicalDamage => 'Dano físico';

  @override
  String get problemDescriptionLabel => 'Descrição (opcional)';

  @override
  String get taskDescriptionLabel => 'Qual tarefa?';

  @override
  String get wetWeightLabel => 'Peso úmido';

  @override
  String get dryWeightLabel => 'Peso seco';

  @override
  String get weightUnitHelper => 'Ex.: g, kg (opcional)';

  @override
  String get harvestEndsCycle => 'Encerrar o ciclo desta planta';

  @override
  String get harvestEndsCycleHelper =>
      'A planta passa a “Concluída”. O histórico fica guardado.';

  @override
  String get endReasonLabel => 'Por que encerrar?';

  @override
  String get endReasonHarvestCompleted => 'Colheita concluída';

  @override
  String get endReasonDied => 'Morreu';

  @override
  String get endReasonDiscarded => 'Descartada';

  @override
  String get endReasonInterrupted => 'Interrompida';

  @override
  String get endReasonOther => 'Outro motivo';

  @override
  String get endCauseLabel => 'O que causou?';

  @override
  String get causePest => 'Praga';

  @override
  String get causeDisease => 'Doença';

  @override
  String get causeWatering => 'Rega';

  @override
  String get causeNutrition => 'Nutrição';

  @override
  String get causeEnvironment => 'Ambiente';

  @override
  String get causeAccident => 'Acidente';

  @override
  String get endPlantKeepsHistory =>
      'O histórico completo fica guardado. Nada é apagado.';

  @override
  String get timelineTitle => 'Linha do tempo';

  @override
  String get timelineEmpty => 'Nenhum registro ainda.';

  @override
  String get registerActivity => 'Registrar atividade';

  @override
  String get statusActive => 'Ativa';

  @override
  String get statusCompleted => 'Concluída';

  @override
  String get statusDied => 'Morta';

  @override
  String get statusDiscarded => 'Descartada';

  @override
  String get statusInterrupted => 'Interrompida';

  @override
  String get statusArchived => 'Arquivada';

  @override
  String get eventPlantCreated => 'Planta cadastrada';

  @override
  String get eventGerminated => 'Germinação';

  @override
  String get eventWatered => 'Rega';

  @override
  String get eventFed => 'Alimentação';

  @override
  String get eventTreatment => 'Tratamento';

  @override
  String get eventMeasurement => 'Medição';

  @override
  String get eventTransplant => 'Transplante';

  @override
  String get eventPhaseChanged => 'Mudança de fase';

  @override
  String get eventPhotoAdded => 'Foto';

  @override
  String get eventObservation => 'Observação';

  @override
  String get eventProblem => 'Problema';

  @override
  String get eventTaskDone => 'Tarefa concluída';

  @override
  String get eventHarvested => 'Colheita';

  @override
  String get eventPlantEnded => 'Ciclo encerrado';
}
