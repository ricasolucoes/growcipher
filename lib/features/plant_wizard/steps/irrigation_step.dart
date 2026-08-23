import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 9 — irrigação. Manual e indefinida encerram o passo sozinhas;
/// automática e mista abrem a escolha opcional do sistema.
class IrrigationStep extends StatelessWidget {
  const IrrigationStep({
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
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final draft = machine.draft;
    final mode = draft.irrigationMode;
    final showSystems =
        mode == IrrigationMode.automatic || mode == IrrigationMode.mixed;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardIrrigationTitle,
      children: [
        for (final value in const [
          IrrigationMode.manual,
          IrrigationMode.automatic,
          IrrigationMode.mixed,
          IrrigationMode.undefined,
        ])
          WizardOptionCard(
            title: l10n.irrigationModeLabel(value),
            selected: mode == value,
            onTap: () => onTransition(machine.selectIrrigationMode(value)),
          ),
        if (showSystems) ...[
          const SizedBox(height: 16),
          Text(
            '${l10n.irrigationSystemLabel} (${l10n.optionalTag})',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final system in IrrigationSystem.values)
                ChoiceChip(
                  label: Text(l10n.irrigationSystemOptionLabel(system)),
                  selected: draft.irrigationSystem == system,
                  onSelected: (selected) => onTransition(
                    machine.selectIrrigationSystem(selected ? system : null),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
