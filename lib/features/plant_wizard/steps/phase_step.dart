import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Passo 8 — fase atual. Já chega com a sugestão do ponto de partida
/// marcada, então este passo nunca fica sem resposta.
class PhaseStep extends StatelessWidget {
  const PhaseStep({
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
    final selected = machine.selectedPhase;

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.wizardPhaseTitle,
      subtitle: l10n.phaseSuggestedHint,
      children: [
        for (final value in PlantPhase.values)
          WizardOptionCard(
            title: l10n.phaseLabel(value),
            selected: selected == value,
            onTap: () => onTransition(machine.selectPhase(value)),
          ),
      ],
    );
  }
}
