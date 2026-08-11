import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'GrowCipher'**
  String get appTitle;

  /// No description provided for @actionContinue.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get actionContinue;

  /// No description provided for @actionSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get actionSkip;

  /// No description provided for @actionBack.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get actionBack;

  /// No description provided for @actionSave.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get actionSave;

  /// No description provided for @actionCancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get actionCancel;

  /// No description provided for @actionEdit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get actionEdit;

  /// No description provided for @dontKnow.
  ///
  /// In pt, this message translates to:
  /// **'Não sei'**
  String get dontKnow;

  /// No description provided for @optionalTag.
  ///
  /// In pt, this message translates to:
  /// **'opcional'**
  String get optionalTag;

  /// No description provided for @notInformed.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get notInformed;

  /// No description provided for @homeTagline.
  ///
  /// In pt, this message translates to:
  /// **'Seu cultivo. Seus dados. Suas decisões.'**
  String get homeTagline;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Vamos cadastrar sua planta'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptyBody.
  ///
  /// In pt, this message translates to:
  /// **'Registre sua primeira planta e acompanhe cada etapa do cultivo — tudo offline, só no seu aparelho.'**
  String get homeEmptyBody;

  /// No description provided for @addPlant.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar planta'**
  String get addPlant;

  /// No description provided for @homePlantsSection.
  ///
  /// In pt, this message translates to:
  /// **'Suas plantas'**
  String get homePlantsSection;

  /// No description provided for @plantAgeDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 dia} other{{count} dias}}'**
  String plantAgeDays(int count);

  /// No description provided for @stepProgress.
  ///
  /// In pt, this message translates to:
  /// **'Passo {current} de {total}'**
  String stepProgress(int current, int total);

  /// No description provided for @wizardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova planta'**
  String get wizardTitle;

  /// No description provided for @wizardStartTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que você tem agora?'**
  String get wizardStartTitle;

  /// No description provided for @startingPointSeed.
  ///
  /// In pt, this message translates to:
  /// **'Semente'**
  String get startingPointSeed;

  /// No description provided for @startingPointSeedDesc.
  ///
  /// In pt, this message translates to:
  /// **'Vou germinar e acompanhar desde o início'**
  String get startingPointSeedDesc;

  /// No description provided for @startingPointSeedling.
  ///
  /// In pt, this message translates to:
  /// **'Muda'**
  String get startingPointSeedling;

  /// No description provided for @startingPointSeedlingDesc.
  ///
  /// In pt, this message translates to:
  /// **'Uma planta jovem, já germinada'**
  String get startingPointSeedlingDesc;

  /// No description provided for @startingPointClone.
  ///
  /// In pt, this message translates to:
  /// **'Clone'**
  String get startingPointClone;

  /// No description provided for @startingPointCloneDesc.
  ///
  /// In pt, this message translates to:
  /// **'Corte tirado de outra planta'**
  String get startingPointCloneDesc;

  /// No description provided for @startingPointInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Planta em andamento'**
  String get startingPointInProgress;

  /// No description provided for @startingPointInProgressDesc.
  ///
  /// In pt, this message translates to:
  /// **'Cultivo que já começou e quero registrar aqui'**
  String get startingPointInProgressDesc;

  /// No description provided for @wizardIdentityTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como você quer identificar a planta?'**
  String get wizardIdentityTitle;

  /// No description provided for @plantNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome da planta'**
  String get plantNameLabel;

  /// No description provided for @plantNameHelper.
  ///
  /// In pt, this message translates to:
  /// **'Opcional — você pode usar só o código'**
  String get plantNameHelper;

  /// No description provided for @privacyCodeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Código local'**
  String get privacyCodeLabel;

  /// No description provided for @privacyCodeHelper.
  ///
  /// In pt, this message translates to:
  /// **'Gerado no aparelho, sem identificação nominal.'**
  String get privacyCodeHelper;

  /// No description provided for @regeneratePrivacyCode.
  ///
  /// In pt, this message translates to:
  /// **'Gerar outro código'**
  String get regeneratePrivacyCode;

  /// No description provided for @photoLabel.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get photoLabel;

  /// No description provided for @photoComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'A galeria privada chega em uma próxima versão.'**
  String get photoComingSoon;

  /// No description provided for @wizardOriginTitle.
  ///
  /// In pt, this message translates to:
  /// **'De onde ela veio?'**
  String get wizardOriginTitle;

  /// No description provided for @originPurchasedF.
  ///
  /// In pt, this message translates to:
  /// **'Comprada'**
  String get originPurchasedF;

  /// No description provided for @originPurchasedM.
  ///
  /// In pt, this message translates to:
  /// **'Comprado'**
  String get originPurchasedM;

  /// No description provided for @originOwnProduction.
  ///
  /// In pt, this message translates to:
  /// **'Produção própria'**
  String get originOwnProduction;

  /// No description provided for @originGiftOrTrade.
  ///
  /// In pt, this message translates to:
  /// **'Presente ou troca'**
  String get originGiftOrTrade;

  /// No description provided for @originFoundSeed.
  ///
  /// In pt, this message translates to:
  /// **'Encontrada em uma flor'**
  String get originFoundSeed;

  /// No description provided for @originReceivedClone.
  ///
  /// In pt, this message translates to:
  /// **'Recebido'**
  String get originReceivedClone;

  /// No description provided for @originOtherF.
  ///
  /// In pt, this message translates to:
  /// **'Outra'**
  String get originOtherF;

  /// No description provided for @originOtherM.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get originOtherM;

  /// No description provided for @originDetailsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes da origem'**
  String get originDetailsLabel;

  /// No description provided for @originDetailsHelper.
  ///
  /// In pt, this message translates to:
  /// **'Fornecedor, produtor, lote, referência… (opcional)'**
  String get originDetailsHelper;

  /// No description provided for @wizardGeneticsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você conhece a genética?'**
  String get wizardGeneticsTitle;

  /// No description provided for @geneticsKnown.
  ///
  /// In pt, this message translates to:
  /// **'Sim, eu sei qual é'**
  String get geneticsKnown;

  /// No description provided for @strainLabel.
  ///
  /// In pt, this message translates to:
  /// **'Variedade / genética'**
  String get strainLabel;

  /// No description provided for @strainHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: nome da variedade ou cruzamento'**
  String get strainHelper;

  /// No description provided for @geneticTypeQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Ela é autoflorescente ou fotoperiódica?'**
  String get geneticTypeQuestion;

  /// No description provided for @geneticTypeAutoflower.
  ///
  /// In pt, this message translates to:
  /// **'Autoflorescente'**
  String get geneticTypeAutoflower;

  /// No description provided for @geneticTypePhotoperiod.
  ///
  /// In pt, this message translates to:
  /// **'Fotoperiódica'**
  String get geneticTypePhotoperiod;

  /// No description provided for @datesTitleSeed.
  ///
  /// In pt, this message translates to:
  /// **'Quando a semente foi plantada?'**
  String get datesTitleSeed;

  /// No description provided for @datesTitleSeedling.
  ///
  /// In pt, this message translates to:
  /// **'Quando a muda começou?'**
  String get datesTitleSeedling;

  /// No description provided for @datesTitleClone.
  ///
  /// In pt, this message translates to:
  /// **'Quando você recebeu o clone?'**
  String get datesTitleClone;

  /// No description provided for @datesTitleInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Quando o cultivo começou, mais ou menos?'**
  String get datesTitleInProgress;

  /// No description provided for @dateToday.
  ///
  /// In pt, this message translates to:
  /// **'Hoje'**
  String get dateToday;

  /// No description provided for @dateYesterday.
  ///
  /// In pt, this message translates to:
  /// **'Ontem'**
  String get dateYesterday;

  /// No description provided for @datePick.
  ///
  /// In pt, this message translates to:
  /// **'Escolher data'**
  String get datePick;

  /// No description provided for @dateApproximate.
  ///
  /// In pt, this message translates to:
  /// **'Data aproximada'**
  String get dateApproximate;

  /// No description provided for @approximateTag.
  ///
  /// In pt, this message translates to:
  /// **'aproximada'**
  String get approximateTag;

  /// No description provided for @extraDatesLabel.
  ///
  /// In pt, this message translates to:
  /// **'Outras datas, se você souber'**
  String get extraDatesLabel;

  /// No description provided for @extraDateSeedObtained.
  ///
  /// In pt, this message translates to:
  /// **'Data da semente'**
  String get extraDateSeedObtained;

  /// No description provided for @extraDateGermination.
  ///
  /// In pt, this message translates to:
  /// **'Data de germinação'**
  String get extraDateGermination;

  /// No description provided for @extraDateRooted.
  ///
  /// In pt, this message translates to:
  /// **'Data de enraizamento'**
  String get extraDateRooted;

  /// No description provided for @wizardEnvironmentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Onde ela vai crescer?'**
  String get wizardEnvironmentTitle;

  /// No description provided for @environmentIndoor.
  ///
  /// In pt, this message translates to:
  /// **'Indoor'**
  String get environmentIndoor;

  /// No description provided for @environmentOutdoor.
  ///
  /// In pt, this message translates to:
  /// **'Outdoor'**
  String get environmentOutdoor;

  /// No description provided for @environmentMixed.
  ///
  /// In pt, this message translates to:
  /// **'Misto'**
  String get environmentMixed;

  /// No description provided for @environmentDetailLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quer detalhar o espaço?'**
  String get environmentDetailLabel;

  /// No description provided for @envGrowTent.
  ///
  /// In pt, this message translates to:
  /// **'Grow tent'**
  String get envGrowTent;

  /// No description provided for @envRoom.
  ///
  /// In pt, this message translates to:
  /// **'Quarto'**
  String get envRoom;

  /// No description provided for @envGreenhouse.
  ///
  /// In pt, this message translates to:
  /// **'Estufa'**
  String get envGreenhouse;

  /// No description provided for @envPot.
  ///
  /// In pt, this message translates to:
  /// **'Vaso'**
  String get envPot;

  /// No description provided for @envSoil.
  ///
  /// In pt, this message translates to:
  /// **'Solo'**
  String get envSoil;

  /// No description provided for @envOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get envOther;

  /// No description provided for @environmentNameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome do espaço'**
  String get environmentNameLabel;

  /// No description provided for @environmentNameHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: “Tenda 1”, “Quintal” (opcional)'**
  String get environmentNameHelper;

  /// No description provided for @wizardMediumTitle.
  ///
  /// In pt, this message translates to:
  /// **'Em que meio ela cresce?'**
  String get wizardMediumTitle;

  /// No description provided for @mediumSoil.
  ///
  /// In pt, this message translates to:
  /// **'Solo'**
  String get mediumSoil;

  /// No description provided for @mediumCoco.
  ///
  /// In pt, this message translates to:
  /// **'Coco'**
  String get mediumCoco;

  /// No description provided for @mediumHydroponic.
  ///
  /// In pt, this message translates to:
  /// **'Hidroponia'**
  String get mediumHydroponic;

  /// No description provided for @mediumAeroponic.
  ///
  /// In pt, this message translates to:
  /// **'Aeroponia'**
  String get mediumAeroponic;

  /// No description provided for @mediumOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get mediumOther;

  /// No description provided for @containerTypeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Recipiente'**
  String get containerTypeLabel;

  /// No description provided for @containerTypeHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: vaso de tecido, vaso plástico (opcional)'**
  String get containerTypeHelper;

  /// No description provided for @containerVolumeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Volume do recipiente (L)'**
  String get containerVolumeLabel;

  /// No description provided for @containerVolumeHelper.
  ///
  /// In pt, this message translates to:
  /// **'Em litros (opcional)'**
  String get containerVolumeHelper;

  /// No description provided for @wizardPhaseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Em que fase ela está?'**
  String get wizardPhaseTitle;

  /// No description provided for @phaseSuggestedHint.
  ///
  /// In pt, this message translates to:
  /// **'Sugerida a partir da sua primeira resposta — pode mudar.'**
  String get phaseSuggestedHint;

  /// No description provided for @phaseSeed.
  ///
  /// In pt, this message translates to:
  /// **'Semente'**
  String get phaseSeed;

  /// No description provided for @phaseGermination.
  ///
  /// In pt, this message translates to:
  /// **'Germinação'**
  String get phaseGermination;

  /// No description provided for @phaseSeedling.
  ///
  /// In pt, this message translates to:
  /// **'Muda'**
  String get phaseSeedling;

  /// No description provided for @phaseVegetative.
  ///
  /// In pt, this message translates to:
  /// **'Vegetativo'**
  String get phaseVegetative;

  /// No description provided for @phaseFlowering.
  ///
  /// In pt, this message translates to:
  /// **'Floração'**
  String get phaseFlowering;

  /// No description provided for @phaseHarvest.
  ///
  /// In pt, this message translates to:
  /// **'Finalização / Colheita'**
  String get phaseHarvest;

  /// No description provided for @wizardIrrigationTitle.
  ///
  /// In pt, this message translates to:
  /// **'Como você rega?'**
  String get wizardIrrigationTitle;

  /// No description provided for @irrigationManual.
  ///
  /// In pt, this message translates to:
  /// **'Manual'**
  String get irrigationManual;

  /// No description provided for @irrigationAutomatic.
  ///
  /// In pt, this message translates to:
  /// **'Automática'**
  String get irrigationAutomatic;

  /// No description provided for @irrigationMixed.
  ///
  /// In pt, this message translates to:
  /// **'As duas'**
  String get irrigationMixed;

  /// No description provided for @irrigationUndefined.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não definida'**
  String get irrigationUndefined;

  /// No description provided for @irrigationSystemLabel.
  ///
  /// In pt, this message translates to:
  /// **'Qual sistema?'**
  String get irrigationSystemLabel;

  /// No description provided for @irrigationDrip.
  ///
  /// In pt, this message translates to:
  /// **'Gotejamento'**
  String get irrigationDrip;

  /// No description provided for @irrigationReservoir.
  ///
  /// In pt, this message translates to:
  /// **'Reservatório'**
  String get irrigationReservoir;

  /// No description provided for @irrigationScheduled.
  ///
  /// In pt, this message translates to:
  /// **'Programada'**
  String get irrigationScheduled;

  /// No description provided for @reviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Revise sua planta'**
  String get reviewTitle;

  /// No description provided for @reviewHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em uma seção para voltar e editar.'**
  String get reviewHint;

  /// No description provided for @createPlantCta.
  ///
  /// In pt, this message translates to:
  /// **'CRIAR PLANTA'**
  String get createPlantCta;

  /// No description provided for @reviewSectionStart.
  ///
  /// In pt, this message translates to:
  /// **'Ponto de partida'**
  String get reviewSectionStart;

  /// No description provided for @reviewSectionIdentity.
  ///
  /// In pt, this message translates to:
  /// **'Identificação'**
  String get reviewSectionIdentity;

  /// No description provided for @reviewSectionOrigin.
  ///
  /// In pt, this message translates to:
  /// **'Origem'**
  String get reviewSectionOrigin;

  /// No description provided for @reviewSectionGenetics.
  ///
  /// In pt, this message translates to:
  /// **'Genética'**
  String get reviewSectionGenetics;

  /// No description provided for @reviewSectionDates.
  ///
  /// In pt, this message translates to:
  /// **'Datas'**
  String get reviewSectionDates;

  /// No description provided for @reviewSectionEnvironment.
  ///
  /// In pt, this message translates to:
  /// **'Ambiente'**
  String get reviewSectionEnvironment;

  /// No description provided for @reviewSectionMedium.
  ///
  /// In pt, this message translates to:
  /// **'Meio de cultivo'**
  String get reviewSectionMedium;

  /// No description provided for @reviewSectionPhase.
  ///
  /// In pt, this message translates to:
  /// **'Fase'**
  String get reviewSectionPhase;

  /// No description provided for @reviewSectionIrrigation.
  ///
  /// In pt, this message translates to:
  /// **'Irrigação'**
  String get reviewSectionIrrigation;

  /// No description provided for @successTitle.
  ///
  /// In pt, this message translates to:
  /// **'Planta criada'**
  String get successTitle;

  /// No description provided for @successSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Tudo salvo no seu aparelho, sem internet e sem conta.'**
  String get successSubtitle;

  /// No description provided for @registerFirstActivity.
  ///
  /// In pt, this message translates to:
  /// **'REGISTRAR PRIMEIRA ATIVIDADE'**
  String get registerFirstActivity;

  /// No description provided for @goToPlant.
  ///
  /// In pt, this message translates to:
  /// **'IR PARA A PLANTA'**
  String get goToPlant;

  /// No description provided for @quickLogTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que aconteceu?'**
  String get quickLogTitle;

  /// No description provided for @quickLogWatered.
  ///
  /// In pt, this message translates to:
  /// **'Reguei'**
  String get quickLogWatered;

  /// No description provided for @quickLogFed.
  ///
  /// In pt, this message translates to:
  /// **'Nutrientes / alimentação'**
  String get quickLogFed;

  /// No description provided for @quickLogTreatment.
  ///
  /// In pt, this message translates to:
  /// **'Tratamento'**
  String get quickLogTreatment;

  /// No description provided for @quickLogMeasurement.
  ///
  /// In pt, this message translates to:
  /// **'Medição'**
  String get quickLogMeasurement;

  /// No description provided for @quickLogTransplant.
  ///
  /// In pt, this message translates to:
  /// **'Transplante'**
  String get quickLogTransplant;

  /// No description provided for @quickLogPhaseChange.
  ///
  /// In pt, this message translates to:
  /// **'Mudança de fase'**
  String get quickLogPhaseChange;

  /// No description provided for @quickLogPhoto.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get quickLogPhoto;

  /// No description provided for @quickLogPhotoComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Chega com a galeria privada'**
  String get quickLogPhotoComingSoon;

  /// No description provided for @quickLogObservation.
  ///
  /// In pt, this message translates to:
  /// **'Observação'**
  String get quickLogObservation;

  /// No description provided for @quickLogProblem.
  ///
  /// In pt, this message translates to:
  /// **'Problema'**
  String get quickLogProblem;

  /// No description provided for @quickLogTaskDone.
  ///
  /// In pt, this message translates to:
  /// **'Tarefa concluída'**
  String get quickLogTaskDone;

  /// No description provided for @quickLogHarvest.
  ///
  /// In pt, this message translates to:
  /// **'Colheita'**
  String get quickLogHarvest;

  /// No description provided for @quickLogEndPlant.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar planta'**
  String get quickLogEndPlant;

  /// No description provided for @eventSaved.
  ///
  /// In pt, this message translates to:
  /// **'Registro salvo'**
  String get eventSaved;

  /// No description provided for @occurredAtLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quando aconteceu?'**
  String get occurredAtLabel;

  /// No description provided for @occurredAtNow.
  ///
  /// In pt, this message translates to:
  /// **'Agora'**
  String get occurredAtNow;

  /// No description provided for @notesLabel.
  ///
  /// In pt, this message translates to:
  /// **'Anotação (opcional)'**
  String get notesLabel;

  /// No description provided for @amountLabel.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade'**
  String get amountLabel;

  /// No description provided for @unitLabel.
  ///
  /// In pt, this message translates to:
  /// **'Unidade'**
  String get unitLabel;

  /// No description provided for @volumeUnitHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: ml, L (opcional)'**
  String get volumeUnitHelper;

  /// No description provided for @solutionTypeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de solução'**
  String get solutionTypeLabel;

  /// No description provided for @solutionTypeHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: água pura, água com nutrientes (opcional)'**
  String get solutionTypeHelper;

  /// No description provided for @productLabel.
  ///
  /// In pt, this message translates to:
  /// **'Produto'**
  String get productLabel;

  /// No description provided for @productHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: nome do fertilizante (opcional)'**
  String get productHelper;

  /// No description provided for @treatmentTypeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de tratamento'**
  String get treatmentTypeLabel;

  /// No description provided for @treatmentPestControl.
  ///
  /// In pt, this message translates to:
  /// **'Controle de pragas'**
  String get treatmentPestControl;

  /// No description provided for @treatmentFungusControl.
  ///
  /// In pt, this message translates to:
  /// **'Controle de fungos'**
  String get treatmentFungusControl;

  /// No description provided for @treatmentGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Tratamento geral'**
  String get treatmentGeneric;

  /// No description provided for @treatmentCorrection.
  ///
  /// In pt, this message translates to:
  /// **'Correção'**
  String get treatmentCorrection;

  /// No description provided for @treatmentSupplement.
  ///
  /// In pt, this message translates to:
  /// **'Suplemento'**
  String get treatmentSupplement;

  /// No description provided for @methodLabel.
  ///
  /// In pt, this message translates to:
  /// **'Método'**
  String get methodLabel;

  /// No description provided for @methodHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: pulverização foliar, rega (opcional)'**
  String get methodHelper;

  /// No description provided for @measurementHint.
  ///
  /// In pt, this message translates to:
  /// **'Preencha só o que você mediu.'**
  String get measurementHint;

  /// No description provided for @measureTemperature.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura (°C)'**
  String get measureTemperature;

  /// No description provided for @measureHumidity.
  ///
  /// In pt, this message translates to:
  /// **'Umidade (%)'**
  String get measureHumidity;

  /// No description provided for @measurePh.
  ///
  /// In pt, this message translates to:
  /// **'pH'**
  String get measurePh;

  /// No description provided for @measureEc.
  ///
  /// In pt, this message translates to:
  /// **'EC (mS/cm)'**
  String get measureEc;

  /// No description provided for @measureVpd.
  ///
  /// In pt, this message translates to:
  /// **'VPD (kPa)'**
  String get measureVpd;

  /// No description provided for @measureDli.
  ///
  /// In pt, this message translates to:
  /// **'DLI (mol/m²·dia)'**
  String get measureDli;

  /// No description provided for @newPhaseLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nova fase'**
  String get newPhaseLabel;

  /// No description provided for @currentPhaseLabel.
  ///
  /// In pt, this message translates to:
  /// **'Fase atual: {phase}'**
  String currentPhaseLabel(String phase);

  /// No description provided for @phaseTransition.
  ///
  /// In pt, this message translates to:
  /// **'{from} → {to}'**
  String phaseTransition(String from, String to);

  /// No description provided for @observationFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'O que você observou?'**
  String get observationFieldLabel;

  /// No description provided for @problemCategoryLabel.
  ///
  /// In pt, this message translates to:
  /// **'Categoria'**
  String get problemCategoryLabel;

  /// No description provided for @problemPest.
  ///
  /// In pt, this message translates to:
  /// **'Praga'**
  String get problemPest;

  /// No description provided for @problemDisease.
  ///
  /// In pt, this message translates to:
  /// **'Doença'**
  String get problemDisease;

  /// No description provided for @problemDeficiency.
  ///
  /// In pt, this message translates to:
  /// **'Deficiência'**
  String get problemDeficiency;

  /// No description provided for @problemExcess.
  ///
  /// In pt, this message translates to:
  /// **'Excesso'**
  String get problemExcess;

  /// No description provided for @problemWatering.
  ///
  /// In pt, this message translates to:
  /// **'Rega'**
  String get problemWatering;

  /// No description provided for @problemTemperature.
  ///
  /// In pt, this message translates to:
  /// **'Temperatura'**
  String get problemTemperature;

  /// No description provided for @problemHumidity.
  ///
  /// In pt, this message translates to:
  /// **'Umidade'**
  String get problemHumidity;

  /// No description provided for @problemLighting.
  ///
  /// In pt, this message translates to:
  /// **'Iluminação'**
  String get problemLighting;

  /// No description provided for @problemPhysicalDamage.
  ///
  /// In pt, this message translates to:
  /// **'Dano físico'**
  String get problemPhysicalDamage;

  /// No description provided for @problemDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Descrição (opcional)'**
  String get problemDescriptionLabel;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Qual tarefa?'**
  String get taskDescriptionLabel;

  /// No description provided for @wetWeightLabel.
  ///
  /// In pt, this message translates to:
  /// **'Peso úmido'**
  String get wetWeightLabel;

  /// No description provided for @dryWeightLabel.
  ///
  /// In pt, this message translates to:
  /// **'Peso seco'**
  String get dryWeightLabel;

  /// No description provided for @weightUnitHelper.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: g, kg (opcional)'**
  String get weightUnitHelper;

  /// No description provided for @harvestEndsCycle.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar o ciclo desta planta'**
  String get harvestEndsCycle;

  /// No description provided for @harvestEndsCycleHelper.
  ///
  /// In pt, this message translates to:
  /// **'A planta passa a “Concluída”. O histórico fica guardado.'**
  String get harvestEndsCycleHelper;

  /// No description provided for @endReasonLabel.
  ///
  /// In pt, this message translates to:
  /// **'Por que encerrar?'**
  String get endReasonLabel;

  /// No description provided for @endReasonHarvestCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Colheita concluída'**
  String get endReasonHarvestCompleted;

  /// No description provided for @endReasonDied.
  ///
  /// In pt, this message translates to:
  /// **'Morreu'**
  String get endReasonDied;

  /// No description provided for @endReasonDiscarded.
  ///
  /// In pt, this message translates to:
  /// **'Descartada'**
  String get endReasonDiscarded;

  /// No description provided for @endReasonInterrupted.
  ///
  /// In pt, this message translates to:
  /// **'Interrompida'**
  String get endReasonInterrupted;

  /// No description provided for @endReasonOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro motivo'**
  String get endReasonOther;

  /// No description provided for @endCauseLabel.
  ///
  /// In pt, this message translates to:
  /// **'O que causou?'**
  String get endCauseLabel;

  /// No description provided for @causePest.
  ///
  /// In pt, this message translates to:
  /// **'Praga'**
  String get causePest;

  /// No description provided for @causeDisease.
  ///
  /// In pt, this message translates to:
  /// **'Doença'**
  String get causeDisease;

  /// No description provided for @causeWatering.
  ///
  /// In pt, this message translates to:
  /// **'Rega'**
  String get causeWatering;

  /// No description provided for @causeNutrition.
  ///
  /// In pt, this message translates to:
  /// **'Nutrição'**
  String get causeNutrition;

  /// No description provided for @causeEnvironment.
  ///
  /// In pt, this message translates to:
  /// **'Ambiente'**
  String get causeEnvironment;

  /// No description provided for @causeAccident.
  ///
  /// In pt, this message translates to:
  /// **'Acidente'**
  String get causeAccident;

  /// No description provided for @endPlantKeepsHistory.
  ///
  /// In pt, this message translates to:
  /// **'O histórico completo fica guardado. Nada é apagado.'**
  String get endPlantKeepsHistory;

  /// No description provided for @timelineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Linha do tempo'**
  String get timelineTitle;

  /// No description provided for @timelineEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum registro ainda.'**
  String get timelineEmpty;

  /// No description provided for @registerActivity.
  ///
  /// In pt, this message translates to:
  /// **'Registrar atividade'**
  String get registerActivity;

  /// No description provided for @plantFallbackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Planta {code}'**
  String plantFallbackTitle(String code);

  /// No description provided for @statusActive.
  ///
  /// In pt, this message translates to:
  /// **'Ativa'**
  String get statusActive;

  /// No description provided for @statusCompleted.
  ///
  /// In pt, this message translates to:
  /// **'Concluída'**
  String get statusCompleted;

  /// No description provided for @statusDied.
  ///
  /// In pt, this message translates to:
  /// **'Morta'**
  String get statusDied;

  /// No description provided for @statusDiscarded.
  ///
  /// In pt, this message translates to:
  /// **'Descartada'**
  String get statusDiscarded;

  /// No description provided for @statusInterrupted.
  ///
  /// In pt, this message translates to:
  /// **'Interrompida'**
  String get statusInterrupted;

  /// No description provided for @statusArchived.
  ///
  /// In pt, this message translates to:
  /// **'Arquivada'**
  String get statusArchived;

  /// No description provided for @eventPlantCreated.
  ///
  /// In pt, this message translates to:
  /// **'Planta cadastrada'**
  String get eventPlantCreated;

  /// No description provided for @eventGerminated.
  ///
  /// In pt, this message translates to:
  /// **'Germinação'**
  String get eventGerminated;

  /// No description provided for @eventWatered.
  ///
  /// In pt, this message translates to:
  /// **'Rega'**
  String get eventWatered;

  /// No description provided for @eventFed.
  ///
  /// In pt, this message translates to:
  /// **'Alimentação'**
  String get eventFed;

  /// No description provided for @eventTreatment.
  ///
  /// In pt, this message translates to:
  /// **'Tratamento'**
  String get eventTreatment;

  /// No description provided for @eventMeasurement.
  ///
  /// In pt, this message translates to:
  /// **'Medição'**
  String get eventMeasurement;

  /// No description provided for @eventTransplant.
  ///
  /// In pt, this message translates to:
  /// **'Transplante'**
  String get eventTransplant;

  /// No description provided for @eventPhaseChanged.
  ///
  /// In pt, this message translates to:
  /// **'Mudança de fase'**
  String get eventPhaseChanged;

  /// No description provided for @eventPhotoAdded.
  ///
  /// In pt, this message translates to:
  /// **'Foto'**
  String get eventPhotoAdded;

  /// No description provided for @eventObservation.
  ///
  /// In pt, this message translates to:
  /// **'Observação'**
  String get eventObservation;

  /// No description provided for @eventProblem.
  ///
  /// In pt, this message translates to:
  /// **'Problema'**
  String get eventProblem;

  /// No description provided for @eventTaskDone.
  ///
  /// In pt, this message translates to:
  /// **'Tarefa concluída'**
  String get eventTaskDone;

  /// No description provided for @eventHarvested.
  ///
  /// In pt, this message translates to:
  /// **'Colheita'**
  String get eventHarvested;

  /// No description provided for @eventPlantEnded.
  ///
  /// In pt, this message translates to:
  /// **'Ciclo encerrado'**
  String get eventPlantEnded;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
