import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 3 — origem. As opções vêm do ponto de partida
/// ([WizardMachine.originOptions]), inclusive a concordância de gênero dos
/// rótulos ("Comprada" para semente, "Comprado" para clone).
class OriginStep extends StatelessWidget {
  const OriginStep({
    super.key,
    required this.machine,
    required this.progressLabel,
    required this.onTransition,
    required this.detailsController,
  });

  final WizardMachine machine;
  final String progressLabel;
  final ValueChanged<WizardNavigation> onTransition;
  final TextEditingController detailsController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final draft = machine.draft;
    final showDetails =
        draft.origin != null && draft.origin != PlantOrigin.unknown;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardOriginTitle,
      children: [
        for (final value in machine.originOptions)
          WizardOptionCard(
            title: l10n.originLabel(value, startingPoint: draft.startingPoint),
            selected: draft.origin == value,
            onTap: () => onTransition(machine.selectOrigin(value)),
          ),
        if (showDetails) ...[
          const SizedBox(height: 12),
          TextField(
            controller: detailsController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.originDetailsLabel,
              helperText: l10n.originDetailsHelper,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
