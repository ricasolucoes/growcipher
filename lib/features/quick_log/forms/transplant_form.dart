import 'package:flutter/material.dart';

import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/input_parsing.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Transplante: recipiente e volume, ambos opcionais.
class TransplantInput implements QuickLogInput {
  const TransplantInput({
    this.containerType = '',
    this.containerVolume = '',
    this.notes = '',
  });

  final String containerType;
  final String containerVolume;
  final String notes;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    TransplantedEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      containerType: textOrNull(containerType),
      containerVolumeLiters: parseFlexibleDouble(containerVolume),
      notes: textOrNull(notes),
    ),
  );
}

class TransplantForm extends QuickLogFormWidget {
  const TransplantForm({
    super.key,
    required super.plant,
    required super.onBack,
  });

  @override
  State<TransplantForm> createState() => _TransplantFormState();
}

class _TransplantFormState extends QuickLogFormState<TransplantForm> {
  final _container = TextEditingController();
  final _volume = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _container.dispose();
    _volume.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogTransplant;

  @override
  TransplantInput get input => TransplantInput(
    containerType: _container.text,
    containerVolume: _volume.text,
    notes: _notes.text,
  );

  @override
  List<Widget> fields(BuildContext context) {
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      LabeledTextField(
        controller: _container,
        label: l10n.containerTypeLabel,
        helper: l10n.containerTypeHelper,
      ),
      const SizedBox(height: 16),
      NumberField(
        controller: _volume,
        label: l10n.containerVolumeLabel,
        helper: l10n.containerVolumeHelper,
      ),
      const SizedBox(height: 16),
      NotesField(controller: _notes),
    ];
  }
}
