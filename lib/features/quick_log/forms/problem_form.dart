import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/enum_labels.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Problema observado. A categoria já nasce em "não sei": registrar que algo
/// está errado não pode depender de saber o que é.
class ProblemInput implements QuickLogInput {
  const ProblemInput({
    this.category = ProblemCategory.unknown,
    this.description = '',
  });

  final ProblemCategory category;
  final String description;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    ProblemReportedEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      category: category,
      notes: textOrNull(description),
    ),
  );
}

class ProblemForm extends QuickLogFormWidget {
  const ProblemForm({super.key, required super.plant, required super.onBack});

  @override
  State<ProblemForm> createState() => _ProblemFormState();
}

class _ProblemFormState extends QuickLogFormState<ProblemForm> {
  ProblemCategory _category = ProblemCategory.unknown;
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogProblem;

  @override
  ProblemInput get input =>
      ProblemInput(category: _category, description: _description.text);

  @override
  List<Widget> fields(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      Text(l10n.problemCategoryLabel, style: theme.textTheme.titleSmall),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final category in ProblemCategory.values)
            ChoiceChip(
              label: Text(l10n.problemCategoryOptionLabel(category)),
              selected: _category == category,
              onSelected: (_) => setState(() => _category = category),
            ),
        ],
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _description,
        textCapitalization: TextCapitalization.sentences,
        minLines: 2,
        maxLines: 4,
        decoration: InputDecoration(
          labelText: l10n.problemDescriptionLabel,
          border: const OutlineInputBorder(),
        ),
      ),
    ];
  }
}
