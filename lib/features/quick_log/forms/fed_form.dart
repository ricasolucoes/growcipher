import 'package:flutter/material.dart';

import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/input_parsing.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Alimentação / nutrientes. Tudo opcional — quem só quer marcar que alimentou
/// consegue salvar sem digitar nada.
class FedInput implements QuickLogInput {
  const FedInput({
    this.product = '',
    this.amount = '',
    this.unit = '',
    this.notes = '',
  });

  final String product;
  final String amount;
  final String unit;
  final String notes;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    FedEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      product: textOrNull(product),
      amount: parseFlexibleDouble(amount),
      unit: textOrNull(unit),
      notes: textOrNull(notes),
    ),
  );
}

class FedForm extends QuickLogFormWidget {
  const FedForm({super.key, required super.plant, required super.onBack});

  @override
  State<FedForm> createState() => _FedFormState();
}

class _FedFormState extends QuickLogFormState<FedForm> {
  final _product = TextEditingController();
  final _amount = TextEditingController();
  final _unit = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _product.dispose();
    _amount.dispose();
    _unit.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogFed;

  @override
  FedInput get input => FedInput(
    product: _product.text,
    amount: _amount.text,
    unit: _unit.text,
    notes: _notes.text,
  );

  @override
  List<Widget> fields(BuildContext context) {
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      LabeledTextField(
        controller: _product,
        label: l10n.productLabel,
        helper: l10n.productHelper,
      ),
      const SizedBox(height: 16),
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
      NotesField(controller: _notes),
    ];
  }
}
