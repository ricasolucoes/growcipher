import '../domain/models/plant.dart';
import '../domain/models/plant_enums.dart';
import '../domain/models/plant_event.dart';
import '../domain/repositories/gamification_repository.dart';
import '../domain/repositories/plant_repository.dart';

/// Decora um [PlantRepository] aplicando a progressão local a cada evento
/// que entra na linha do tempo.
///
/// A progressão é derivada: este decorador só lê o que o repositório real
/// gravou e alimenta a camada de gamificação. Se ele for removido da
/// composição, o app continua registrando cultivo normalmente — apenas para
/// de pontuar (`docs/Principios.md` → Progressão local).
///
/// Falha na progressão nunca derruba um registro de cultivo: o dado do
/// usuário é a prioridade, o XP é consequência.
class GamifiedPlantRepository implements PlantRepository {
  GamifiedPlantRepository({
    required this.inner,
    required this.gamification,
    this.onProgressError,
  });

  final PlantRepository inner;
  final GamificationRepository gamification;

  /// Chamado quando a progressão falha; o registro de cultivo segue válido.
  final void Function(Object error, StackTrace stack)? onProgressError;

  @override
  Future<List<Plant>> getPlants() => inner.getPlants();

  @override
  Future<Plant?> getPlant(String id) => inner.getPlant(id);

  @override
  Future<List<PlantEvent>> getEvents(String plantId) =>
      inner.getEvents(plantId);

  @override
  Future<Plant> createPlant(
    Plant plant, {
    List<PlantEvent> extraEvents = const [],
  }) async {
    final since = _mark();
    final created = await inner.createPlant(plant, extraEvents: extraEvents);
    await _scoreRecentEvents(created, since);
    return created;
  }

  @override
  Future<void> addEvent(PlantEvent event) async {
    await inner.addEvent(event);
    final plant = await inner.getPlant(event.plantId);
    if (plant != null) await _score(event, plant);
  }

  @override
  Future<Plant> changePhase({
    required String plantId,
    required PlantPhase newPhase,
    DateTime? occurredAt,
    String? notes,
  }) async {
    final since = _mark();
    final plant = await inner.changePhase(
      plantId: plantId,
      newPhase: newPhase,
      occurredAt: occurredAt,
      notes: notes,
    );
    await _scoreRecentEvents(plant, since);
    return plant;
  }

  @override
  Future<Plant> endPlant({
    required String plantId,
    required PlantEndReason reason,
    PlantEndCause? cause,
    DateTime? occurredAt,
    String? notes,
  }) async {
    final since = _mark();
    final plant = await inner.endPlant(
      plantId: plantId,
      reason: reason,
      cause: cause,
      occurredAt: occurredAt,
      notes: notes,
    );
    await _scoreRecentEvents(plant, since);
    return plant;
  }

  /// Margem de um segundo: o repositório interno carimba `createdAt` com o
  /// relógio dele, que pode ter granularidade diferente da nossa marcação.
  DateTime _mark() =>
      DateTime.now().subtract(const Duration(seconds: 1));

  /// Pontua os eventos gravados desde [since] — cobre operações que criam o
  /// evento internamente (cadastro, mudança de fase, encerramento).
  Future<void> _scoreRecentEvents(Plant plant, DateTime since) async {
    try {
      final events = await inner.getEvents(plant.id);
      // Vêm em ordem decrescente; pontua-se do mais antigo para o mais novo
      // para a sequência diária avançar na ordem certa.
      final recent = events
          .where((event) => event.createdAt.isAfter(since))
          .toList()
          .reversed;

      for (final event in recent) {
        await gamification.registerEvent(event: event, plant: plant);
      }
    } catch (error, stack) {
      onProgressError?.call(error, stack);
    }
  }

  Future<void> _score(PlantEvent event, Plant plant) async {
    try {
      await gamification.registerEvent(event: event, plant: plant);
    } catch (error, stack) {
      onProgressError?.call(error, stack);
    }
  }
}
