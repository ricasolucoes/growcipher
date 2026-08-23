import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/enum_labels.dart';
import '../../common/input_parsing.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Tratamento — separado de alimentação de propósito: pulverizar um
/// fungicida não é a mesma coisa que adubar, e a linha do tempo mostra os
/// dois com ícones diferentes.
class TreatmentInput implements QuickLogInput {
  const TreatmentInput({
    this.treatmentType = TreatmentType.treatment,
    this.product = '',
    this.amount = '',
    this.unit = '',
    this.method = '',
    this.notes = '',
  });

  /// Sempre preenchido: o tipo genérico já vem selecionado.
  final TreatmentType treatmentType;
  final String product;
  final String amount;
  final String unit;
  final String method;
  final String notes;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    TreatmentAppliedEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      treatmentType: treatmentType,
      product: textOrNull(product),
      amount: parseFlexibleDouble(amount),
      unit: textOrNull(unit),
      method: textOrNull(method),
      notes: textOrNull(notes),
    ),
  );
}

class TreatmentForm extends QuickLogFormWidget {
  const TreatmentForm({super.key, required super.plant, required super.onBack});

  @override
  State<TreatmentForm> createState() => _TreatmentFormState();
}

class _TreatmentFormState extends QuickLogFormState<TreatmentForm> {
  TreatmentType _type = TreatmentType.treatment;
  final _product = TextEditingController();
  final _amount = TextEditingController();
  final _unit = TextEditingController();
  final _method = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _product.dispose();
    _amount.dispose();
    _unit.dispose();
    _method.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogTreatment;

  @override
  TreatmentInput get input => TreatmentInput(
    treatmentType: _type,
    product: _product.text,
    amount: _amount.text,
    unit: _unit.text,
    method: _method.text,
    notes: _notes.text,
  );

  @override
  List<Widget> fields(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      Text(l10n.treatmentTypeLabel, style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final type in TreatmentType.values)
            ChoiceChip(
              label: Text(l10n.treatmentTypeOptionLabel(type)),
              selected: _type == type,
              onSelected: (_) => setState(() => _type = type),
            ),
        ],
      ),
      const SizedBox(height: 16),
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
            child: LabeledTextField(controller: _unit, label: l10n.unitLabel),
          ),
        ],
      ),
      const SizedBox(height: 16),
      LabeledTextField(
        controller: _method,
        label: l10n.methodLabel,
        helper: l10n.methodHelper,
      ),
      const SizedBox(height: 16),
      NotesField(controller: _notes),
    ];
  }
}
