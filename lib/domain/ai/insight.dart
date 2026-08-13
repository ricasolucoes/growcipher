import '../gamification/completeness.dart';
import '../models/plant.dart';
import '../models/plant_event.dart';

/// Espécies de conclusão que a camada determinística sabe tirar
/// (`docs/IA.md` §1).
enum InsightKind {
  wateringOverdue,
  phaseLongerThanUsual,
  measurementOutOfBaseline,
  incompleteProfile,
  noRecentPhoto,
  problemWithoutFollowUp,
  harvestWindow,
  streakAtRisk,
}

enum InsightSeverity { info, attention, urgent }

/// Uma conclusão sobre o histórico do próprio usuário.
///
/// Sem texto pronto: o domínio entrega espécie, severidade e evidência
/// numérica; a interface traduz via ARB. Sugestão, nunca ordem
/// (`docs/Principios.md` → Inteligência no aparelho).
class Insight {
  const Insight({
    required this.kind,
    required this.severity,
    this.plantId,
    this.subject,
    this.evidence = const {},
    this.missingFields = const [],
  });

  final InsightKind kind;
  final InsightSeverity severity;
  final String? plantId;

  /// Qualificador da espécie quando ela se aplica a mais de uma grandeza
  /// (ex.: `ph`, `temperatureC` em [InsightKind.measurementOutOfBaseline]).
  final String? subject;

  /// Números que sustentam a conclusão, prontos para virar parâmetro de
  /// tradução. O usuário vê a evidência, não um veredito opaco.
  final Map<String, num> evidence;

  /// Campos faltantes, quando a espécie é [InsightKind.incompleteProfile].
  final List<CompletenessField> missingFields;
}

/// Planta com a linha do tempo dela, entrada do motor de análise.
class PlantHistory {
  const PlantHistory({required this.plant, required this.events});

  final Plant plant;

  /// Eventos em qualquer ordem — o motor ordena o que precisar.
  final List<PlantEvent> events;
}
