import 'package:flutter/material.dart';

import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/input_parsing.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Rega. Sem campo obrigatório: salvar só com a data/hora já é um registro
/// válido — é o caso mais frequente do app.
class WateredInput implements QuickLogInput {
  const WateredInput({
    this.amount = '',
    this.unit = '',
    this.solutionType = '',
    this.notes = '',
  });

  final String amount;
  final String unit;
  final String solutionType;
  final String notes;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    WateredEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      amount: parseFlexibleDouble(amount),
      unit: textOrNull(unit),
      solutionType: textOrNull(solutionType),
      notes: textOrNull(notes),
    ),
  );
}

class WateredForm extends QuickLogFormWidget {
  const WateredForm({super.key, required super.plant, required super.onBack});

  @override
  State<WateredForm> createState() => _WateredFormState();
}

class _WateredFormState extends QuickLogFormState<WateredForm> {
  final _amount = TextEditingController();
  final _unit = TextEditingController();
  final _solution = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _amount.dispose();
    _unit.dispose();
    _solution.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogWatered;

  @override
  WateredInput get input => WateredInput(
    amount: _amount.text,
    unit: _unit.text,
    solutionType: _solution.text,
    notes: _notes.text,
  );

  @override
  List<Widget> fields(BuildContext context) {
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: NumberField(controller: _amount, label: l10n.amountLabel),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: LabeledTextField(
              controller: _unit,
              label: l10n.unitLabel,
              helper: l10n.volumeUnitHelper,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      LabeledTextField(
        controller: _solution,
        label: l10n.solutionTypeLabel,
        helper: l10n.solutionTypeHelper,
      ),
      const SizedBox(height: 16),
      NotesField(controller: _notes),
    ];
  }
}
