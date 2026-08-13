import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/identifiers.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_enums.dart';
import '../../domain/models/plant_event.dart';
import '../../domain/repositories/plant_repository.dart';
import '../common/enum_labels.dart';
import '../common/formatting.dart';
import '../common/input_parsing.dart';
import '../common/l10n_extensions.dart';
import 'quick_log.dart';

/// Formulário mínimo de cada ação do registro rápido.
///
/// Todos os campos são opcionais salvo o essencial da ação (ex.: motivo do
/// encerramento); salvar só com a data/hora padrão ("Agora") é sempre
/// possível na rega e nas demais ações de rotina.
class QuickLogForm extends StatelessWidget {
  const QuickLogForm({
    super.key,
    required this.action,
    required this.plant,
    required this.onBack,
  });

  final QuickLogAction action;
  final Plant plant;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return switch (action) {
      QuickLogAction.watered => _WateredForm(plant: plant, onBack: onBack),
      QuickLogAction.fed => _FedForm(plant: plant, onBack: onBack),
      QuickLogAction.treatment => _TreatmentForm(plant: plant, onBack: onBack),
      QuickLogAction.measurement => _MeasurementForm(
        plant: plant,
        onBack: onBack,
      ),
      QuickLogAction.transplant => _TransplantForm(
        plant: plant,
        onBack: onBack,
      ),
      QuickLogAction.phaseChange => _PhaseChangeForm(
        plant: plant,
        onBack: onBack,
      ),
      // Foto fica desabilitada no menu até a galeria privada existir.
      QuickLogAction.photo => const SizedBox.shrink(),
      QuickLogAction.observation => _ObservationForm(
        plant: plant,
        onBack: onBack,
      ),
      QuickLogAction.problem => _ProblemForm(plant: plant, onBack: onBack),
      QuickLogAction.taskDone => _TaskDoneForm(plant: plant, onBack: onBack),
      QuickLogAction.harvest => _HarvestForm(plant: plant, onBack: onBack),
      QuickLogAction.endPlant => _EndPlantForm(plant: plant, onBack: onBack),
    };
  }
}

// --- infraestrutura comum dos formulários ---

abstract class _EventFormState<T extends StatefulWidget> extends State<T> {
  /// `null` = "Agora" (resolvido no momento de salvar).
  DateTime? occurredAt;
  bool saving = false;

  PlantRepository get repository => AppScope.of(context).plantRepository;

  Future<void> submit(Future<void> Function(DateTime occurredAt) write) async {
    if (saving) return;
    setState(() => saving = true);
    try {
      await write(occurredAt ?? DateTime.now());
    } catch (_) {
      // Falha de escrita local: libera o botão para o usuário tentar de novo
      // em vez de deixar o formulário travado em "salvando".
      if (mounted) setState(() => saving = false);
      rethrow;
    }
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  static String? textOrNull(TextEditingController controller) {
    final text = controller.text.trim();
    return text.isEmpty ? null : text;
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({
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

class _OccurredAtField extends StatelessWidget {
  const _OccurredAtField({required this.value, required this.onChanged});

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

class _NotesField extends StatelessWidget {
  const _NotesField({required this.controller});

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

class _NumberField extends StatelessWidget {
  const _NumberField({
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

class _TextField extends StatelessWidget {
  const _TextField({
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

// --- rega ---

class _WateredForm extends StatefulWidget {
  const _WateredForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_WateredForm> createState() => _WateredFormState();
}

class _WateredFormState extends _EventFormState<_WateredForm> {
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

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      WateredEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        amount: parseFlexibleDouble(_amount.text),
        unit: _EventFormState.textOrNull(_unit),
        solutionType: _EventFormState.textOrNull(_solution),
        notes: _EventFormState.textOrNull(_notes),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogWatered,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _NumberField(controller: _amount, label: l10n.amountLabel),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _TextField(
                controller: _unit,
                label: l10n.unitLabel,
                helper: l10n.volumeUnitHelper,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TextField(
          controller: _solution,
          label: l10n.solutionTypeLabel,
          helper: l10n.solutionTypeHelper,
        ),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
      ],
    );
  }
}

// --- alimentação / nutrientes ---

class _FedForm extends StatefulWidget {
  const _FedForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_FedForm> createState() => _FedFormState();
}

class _FedFormState extends _EventFormState<_FedForm> {
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

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      FedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        product: _EventFormState.textOrNull(_product),
        amount: parseFlexibleDouble(_amount.text),
        unit: _EventFormState.textOrNull(_unit),
        notes: _EventFormState.textOrNull(_notes),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogFed,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 8),
        _TextField(
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
              child: _NumberField(controller: _amount, label: l10n.amountLabel),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _TextField(
                controller: _unit,
                label: l10n.unitLabel,
                helper: l10n.volumeUnitHelper,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
      ],
    );
  }
}

// --- tratamento (separado de alimentação) ---

class _TreatmentForm extends StatefulWidget {
  const _TreatmentForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_TreatmentForm> createState() => _TreatmentFormState();
}

class _TreatmentFormState extends _EventFormState<_TreatmentForm> {
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

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      TreatmentAppliedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        treatmentType: _type,
        product: _EventFormState.textOrNull(_product),
        amount: parseFlexibleDouble(_amount.text),
        unit: _EventFormState.textOrNull(_unit),
        method: _EventFormState.textOrNull(_method),
        notes: _EventFormState.textOrNull(_notes),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogTreatment,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
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
        _TextField(
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
              child: _NumberField(controller: _amount, label: l10n.amountLabel),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _TextField(controller: _unit, label: l10n.unitLabel),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TextField(
          controller: _method,
          label: l10n.methodLabel,
          helper: l10n.methodHelper,
        ),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
      ],
    );
  }
}

// --- medição ---

class _MeasurementForm extends StatefulWidget {
  const _MeasurementForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends _EventFormState<_MeasurementForm> {
  final _temperature = TextEditingController();
  final _humidity = TextEditingController();
  final _ph = TextEditingController();
  final _ec = TextEditingController();
  final _vpd = TextEditingController();
  final _dli = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _temperature.dispose();
    _humidity.dispose();
    _ph.dispose();
    _ec.dispose();
    _vpd.dispose();
    _dli.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      MeasurementAddedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        temperatureC: parseFlexibleDouble(_temperature.text),
        humidityPercent: parseFlexibleDouble(_humidity.text),
        ph: parseFlexibleDouble(_ph.text),
        ec: parseFlexibleDouble(_ec.text),
        vpd: parseFlexibleDouble(_vpd.text),
        dli: parseFlexibleDouble(_dli.text),
        notes: _EventFormState.textOrNull(_notes),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    Widget pair(
      TextEditingController a,
      String labelA,
      TextEditingController b,
      String labelB,
    ) {
      return Row(
        children: [
          Expanded(
            child: _NumberField(controller: a, label: labelA),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _NumberField(controller: b, label: labelB),
          ),
        ],
      );
    }

    return _FormShell(
      title: l10n.quickLogMeasurement,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.measurementHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        pair(
          _temperature,
          l10n.measureTemperature,
          _humidity,
          l10n.measureHumidity,
        ),
        const SizedBox(height: 16),
        pair(_ph, l10n.measurePh, _ec, l10n.measureEc),
        const SizedBox(height: 16),
        pair(_vpd, l10n.measureVpd, _dli, l10n.measureDli),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
      ],
    );
  }
}

// --- transplante ---

class _TransplantForm extends StatefulWidget {
  const _TransplantForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_TransplantForm> createState() => _TransplantFormState();
}

class _TransplantFormState extends _EventFormState<_TransplantForm> {
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

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      TransplantedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        containerType: _EventFormState.textOrNull(_container),
        containerVolumeLiters: parseFlexibleDouble(_volume.text),
        notes: _EventFormState.textOrNull(_notes),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogTransplant,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 8),
        _TextField(
          controller: _container,
          label: l10n.containerTypeLabel,
          helper: l10n.containerTypeHelper,
        ),
        const SizedBox(height: 16),
        _NumberField(
          controller: _volume,
          label: l10n.containerVolumeLabel,
          helper: l10n.containerVolumeHelper,
        ),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
      ],
    );
  }
}

// --- mudança de fase ---

class _PhaseChangeForm extends StatefulWidget {
  const _PhaseChangeForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_PhaseChangeForm> createState() => _PhaseChangeFormState();
}

class _PhaseChangeFormState extends _EventFormState<_PhaseChangeForm> {
  PlantPhase? _newPhase;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() => submit((occurredAt) {
    return repository.changePhase(
      plantId: widget.plant.id,
      newPhase: _newPhase!,
      occurredAt: occurredAt,
      notes: _EventFormState.textOrNull(_notes),
    );
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogPhaseChange,
      onBack: widget.onBack,
      onSave: _save,
      saveEnabled: _newPhase != null,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.currentPhaseLabel(l10n.phaseLabel(widget.plant.phase)),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Text(l10n.newPhaseLabel, style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final phase in PlantPhase.values)
              if (phase != widget.plant.phase)
                ChoiceChip(
                  label: Text(l10n.phaseLabel(phase)),
                  selected: _newPhase == phase,
                  onSelected: (_) => setState(() => _newPhase = phase),
                ),
          ],
        ),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
      ],
    );
  }
}

// --- observação ---

class _ObservationForm extends StatefulWidget {
  const _ObservationForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_ObservationForm> createState() => _ObservationFormState();
}

class _ObservationFormState extends _EventFormState<_ObservationForm> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      ObservationAddedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        notes: _EventFormState.textOrNull(_text),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogObservation,
      onBack: widget.onBack,
      onSave: _save,
      saveEnabled: _text.text.trim().isNotEmpty,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
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
      ],
    );
  }
}

// --- problema ---

class _ProblemForm extends StatefulWidget {
  const _ProblemForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_ProblemForm> createState() => _ProblemFormState();
}

class _ProblemFormState extends _EventFormState<_ProblemForm> {
  ProblemCategory _category = ProblemCategory.unknown;
  final _description = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      ProblemReportedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        category: _category,
        notes: _EventFormState.textOrNull(_description),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogProblem,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
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
      ],
    );
  }
}

// --- tarefa concluída ---

class _TaskDoneForm extends StatefulWidget {
  const _TaskDoneForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_TaskDoneForm> createState() => _TaskDoneFormState();
}

class _TaskDoneFormState extends _EventFormState<_TaskDoneForm> {
  final _description = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _description.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() => submit((occurredAt) {
    return repository.addEvent(
      TaskCompletedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        taskDescription: _EventFormState.textOrNull(_description),
        notes: _EventFormState.textOrNull(_notes),
      ),
    );
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogTaskDone,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 8),
        _TextField(controller: _description, label: l10n.taskDescriptionLabel),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
      ],
    );
  }
}

// --- colheita ---

class _HarvestForm extends StatefulWidget {
  const _HarvestForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_HarvestForm> createState() => _HarvestFormState();
}

class _HarvestFormState extends _EventFormState<_HarvestForm> {
  final _wet = TextEditingController();
  final _dry = TextEditingController();
  final _unit = TextEditingController();
  final _notes = TextEditingController();
  bool _endCycle = false;

  @override
  void dispose() {
    _wet.dispose();
    _dry.dispose();
    _unit.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() => submit((occurredAt) async {
    await repository.addEvent(
      HarvestedEvent(
        id: generateLocalId(),
        plantId: widget.plant.id,
        occurredAt: occurredAt,
        createdAt: DateTime.now(),
        wetWeight: parseFlexibleDouble(_wet.text),
        dryWeight: parseFlexibleDouble(_dry.text),
        unit: _EventFormState.textOrNull(_unit),
        notes: _EventFormState.textOrNull(_notes),
      ),
    );
    if (_endCycle) {
      await repository.endPlant(
        plantId: widget.plant.id,
        reason: PlantEndReason.harvestCompleted,
        occurredAt: occurredAt,
      );
    }
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogHarvest,
      onBack: widget.onBack,
      onSave: _save,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _NumberField(controller: _wet, label: l10n.wetWeightLabel),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _NumberField(controller: _dry, label: l10n.dryWeightLabel),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TextField(
          controller: _unit,
          label: l10n.unitLabel,
          helper: l10n.weightUnitHelper,
        ),
        const SizedBox(height: 16),
        _NotesField(controller: _notes),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.harvestEndsCycle),
          subtitle: Text(l10n.harvestEndsCycleHelper),
          value: _endCycle,
          onChanged: (value) => setState(() => _endCycle = value),
        ),
      ],
    );
  }
}

// --- encerramento da planta ---

class _EndPlantForm extends StatefulWidget {
  const _EndPlantForm({required this.plant, required this.onBack});

  final Plant plant;
  final VoidCallback onBack;

  @override
  State<_EndPlantForm> createState() => _EndPlantFormState();
}

class _EndPlantFormState extends _EventFormState<_EndPlantForm> {
  PlantEndReason? _reason;
  PlantEndCause? _cause;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() => submit((occurredAt) {
    return repository.endPlant(
      plantId: widget.plant.id,
      reason: _reason!,
      cause: _reason == PlantEndReason.died ? _cause : null,
      occurredAt: occurredAt,
      notes: _EventFormState.textOrNull(_notes),
    );
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return _FormShell(
      title: l10n.quickLogEndPlant,
      onBack: widget.onBack,
      onSave: _save,
      saveEnabled: _reason != null,
      saving: saving,
      children: [
        _OccurredAtField(
          value: occurredAt,
          onChanged: (value) => setState(() => occurredAt = value),
        ),
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
        _NotesField(controller: _notes),
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
      ],
    );
  }
}
