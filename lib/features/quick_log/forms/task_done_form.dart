import 'package:flutter/material.dart';

import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Tarefa concluída: o que foi feito, em texto livre.
class TaskDoneInput implements QuickLogInput {
  const TaskDoneInput({this.description = '', this.notes = ''});

  final String description;
  final String notes;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    TaskCompletedEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      taskDescription: textOrNull(description),
      notes: textOrNull(notes),
    ),
  );
}

class TaskDoneForm extends QuickLogFormWidget {
  const TaskDoneForm({super.key, required super.plant, required super.onBack});

  @override
  State<TaskDoneForm> createState() => _TaskDoneFormState();
}

class _TaskDoneFormState extends QuickLogFormState<TaskDoneForm> {
  final _description = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogTaskDone;

  @override
  TaskDoneInput get input =>
      TaskDoneInput(description: _description.text, notes: _notes.text);

  @override
  List<Widget> fields(BuildContext context) {
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      LabeledTextField(
        controller: _description,
        label: l10n.taskDescriptionLabel,
      ),
      const SizedBox(height: 16),
      NotesField(controller: _notes),
    ];
  }
}
