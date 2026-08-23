import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 1 — ponto de partida. Escolher já avança: é a única resposta que o
/// wizard exige, e ela define os quatro caminhos dos passos seguintes.
class StartStep extends StatelessWidget {
  const StartStep({
    super.key,
    required this.machine,
    required this.progressLabel,
    required this.onTransition,
  });

  final WizardMachine machine;
  final String progressLabel;
  final ValueChanged<WizardNavigation> onTransition;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardStartTitle,
      children: [
        for (final value in PlantStartingPoint.values)
          WizardOptionCard(
            title: l10n.startingPointLabel(value),
            description: switch (value) {
              PlantStartingPoint.seed => l10n.startingPointSeedDesc,
              PlantStartingPoint.seedling => l10n.startingPointSeedlingDesc,
              PlantStartingPoint.clone => l10n.startingPointCloneDesc,
              PlantStartingPoint.inProgress => l10n.startingPointInProgressDesc,
            },
            selected: machine.draft.startingPoint == value,
            onTap: () => onTransition(machine.selectStartingPoint(value)),
          ),
      ],
    );
  }
}
