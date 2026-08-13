import '../gamification/gamification_engine.dart';
import '../gamification/gamification_state.dart';
import '../models/plant.dart';
import '../models/plant_event.dart';

/// Uma conquista destravada, com o momento em que caiu.
class UnlockedAchievement {
  const UnlockedAchievement({required this.id, required this.unlockedAt});

  final String id;
  final DateTime unlockedAt;
}

/// Contrato da progressão local.
///
/// Invariantes que toda implementação deve garantir:
/// - a camada é derivada: nenhuma escrita aqui altera plantas ou eventos;
/// - concessão de XP é idempotente por chave — reprocessar o mesmo evento
///   não paga de novo;
/// - conquista destravada nunca é removida.
abstract class GamificationRepository {
  Future<GamificationState> getState();

  /// Aplica a progressão referente a um evento recém-gravado.
  ///
  /// Devolve `null` quando o evento já havia sido processado.
  Future<GamificationOutcome?> registerEvent({
    required PlantEvent event,
    required Plant plant,
  });

  Future<List<UnlockedAchievement>> getUnlockedAchievements();
}
