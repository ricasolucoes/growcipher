import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 4 — genética. "Não sei" avança direto; conhecer abre a variedade e
/// o tipo genético.
class GeneticsStep extends StatelessWidget {
  const GeneticsStep({
    super.key,
    required this.machine,
    required this.progressLabel,
    required this.onTransition,
    required this.strainController,
  });

  final WizardMachine machine;
  final String progressLabel;
  final ValueChanged<WizardNavigation> onTransition;
  final TextEditingController strainController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final draft = machine.draft;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardGeneticsTitle,
      children: [
        WizardOptionCard(
          title: l10n.geneticsKnown,
          selected: draft.knowsGenetics == true,
          onTap: () => onTransition(machine.answerGenetics(true)),
        ),
        WizardOptionCard(
          title: l10n.dontKnow,
          selected: draft.knowsGenetics == false,
          onTap: () => onTransition(machine.answerGenetics(false)),
        ),
        if (draft.knowsGenetics == true) ...[
          const SizedBox(height: 12),
          TextField(
            controller: strainController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.strainLabel,
              helperText: l10n.strainHelper,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.geneticTypeQuestion, style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          for (final value in PlantGeneticType.values)
            WizardOptionCard(
              title: l10n.geneticTypeLabel(value),
              selected: draft.geneticType == value,
              onTap: () => onTransition(machine.selectGeneticType(value)),
            ),
        ],
      ],
    );
  }
}
