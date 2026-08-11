import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_enums.dart';
import '../../domain/models/plant_event.dart';
import '../../l10n/generated/app_localizations.dart';
import '../common/enum_labels.dart';
import '../common/formatting.dart';
import '../common/l10n_extensions.dart';
import '../quick_log/quick_log.dart';

/// Perfil da planta: dados estáveis no topo, linha do tempo abaixo.
class PlantProfileScreen extends StatefulWidget {
  const PlantProfileScreen({super.key, required this.plantId});

  static const String route = '/plants/profile';

  final String plantId;

  @override
  State<PlantProfileScreen> createState() => _PlantProfileScreenState();
}

class _PlantProfileScreenState extends State<PlantProfileScreen> {
  Plant? _plant;
  List<PlantEvent>? _events;
  bool _loadRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadRequested) {
      _loadRequested = true;
      _reload();
    }
  }

  Future<void> _reload() async {
    final repository = AppScope.of(context).plantRepository;
    final plant = await repository.getPlant(widget.plantId);
    final events = await repository.getEvents(widget.plantId);
    if (mounted) {
      setState(() {
        _plant = plant;
        _events = events;
      });
    }
  }

  Future<void> _openQuickLog() async {
    final plant = _plant;
    if (plant == null) return;

    final saved = await showQuickLog(context, plant);
    if (saved && mounted) {
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final plant = _plant;
    final events = _events;

    return Scaffold(
      appBar: AppBar(title: Text(plant?.displayLabel ?? '')),
      floatingActionButton: plant == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _openQuickLog,
              icon: const Icon(Icons.add),
              label: Text(l10n.registerActivity),
            ),
      body: plant == null || events == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              children: [
                _PlantHeader(plant: plant),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    l10n.timelineTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      l10n.timelineEmpty,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                else
                  for (final event in events) _EventTile(event: event),
              ],
            ),
    );
  }
}

class _PlantHeader extends StatelessWidget {
  const _PlantHeader({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final chips = <Widget>[];

    if (plant.status != PlantStatus.active) {
      chips.add(
        Chip(
          label: Text(l10n.statusLabel(plant.status)),
          visualDensity: VisualDensity.compact,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
        ),
      );
    }
    void addInfo(String label) {
      chips.add(Chip(label: Text(label), visualDensity: VisualDensity.compact));
    }

    if (plant.phase != PlantPhase.unknown) {
      addInfo(l10n.phaseLabel(plant.phase));
    }
    if (plant.environment != GrowingEnvironment.unknown) {
      addInfo(l10n.environmentLabel(plant.environment));
    }
    if (plant.growingMedium != GrowingMedium.unknown) {
      addInfo(l10n.growingMediumLabel(plant.growingMedium));
    }
    if (plant.irrigationMode != IrrigationMode.undefined) {
      addInfo(l10n.irrigationModeLabel(plant.irrigationMode));
    }
    if (plant.strain != null) {
      addInfo(plant.strain!);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plant.displayLabel, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            [
              plant.privacyCode,
              if (plant.startDate != null)
                formatDate(
                  context,
                  plant.startDate!,
                  approximate: plant.startDateIsApproximate,
                ),
            ].join(' · '),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: chips),
          ],
        ],
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final PlantEvent event;

  static IconData _icon(PlantEventType type) => switch (type) {
    PlantEventType.plantCreated => Icons.spa_outlined,
    PlantEventType.germinated => Icons.grass,
    PlantEventType.watered => Icons.water_drop_outlined,
    PlantEventType.fed => Icons.science_outlined,
    PlantEventType.treatmentApplied => Icons.healing_outlined,
    PlantEventType.measurementAdded => Icons.thermostat_outlined,
    PlantEventType.transplanted => Icons.yard_outlined,
    PlantEventType.phaseChanged => Icons.trending_up,
    PlantEventType.photoAdded => Icons.photo_camera_outlined,
    PlantEventType.observationAdded => Icons.notes_outlined,
    PlantEventType.problemReported => Icons.report_problem_outlined,
    PlantEventType.taskCompleted => Icons.check_circle_outline,
    PlantEventType.harvested => Icons.agriculture_outlined,
    PlantEventType.plantEnded => Icons.flag_outlined,
  };

  static String? _summary(AppLocalizations l10n, PlantEvent event) {
    String amountWithUnit(double? amount, String? unit) =>
        [if (amount != null) formatNumber(amount), ?unit].join(' ');

    String? joined(List<String?> parts) {
      final filled = parts
          .where((part) => part != null && part.trim().isNotEmpty)
          .cast<String>()
          .toList();
      return filled.isEmpty ? null : filled.join(' · ');
    }

    return switch (event) {
      WateredEvent e => joined([
        if (e.amount != null) amountWithUnit(e.amount, e.unit),
        e.solutionType,
      ]),
      FedEvent e => joined([
        e.product,
        if (e.amount != null) amountWithUnit(e.amount, e.unit),
      ]),
      TreatmentAppliedEvent e => joined([
        l10n.treatmentTypeOptionLabel(e.treatmentType),
        e.product,
        if (e.amount != null) amountWithUnit(e.amount, e.unit),
        e.method,
      ]),
      MeasurementAddedEvent e => joined([
        if (e.temperatureC != null) '${formatNumber(e.temperatureC!)} °C',
        if (e.humidityPercent != null) '${formatNumber(e.humidityPercent!)}%',
        if (e.ph != null) 'pH ${formatNumber(e.ph!)}',
        if (e.ec != null) 'EC ${formatNumber(e.ec!)}',
        if (e.vpd != null) 'VPD ${formatNumber(e.vpd!)}',
        if (e.dli != null) 'DLI ${formatNumber(e.dli!)}',
      ]),
      TransplantedEvent e => joined([
        e.containerType,
        if (e.containerVolumeLiters != null)
          '${formatNumber(e.containerVolumeLiters!)} L',
      ]),
      PhaseChangedEvent e => l10n.phaseTransition(
        l10n.phaseLabel(e.previousPhase),
        l10n.phaseLabel(e.newPhase),
      ),
      ProblemReportedEvent e => l10n.problemCategoryOptionLabel(e.category),
      TaskCompletedEvent e => e.taskDescription,
      HarvestedEvent e => joined([
        if (e.wetWeight != null)
          '${l10n.wetWeightLabel} ${amountWithUnit(e.wetWeight, e.unit)}',
        if (e.dryWeight != null)
          '${l10n.dryWeightLabel} ${amountWithUnit(e.dryWeight, e.unit)}',
      ]),
      PlantEndedEvent e => joined([
        l10n.endReasonOptionLabel(e.reason),
        if (e.cause != null) l10n.endCauseOptionLabel(e.cause!),
      ]),
      PlantCreatedEvent() ||
      GerminatedEvent() ||
      PhotoAddedEvent() ||
      ObservationAddedEvent() => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final summary = _summary(l10n, event);
    final notes = event.notes?.trim();
    final showNotes =
        notes != null && notes.isNotEmpty && event is! ObservationAddedEvent;
    final mainText = event is ObservationAddedEvent
        ? notes ?? ''
        : summary ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              foregroundColor: theme.colorScheme.primary,
              child: Icon(_icon(event.type), size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.eventTypeLabel(event.type),
                    style: theme.textTheme.titleSmall,
                  ),
                  if (mainText.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(mainText, style: theme.textTheme.bodyMedium),
                  ],
                  if (showNotes) ...[
                    const SizedBox(height: 2),
                    Text(
                      notes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    formatDateTime(context, event.occurredAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
