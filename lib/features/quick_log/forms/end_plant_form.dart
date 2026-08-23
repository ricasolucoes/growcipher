import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Encerramento da planta. O motivo é obrigatório porque define o status que
/// fica no lugar de "ativa"; a causa só existe quando a planta morreu.
///
/// Encerrar nunca apaga: a planta continua listada, com o histórico completo.
class EndPlantInput implements QuickLogInput {
  const EndPlantInput({this.reason, this.cause, this.notes = ''});

  final PlantEndReason? reason;
  final PlantEndCause? cause;
  final String notes;

  @override
  List<QuickLogError> validate() => [
    if (reason == null) QuickLogError.endReasonRequired,
  ];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => EndPlantSubmission(
    plantId: stamp.plantId,
    reason: reason!,
    // A causa acompanha apenas a morte: escolher "morreu · praga" e depois
    // trocar o motivo para "descartada" não pode levar a praga junto.
    cause: reason == PlantEndReason.died ? cause : null,
    occurredAt: stamp.occurredAt,
    notes: textOrNull(notes),
  );
}

class EndPlantForm extends QuickLogFormWidget {
  const EndPlantForm({super.key, required super.plant, required super.onBack});

  @override
  State<EndPlantForm> createState() => _EndPlantFormState();
}

class _EndPlantFormState extends QuickLogFormState<EndPlantForm> {
  PlantEndReason? _reason;
  PlantEndCause? _cause;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogEndPlant;

  @override
  EndPlantInput get input =>
      EndPlantInput(reason: _reason, cause: _cause, notes: _notes.text);

  @override
  List<Widget> fields(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      Text(l10n.endReasonLabel, style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final reason in PlantEndReason.values)
            ChoiceChip(
              label: Text(l10n.endReasonOptionLabel(reason)),
              selected: _reason == reason,
              onSelected: (_) => setState(() => _reason = reason),
            ),
        ],
      ),
      if (_reason == PlantEndReason.died) ...[
        const SizedBox(height: 16),
        Text(l10n.endCauseLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final cause in PlantEndCause.values)
              ChoiceChip(
                label: Text(l10n.endCauseOptionLabel(cause)),
                selected: _cause == cause,
                onSelected: (selected) =>
                    setState(() => _cause = selected ? cause : null),
              ),
          ],
        ),
      ],
      const SizedBox(height: 16),
      NotesField(controller: _notes),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(
            Icons.history,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.endPlantKeepsHistory,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
