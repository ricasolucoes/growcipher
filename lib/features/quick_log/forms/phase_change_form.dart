import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Mudança de fase. Diferente dos demais, não gera só um evento: o
/// repositório também atualiza o snapshot da planta, por isso a submissão é
/// uma [ChangePhaseSubmission].
class PhaseChangeInput implements QuickLogInput {
  const PhaseChangeInput({this.newPhase, this.notes = ''});

  /// Única resposta obrigatória do registro rápido junto com o motivo de
  /// encerramento: sem ela não há o que mudar.
  final PlantPhase? newPhase;
  final String notes;

  @override
  List<QuickLogError> validate() => [
    if (newPhase == null) QuickLogError.phaseRequired,
  ];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => ChangePhaseSubmission(
    plantId: stamp.plantId,
    newPhase: newPhase!,
    occurredAt: stamp.occurredAt,
    notes: textOrNull(notes),
  );
}

class PhaseChangeForm extends QuickLogFormWidget {
  const PhaseChangeForm({
    super.key,
    required super.plant,
    required super.onBack,
  });

  @override
  State<PhaseChangeForm> createState() => _PhaseChangeFormState();
}

class _PhaseChangeFormState extends QuickLogFormState<PhaseChangeForm> {
  PlantPhase? _newPhase;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogPhaseChange;

  @override
  PhaseChangeInput get input =>
      PhaseChangeInput(newPhase: _newPhase, notes: _notes.text);

  @override
  List<Widget> fields(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return [
      const SizedBox(height: 4),
      Text(
        l10n.currentPhaseLabel(l10n.phaseLabel(widget.plant.phase)),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      const SizedBox(height: 12),
      Text(l10n.newPhaseLabel, style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final phase in PlantPhase.values)
            if (phase != widget.plant.phase)
              ChoiceChip(
                label: Text(l10n.phaseLabel(phase)),
                selected: _newPhase == phase,
                onSelected: (_) => setState(() => _newPhase = phase),
              ),
        ],
      ),
      const SizedBox(height: 16),
      NotesField(controller: _notes),
    ];
  }
}
