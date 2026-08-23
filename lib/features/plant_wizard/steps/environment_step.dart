import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 6 — ambiente. O detalhe do espaço só aparece depois da escolha, e a
/// lista de espaços muda com ela ([WizardMachine.environmentPlaces]).
class EnvironmentStep extends StatelessWidget {
  const EnvironmentStep({
    super.key,
    required this.machine,
    required this.progressLabel,
    required this.onTransition,
    required this.nameController,
  });

  final WizardMachine machine;
  final String progressLabel;
  final ValueChanged<WizardNavigation> onTransition;
  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final draft = machine.draft;
    final environment = draft.environment;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardEnvironmentTitle,
      children: [
        for (final value in const [
          GrowingEnvironment.indoor,
          GrowingEnvironment.outdoor,
          GrowingEnvironment.mixed,
        ])
          WizardOptionCard(
            title: l10n.environmentLabel(value),
            selected: environment == value,
            onTap: () => onTransition(machine.selectEnvironment(value)),
          ),
        if (environment != null &&
            environment != GrowingEnvironment.unknown) ...[
          const SizedBox(height: 16),
          Text(
            '${l10n.environmentDetailLabel} (${l10n.optionalTag})',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final place in machine.environmentPlaces)
                ChoiceChip(
                  label: Text(l10n.environmentPlaceLabel(place)),
                  selected: draft.environmentPlace == place,
                  onSelected: (selected) => onTransition(
                    machine.selectEnvironmentPlace(selected ? place : null),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.environmentNameLabel,
              helperText: l10n.environmentNameHelper,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ],
    );
  }
}
