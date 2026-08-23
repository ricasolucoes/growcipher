import '../../l10n/generated/app_localizations.dart';
import 'wizard_machine.dart';

/// Rótulos pt-BR dos enums da máquina do wizard.
///
/// Mesma divisão de `features/common/enum_labels.dart`: a máquina decide em
/// inglês, a interface pergunta aqui como se diz.
extension WizardLabels on AppLocalizations {
  /// Pergunta que abre o passo de datas.
  String datesQuestionTitle(WizardDatesQuestion value) => switch (value) {
    WizardDatesQuestion.seed => datesTitleSeed,
    WizardDatesQuestion.seedling => datesTitleSeedling,
    WizardDatesQuestion.clone => datesTitleClone,
    WizardDatesQuestion.inProgress => datesTitleInProgress,
  };

  String extraDateLabel(WizardExtraDate value) => switch (value) {
    WizardExtraDate.seedObtained => extraDateSeedObtained,
    WizardExtraDate.germination => extraDateGermination,
    WizardExtraDate.rooted => extraDateRooted,
  };
}
