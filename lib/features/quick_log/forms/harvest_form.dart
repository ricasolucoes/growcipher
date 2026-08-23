import 'package:flutter/material.dart';

import '../../../domain/models/plant_enums.dart';
import '../../../domain/models/plant_event.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/input_parsing.dart';
import '../../common/l10n_extensions.dart';
import 'quick_log_form_shell.dart';
import 'quick_log_input.dart';

/// Colheita. Pode encerrar o ciclo junto: nesse caso o mesmo "Salvar" grava o
/// evento de colheita e depois encerra a planta, nessa ordem.
class HarvestInput implements QuickLogInput {
  const HarvestInput({
    this.wetWeight = '',
    this.dryWeight = '',
    this.unit = '',
    this.notes = '',
    this.endCycle = false,
  });

  final String wetWeight;
  final String dryWeight;
  final String unit;
  final String notes;

  /// Encerrar a planta com motivo "colheita concluída".
  final bool endCycle;

  @override
  List<QuickLogError> validate() => const [];

  @override
  QuickLogSubmission build(QuickLogStamp stamp) {
    final harvested = AddEventSubmission(
      HarvestedEvent(
        id: stamp.eventId,
        plantId: stamp.plantId,
        occurredAt: stamp.occurredAt,
        createdAt: stamp.createdAt,
        wetWeight: parseFlexibleDouble(wetWeight),
        dryWeight: parseFlexibleDouble(dryWeight),
        unit: textOrNull(unit),
        notes: textOrNull(notes),
      ),
    );

    if (!endCycle) return harvested;

    return QuickLogSubmission.all([
      harvested,
      EndPlantSubmission(
        plantId: stamp.plantId,
        reason: PlantEndReason.harvestCompleted,
        occurredAt: stamp.occurredAt,
      ),
    ]);
  }
}

class HarvestForm extends QuickLogFormWidget {
  const HarvestForm({super.key, required super.plant, required super.onBack});

  @override
  State<HarvestForm> createState() => _HarvestFormState();
}

class _HarvestFormState extends QuickLogFormState<HarvestForm> {
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

  @override
  String title(AppLocalizations l10n) => l10n.quickLogHarvest;

  @override
  HarvestInput get input => HarvestInput(
    wetWeight: _wet.text,
    dryWeight: _dry.text,
    unit: _unit.text,
    notes: _notes.text,
    endCycle: _endCycle,
  );

  @override
  List<Widget> fields(BuildContext context) {
    final l10n = context.l10n;

    return [
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: NumberField(controller: _wet, label: l10n.wetWeightLabel),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: NumberField(controller: _dry, label: l10n.dryWeightLabel),
          ),
        ],
      ),
      const SizedBox(height: 16),
      LabeledTextField(
        controller: _unit,
        label: l10n.unitLabel,
        helper: l10n.weightUnitHelper,
      ),
      const SizedBox(height: 16),
      NotesField(controller: _notes),
      const SizedBox(height: 8),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(l10n.harvestEndsCycle),
        subtitle: Text(l10n.harvestEndsCycleHelper),
        value: _endCycle,
        onChanged: (value) => setState(() => _endCycle = value),
      ),
    ];
  }
}
