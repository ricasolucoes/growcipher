import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';
import '../../domain/models/plant.dart';
import '../../domain/models/plant_enums.dart';
import '../../domain/models/plant_event.dart';
import '../../l10n/generated/app_localizations.dart';
import '../common/enum_labels.dart';
import '../common/formatting.dart';
import '../common/l10n_extensions.dart';
import '../quick_log/quick_log.dart';

final photoPathProvider = FutureProvider.family<String?, String>((ref, photoRef) async {
  return ref.watch(photoStoreProvider).getPhotoPath(photoRef);
});

/// Perfil da planta: dados estáveis no topo, linha do tempo abaixo.
class PlantProfileScreen extends ConsumerStatefulWidget {
  const PlantProfileScreen({super.key, required this.plantId});

  static const String route = '/plants/profile';

  final String plantId;

  @override
  ConsumerState<PlantProfileScreen> createState() => _PlantProfileScreenState();
}

class _PlantProfileScreenState extends ConsumerState<PlantProfileScreen> {
  Plant? _plant;
  List<PlantEvent>? _events;
  bool _loadRequested = false;
  bool _isLoadingMore = false;
  bool _hasMoreEvents = true;
  static const int _pageSize = 20;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreEvents();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loadRequested) {
      _loadRequested = true;
      _reload();
    }
  }

  Future<void> _reload() async {
    final repository = ref.read(plantRepositoryProvider);
    final plant = await repository.getPlant(widget.plantId);
    final events = await repository.getEvents(widget.plantId, limit: _pageSize);
    if (mounted) {
      setState(() {
        _plant = plant;
        _events = events;
        _hasMoreEvents = events.length == _pageSize;
      });
    }
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMoreEvents || _events == null) return;
    
    setState(() => _isLoadingMore = true);
    
    final repository = ref.read(plantRepositoryProvider);
    final moreEvents = await repository.getEvents(
      widget.plantId,
      limit: _pageSize,
      offset: _events!.length,
    );
    
    if (mounted) {
      setState(() {
        _events!.addAll(moreEvents);
        _hasMoreEvents = moreEvents.length == _pageSize;
        _isLoadingMore = false;
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
              controller: _scrollController,
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
                else ...[
                  for (final event in events) _EventTile(event: event),
                  if (_isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ],
            ),
    );
  }
}

class _PlantHeader extends ConsumerWidget {
  const _PlantHeader({required this.plant});

  final Plant plant;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

    Widget? photoWidget;
    if (plant.photoRef != null) {
      final photoAsync = ref.watch(photoPathProvider(plant.photoRef!));
      photoWidget = photoAsync.when(
        data: (path) => path == null 
            ? const SizedBox.shrink()
            : ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
        loading: () => const SizedBox(
          width: 80,
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (_, __) => const SizedBox(
          width: 80,
          height: 80,
          child: Icon(Icons.error),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoWidget != null) ...[
            photoWidget,
            const SizedBox(width: 16),
          ],
          Expanded(
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
          ),
        ],
      ),
    );
  }
}

class _EventTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    final summary = _summary(l10n, event);
    final notes = event.notes?.trim();
    final showNotes =
        notes != null && notes.isNotEmpty && event is! ObservationAddedEvent;
    final mainText = event is ObservationAddedEvent
        ? notes ?? ''
        : summary ?? '';

    Widget? photoThumbnail;
    if (event is PhotoAddedEvent) {
      final ev = event as PhotoAddedEvent;
      if (ev.photoRef != null) {
        final photoAsync = ref.watch(photoPathProvider(ev.photoRef!));
        photoThumbnail = photoAsync.when(
          data: (path) => path == null 
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          loading: () => const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          ),
          error: (_, __) => const SizedBox.shrink(),
        );
      }
    }

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
                  if (photoThumbnail != null) photoThumbnail,
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
