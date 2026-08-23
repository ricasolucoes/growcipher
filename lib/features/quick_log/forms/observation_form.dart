import 'package:flutter/material.dart';

import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Observação livre. Único formulário de rotina com campo obrigatório:
/// observação sem texto não registra nada.
class ObservationInput implements QuickLogInput {
  const ObservationInput({this.text = ''});

  final String text;

  @override
  List<QuickLogError> validate() => [
    if (textOrNull(text) == null) QuickLogError.observationRequired,
  ];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) => AddEventSubmission(
    ObservationAddedEvent(
      id: stamp.eventId,
      plantId: stamp.plantId,
      occurredAt: stamp.occurredAt,
      createdAt: stamp.createdAt,
      notes: textOrNull(text),
    ),
  );
}

class ObservationForm extends QuickLogFormWidget {
  const ObservationForm({
    super.key,
    required super.plant,
    required super.onBack,
  });

  @override
  State<ObservationForm> createState() => _ObservationFormState();
}

class _ObservationFormState extends QuickLogFormState<ObservationForm> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    // O botão Salvar depende do texto: redesenha a cada tecla.
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  String title(AppLocalizations l10n) => l10n.quickLogObservation;

  @override
  ObservationInput get input => ObservationInput(text: _text.text);

  @override
  List<Widget> fields(BuildContext context) {
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      TextField(
        controller: _text,
        textCapitalization: TextCapitalization.sentences,
        minLines: 3,
        maxLines: 6,
        decoration: InputDecoration(
          labelText: l10n.observationFieldLabel,
          border: const OutlineInputBorder(),
        ),
      ),
    ];
  }
}
