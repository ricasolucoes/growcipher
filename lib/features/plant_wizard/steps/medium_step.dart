import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 7 — meio de cultivo, recipiente e volume.
class MediumStep extends StatelessWidget {
  const MediumStep({
    super.key,
    required this.machine,
    required this.progressLabel,
    required this.onTransition,
    required this.containerTypeController,
    required this.containerVolumeController,
  });

  final WizardMachine machine;
  final String progressLabel;
  final ValueChanged<WizardNavigation> onTransition;
  final TextEditingController containerTypeController;
  final TextEditingController containerVolumeController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardMediumTitle,
      children: [
        for (final value in GrowingMedium.values)
          WizardOptionCard(
            title: l10n.growingMediumLabel(value),
            selected: machine.draft.growingMedium == value,
            onTap: () => onTransition(machine.selectMedium(value)),
          ),
        const SizedBox(height: 12),
        TextField(
          controller: containerTypeController,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.containerTypeLabel,
            helperText: l10n.containerTypeHelper,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: containerVolumeController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.containerVolumeLabel,
            helperText: l10n.containerVolumeHelper,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
