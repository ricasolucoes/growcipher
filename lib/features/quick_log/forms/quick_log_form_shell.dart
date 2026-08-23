import 'package:flutter/material.dart';

import '../../../app_scope.dart';
import '../../../domain/identifiers.dart';
import '../../../domain/models/plant.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/formatting.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_input.dart';

/// Base dos formulários do registro rápido.
///
/// Todo formulário tem a mesma moldura (voltar, título, "Quando aconteceu",
/// campos, botão Salvar) e o mesmo ciclo de gravação. O que muda por tipo de
/// acontecimento fica em três respostas do subtipo: [title], [fields] e
/// [input] — e é só a [input] que decide se dá para salvar.
abstract class QuickLogFormWidget extends StatefulWidget {
  const QuickLogFormWidget({
    super.key,
    required this.plant,
    required this.onBack,
  });

  final Plant plant;
  final VoidCallback onBack;
}

abstract class QuickLogFormState<T extends QuickLogFormWidget>
    extends State<T> {
  /// `null` = "Agora" (resolvido no momento de salvar).
  DateTime? occurredAt;

  bool _saving = false;

  /// Título da moldura.
  String title(AppLocalizations l10n);

  /// Campos específicos do tipo, abaixo de "Quando aconteceu".
  List<Widget> fields(BuildContext context);

  /// Entrada pura montada a partir do que está preenchido agora.
  QuickLogInput get input;

  Future<void> _save() async {
    final current = input;
    if (_saving || !current.isValid) return;
    setState(() => _saving = true);

    final now = DateTime.now();
    final submission = current.build(
      QuickLogStamp(
        plantId: widget.plant.id,
        eventId: generateLocalId(),
        occurredAt: occurredAt ?? now,
        createdAt: now,
      ),
    );

    try {
      await submission.apply(AppScope.of(context).plantRepository);
    } catch (_) {
      // Falha de escrita local: libera o botão para o usuário tentar de novo
      // em vez de deixar o formulário travado em "salvando".
      if (mounted) setState(() => _saving = false);
      rethrow;
    }
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuickLogFormShell(
      title: title(context.l10n),
      onBack: widget.onBack,
      onSave: _save,
      saveEnabled: input.isValid,
      saving: _saving,
      children: [
        OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        ...fields(context),
      ],
    );
  }
}

/// Moldura visual comum: voltar, título, campos e o botão Salvar.
class QuickLogFormShell extends StatelessWidget {
  const QuickLogFormShell({
    super.key,
    required this.title,
    required this.onBack,
    required this.children,
    required this.onSave,
    this.saveEnabled = true,
    this.saving = false,
  });

  final String title;
  final VoidCallback onBack;
  final List<Widget> children;
  final VoidCallback onSave;
  final bool saveEnabled;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              tooltip: l10n.actionBack,
              onPressed: onBack,
            ),
            const SizedBox(width: 4),
            Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          ],
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: saveEnabled && !saving ? onSave : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.actionSave),
          ),
        ),
      ],
    );
  }
}

/// "Quando aconteceu": vazio significa "Agora", resolvido ao salvar.
class OccurredAtField extends StatelessWidget {
  const OccurredAtField({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final initial = value ?? now;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return;

    onChanged(
      DateTime(date.year, date.month, date.day, time.hour, time.minute),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.schedule),
      title: Text(l10n.occurredAtLabel),
      subtitle: Text(
        value == null ? l10n.occurredAtNow : formatDateTime(context, value!),
      ),
      trailing: value == null
          ? const Icon(Icons.edit_outlined, size: 20)
          : IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () => onChanged(null),
            ),
      onTap: () => _pick(context),
    );
  }
}

/// Observações livres, presentes em quase todos os formulários.
class NotesField extends StatelessWidget {
  const NotesField({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 2,
      minLines: 1,
      decoration: InputDecoration(
        labelText: context.l10n.notesLabel,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Campo numérico com vírgula decimal (ver `parseFlexibleDouble`).
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
  });

  final TextEditingController controller;
  final String label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Campo de texto de uma linha com rótulo e ajuda opcional.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    required this.controller,
    required this.label,
    this.helper,
  });

  final TextEditingController controller;
  final String label;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        helperText: helper,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
