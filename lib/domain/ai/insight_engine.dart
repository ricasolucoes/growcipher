import 'dart:math' as math;

import '../gamification/completeness.dart';
import '../gamification/gamification_state.dart';
import '../models/plant_enums.dart';
import '../models/plant_event.dart';
import 'insight.dart';

/// Parâmetros do motor. Todos são escolhas de produto sobre *documentação*
/// do cultivo — nunca faixas agronômicas universais, que a doutrina proíbe
/// (`docs/IA.md` §1).
class InsightConfig {
  const InsightConfig({
    this.overdueFactor = 1.5,
    this.urgentFactor = 2.5,
    this.baselineSigmas = 2.0,
    this.followUpGraceDays = 3,
    this.minIntervalSamples = 2,
    this.minBaselineSamples = 5,
    this.incompleteProfileBelow = 0.6,
    this.maxMissingFieldsListed = 3,
  });

  /// Quanto o intervalo atual precisa passar da mediana do próprio usuário.
  final double overdueFactor;
  final double urgentFactor;

  /// Desvios-padrão da linha de base para considerar uma medição destoante.
  final double baselineSigmas;

  final int followUpGraceDays;
  final int minIntervalSamples;
  final int minBaselineSamples;
  final double incompleteProfileBelow;
  final int maxMissingFieldsListed;
}

/// Camada 1 da IA: estatística determinística sobre o histórico do próprio
/// usuário. Função pura, sem I/O, sem modelo, sem rede — roda em qualquer
/// aparelho e é o piso do qual as camadas opcionais nunca são pré-requisito.
class InsightEngine {
  const InsightEngine({this.config = const InsightConfig()});

  final InsightConfig config;

  List<Insight> analyze({
    required List<PlantHistory> histories,
    required DateTime now,
    GamificationState? progress,
  }) {
    final insights = <Insight>[];
    final phaseDurations = _phaseDurationsAcross(histories);
    final baselines = _measurementBaselines(histories);
    final floweringToHarvest = _floweringToHarvestDays(histories);

    for (final history in histories) {
      if (history.plant.status != PlantStatus.active) continue;

      insights.addAll([
        ?_wateringOverdue(history, now),
        ?_incompleteProfile(history),
        ?_noRecentPhoto(history, now),
        ?_problemWithoutFollowUp(history, now),
        ?_phaseLongerThanUsual(history, now, phaseDurations),
        ?_harvestWindow(history, now, floweringToHarvest),
      ]);
      insights.addAll(_measurementsOutOfBaseline(history, baselines));
    }

    final streak = _streakAtRisk(progress, now);
    if (streak != null) insights.add(streak);

    insights.sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return insights;
  }

  // --- Regras -------------------------------------------------------------

  /// Rega atrasada frente à cadência que *esta* planta vinha tendo.
  Insight? _wateringOverdue(PlantHistory history, DateTime now) {
    final waterings = _sortedDates(history, PlantEventType.watered);
    if (waterings.length < config.minIntervalSamples + 1) return null;

    final typical = _medianIntervalDays(waterings);
    if (typical == null || typical <= 0) return null;

    final sinceLast = _daysBetween(waterings.last, now);
    if (sinceLast <= typical * config.overdueFactor) return null;

    return Insight(
      kind: InsightKind.wateringOverdue,
      severity: sinceLast > typical * config.urgentFactor
          ? InsightSeverity.urgent
          : InsightSeverity.attention,
      plantId: history.plant.id,
      evidence: {'daysSinceLast': sinceLast, 'typicalIntervalDays': typical},
    );
  }

  Insight? _incompleteProfile(PlantHistory history) {
    final completeness = completenessOf(history.plant);
    if (completeness.fraction >= config.incompleteProfileBelow) return null;

    return Insight(
      kind: InsightKind.incompleteProfile,
      severity: InsightSeverity.info,
      plantId: history.plant.id,
      evidence: {'percent': completeness.percent},
      missingFields: completeness.missing
          .take(config.maxMissingFieldsListed)
          .toList(),
    );
  }

  /// Só dispara para quem já fotografa: a cadência vem do próprio histórico.
  Insight? _noRecentPhoto(PlantHistory history, DateTime now) {
    final photos = _sortedDates(history, PlantEventType.photoAdded);
    if (photos.length < config.minIntervalSamples + 1) return null;

    final typical = _medianIntervalDays(photos);
    if (typical == null || typical <= 0) return null;

    final sinceLast = _daysBetween(photos.last, now);
    if (sinceLast <= typical * config.overdueFactor) return null;

    return Insight(
      kind: InsightKind.noRecentPhoto,
      severity: InsightSeverity.info,
      plantId: history.plant.id,
      evidence: {'daysSinceLast': sinceLast, 'typicalIntervalDays': typical},
    );
  }

  /// Problema registrado e nenhum acompanhamento depois dele.
  Insight? _problemWithoutFollowUp(PlantHistory history, DateTime now) {
    final problems = history.events.whereType<ProblemReportedEvent>().toList()
      ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    if (problems.isEmpty) return null;

    final last = problems.last;
    final elapsed = _daysBetween(last.occurredAt, now);
    if (elapsed < config.followUpGraceDays) return null;

    const followUps = {
      PlantEventType.treatmentApplied,
      PlantEventType.observationAdded,
      PlantEventType.photoAdded,
      PlantEventType.measurementAdded,
    };
    final hasFollowUp = history.events.any(
      (event) =>
          followUps.contains(event.type) &&
          event.occurredAt.isAfter(last.occurredAt),
    );
    if (hasFollowUp) return null;

    return Insight(
      kind: InsightKind.problemWithoutFollowUp,
      severity: InsightSeverity.attention,
      plantId: history.plant.id,
      subject: last.category.name,
      evidence: {'daysSince': elapsed},
    );
  }

  /// Fase atual durando mais que a mediana das plantas anteriores do usuário.
  Insight? _phaseLongerThanUsual(
    PlantHistory history,
    DateTime now,
    Map<PlantPhase, List<double>> durations,
  ) {
    final phase = history.plant.phase;
    if (phase == PlantPhase.unknown) return null;

    final samples = durations[phase];
    if (samples == null || samples.length < config.minIntervalSamples) {
      return null;
    }

    final startedAt = _currentPhaseStart(history);
    if (startedAt == null) return null;

    final typical = _median(samples);
    if (typical <= 0) return null;

    final elapsed = _daysBetween(startedAt, now);
    if (elapsed <= typical * config.overdueFactor) return null;

    return Insight(
      kind: InsightKind.phaseLongerThanUsual,
      severity: InsightSeverity.info,
      plantId: history.plant.id,
      subject: phase.name,
      evidence: {'daysInPhase': elapsed, 'typicalDays': typical},
    );
  }

  /// Medição mais recente destoando da linha de base do próprio usuário.
  List<Insight> _measurementsOutOfBaseline(
    PlantHistory history,
    Map<String, _Baseline> baselines,
  ) {
    final measurements =
        history.events.whereType<MeasurementAddedEvent>().toList()
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
    if (measurements.isEmpty) return const [];

    final latest = measurements.last;
    final values = _metricsOf(latest);
    final insights = <Insight>[];

    for (final entry in values.entries) {
      final baseline = baselines[entry.key];
      if (baseline == null) continue;

      final deviation = baseline.deviationOf(entry.value);
      if (deviation == null || deviation.abs() < config.baselineSigmas) {
        continue;
      }

      insights.add(
        Insight(
          kind: InsightKind.measurementOutOfBaseline,
          severity: InsightSeverity.attention,
          plantId: history.plant.id,
          subject: entry.key,
          evidence: {
            'value': entry.value,
            'baseline': baseline.mean,
            'sigmas': deviation.abs(),
          },
        ),
      );
    }

    return insights;
  }

  /// Janela de colheita projetada dos ciclos que o próprio usuário fechou.
  Insight? _harvestWindow(
    PlantHistory history,
    DateTime now,
    List<double> samples,
  ) {
    if (history.plant.phase != PlantPhase.flowering) return null;
    if (samples.length < config.minIntervalSamples) return null;

    final startedAt = _currentPhaseStart(history);
    if (startedAt == null) return null;

    final typical = _median(samples);
    final elapsed = _daysBetween(startedAt, now);

    return Insight(
      kind: InsightKind.harvestWindow,
      severity: InsightSeverity.info,
      plantId: history.plant.id,
      evidence: {
        'daysInFlowering': elapsed,
        'typicalFloweringDays': typical,
        'daysRemaining': typical - elapsed,
      },
    );
  }

  /// Único insight que a camada de progressão dispara.
  Insight? _streakAtRisk(GamificationState? progress, DateTime now) {
    if (progress == null || progress.currentStreak < 3) return null;

    final last = progress.lastActivityDay;
    if (last == null) return null;

    final gap = _daysBetween(
      DateTime(last.year, last.month, last.day),
      DateTime(now.year, now.month, now.day),
    );
    if (gap != 1) return null;

    return Insight(
      kind: InsightKind.streakAtRisk,
      severity: InsightSeverity.attention,
      evidence: {'streak': progress.currentStreak},
    );
  }

  // --- Agregados sobre todo o histórico -----------------------------------

  Map<PlantPhase, List<double>> _phaseDurationsAcross(
    List<PlantHistory> histories,
  ) {
    final durations = <PlantPhase, List<double>>{};

    for (final history in histories) {
      final changes = history.events.whereType<PhaseChangedEvent>().toList()
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

      for (var i = 0; i < changes.length - 1; i++) {
        final phase = changes[i].newPhase;
        if (phase == PlantPhase.unknown) continue;
        final days = _daysBetween(
          changes[i].occurredAt,
          changes[i + 1].occurredAt,
        );
        if (days > 0) durations.putIfAbsent(phase, () => []).add(days);
      }
    }

    return durations;
  }

  List<double> _floweringToHarvestDays(List<PlantHistory> histories) {
    final samples = <double>[];

    for (final history in histories) {
      final flowering =
          history.events
              .whereType<PhaseChangedEvent>()
              .where((event) => event.newPhase == PlantPhase.flowering)
              .toList()
            ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
      if (flowering.isEmpty) continue;

      final harvests = history.events.whereType<HarvestedEvent>().toList()
        ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));
      if (harvests.isEmpty) continue;

      final days = _daysBetween(
        flowering.first.occurredAt,
        harvests.first.occurredAt,
      );
      if (days > 0) samples.add(days);
    }

    return samples;
  }

  Map<String, _Baseline> _measurementBaselines(List<PlantHistory> histories) {
    final samples = <String, List<double>>{};

    for (final history in histories) {
      for (final event in history.events.whereType<MeasurementAddedEvent>()) {
        _metricsOf(event).forEach((metric, value) {
          samples.putIfAbsent(metric, () => []).add(value);
        });
      }
    }

    final baselines = <String, _Baseline>{};
    samples.forEach((metric, values) {
      if (values.length >= config.minBaselineSamples) {
        baselines[metric] = _Baseline.of(values);
      }
    });
    return baselines;
  }

  Map<String, double> _metricsOf(MeasurementAddedEvent event) {
    return {
      if (event.temperatureC != null) 'temperatureC': event.temperatureC!,
      if (event.humidityPercent != null)
        'humidityPercent': event.humidityPercent!,
      if (event.ph != null) 'ph': event.ph!,
      if (event.ec != null) 'ec': event.ec!,
      if (event.vpd != null) 'vpd': event.vpd!,
      if (event.dli != null) 'dli': event.dli!,
    };
  }

  /// Quando a planta entrou na fase atual: última mudança para ela, ou o
  /// início da planta se a fase nunca foi registrada como mudança.
  DateTime? _currentPhaseStart(PlantHistory history) {
    final entries =
        history.events
            .whereType<PhaseChangedEvent>()
            .where((event) => event.newPhase == history.plant.phase)
            .toList()
          ..sort((a, b) => a.occurredAt.compareTo(b.occurredAt));

    if (entries.isNotEmpty) return entries.last.occurredAt;
    return history.plant.startDate;
  }

  List<DateTime> _sortedDates(PlantHistory history, PlantEventType type) {
    return history.events
        .where((event) => event.type == type)
        .map((event) => event.occurredAt)
        .toList()
      ..sort();
  }

  double? _medianIntervalDays(List<DateTime> sortedDates) {
    if (sortedDates.length < 2) return null;
    final intervals = <double>[];
    for (var i = 1; i < sortedDates.length; i++) {
      intervals.add(_daysBetween(sortedDates[i - 1], sortedDates[i]));
    }
    return _median(intervals);
  }

  double _daysBetween(DateTime from, DateTime to) =>
      to.difference(from).inMinutes / (60 * 24);

  double _median(List<double> values) {
    final sorted = [...values]..sort();
    final middle = sorted.length ~/ 2;
    if (sorted.isEmpty) return 0;
    return sorted.length.isOdd
        ? sorted[middle]
        : (sorted[middle - 1] + sorted[middle]) / 2;
  }
}

class _Baseline {
  const _Baseline({required this.mean, required this.deviation});

  factory _Baseline.of(List<double> values) {
    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values
            .map((value) => math.pow(value - mean, 2).toDouble())
            .reduce((a, b) => a + b) /
        values.length;
    return _Baseline(mean: mean, deviation: math.sqrt(variance));
  }

  final double mean;
  final double deviation;

  /// Em quantos desvios-padrão o valor está do que o usuário costuma medir.
  double? deviationOf(double value) {
    if (deviation <= 0) return null;
    return (value - mean) / deviation;
  }
}
