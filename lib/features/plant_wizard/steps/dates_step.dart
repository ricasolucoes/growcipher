import 'package:flutter/material.dart';

import '../../common/formatting.dart';
import '../../common/l10n_extensions.dart';
import '../wizard_labels.dart';
import '../wizard_machine.dart';
import '../wizard_widgets.dart';

/// Calendário do wizard: nunca aceita data futura, e volta no máximo cinco
/// anos — um diário de cultivo não tem por que ir além disso.
Future<DateTime?> _pickDate(
  BuildContext context, {
  String? helpText,
  DateTime? initial,
}) {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: DateTime(now.year - 5),
    lastDate: now,
    helpText: helpText,
  );
}

/// Passo 5 — datas. A pergunta e as datas extras vêm do ponto de partida;
/// "Não sei" é resposta válida, como em quase todo o wizard.
class DatesStep extends StatelessWidget {
  const DatesStep({
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

    final today = DateUtils.dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));
    final choice = machine.startDateChoice(today);

    return WizardStepScaffold(
      progressLabel: progressLabel,
      title: l10n.datesQuestionTitle(machine.datesQuestion),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(l10n.dateToday),
              selected: choice == WizardDateChoice.today,
              onSelected: (_) => onTransition(machine.setStartDate(today)),
            ),
            ChoiceChip(
              label: Text(l10n.dateYesterday),
              selected: choice == WizardDateChoice.yesterday,
              onSelected: (_) => onTransition(machine.setStartDate(yesterday)),
            ),
            ChoiceChip(
              label: Text(l10n.datePick),
              selected: choice == WizardDateChoice.picked,
              onSelected: (_) async {
                final date = await _pickDate(context, initial: draft.startDate);
                if (date != null) onTransition(machine.setStartDate(date));
              },
            ),
            ChoiceChip(
              label: Text(l10n.dateApproximate),
              selected: choice == WizardDateChoice.approximate,
              onSelected: (_) async {
                final date = await _pickDate(
                  context,
                  helpText: l10n.dateApproximate,
                  initial: draft.startDate,
                );
                if (date != null) {
                  onTransition(machine.setStartDate(date, approximate: true));
                }
              },
            ),
            ChoiceChip(
              label: Text(l10n.dontKnow),
              selected: choice == WizardDateChoice.unknown,
              onSelected: (_) => onTransition(machine.setStartDateUnknown()),
            ),
          ],
        ),
        if (draft.startDate != null) ...[
          const SizedBox(height: 16),
          Text(
            formatDate(
              context,
              draft.startDate!,
              approximate: draft.startDateIsApproximate,
            ),
            style: theme.textTheme.titleMedium,
          ),
        ],
        if (machine.extraDates.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            l10n.extraDatesLabel,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          for (final extra in machine.extraDates)
            _ExtraDateTile(
              label: l10n.extraDateLabel(extra),
              value: machine.extraDate(extra),
              onChanged: (date) =>
                  onTransition(machine.setExtraDate(extra, date)),
            ),
        ],
      ],
    );
  }
}

/// Data adicional: toca para escolher, X para limpar.
class _ExtraDateTile extends StatelessWidget {
  const _ExtraDateTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event_outlined),
      title: Text(label),
      subtitle: value == null ? null : Text(formatDate(context, value!)),
      trailing: value == null
          ? const Icon(Icons.add)
          : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => onChanged(null),
            ),
      onTap: () async {
        final date = await _pickDate(context, helpText: label, initial: value);
        if (date != null) onChanged(date);
      },
    );
  }
}
