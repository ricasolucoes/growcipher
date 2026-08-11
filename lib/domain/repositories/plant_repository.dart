import '../models/plant.dart';
import '../models/plant_enums.dart';
import '../models/plant_event.dart';

/// Contrato de persistência de plantas e da linha do tempo.
///
/// Invariantes que toda implementação deve garantir:
/// - criar uma planta registra um evento `plantCreated`;
/// - mudar a fase registra `phaseChanged` (com fase anterior e nova) além de
///   atualizar o snapshot em [Plant.phase];
/// - encerrar registra `plantEnded` e atualiza [Plant.status] — a planta e
///   seu histórico nunca são apagados.
abstract class PlantRepository {
  Future<List<Plant>> getPlants();

  Future<Plant?> getPlant(String id);

  /// Eventos da planta, mais recentes primeiro.
  Future<List<PlantEvent>> getEvents(String plantId);

  /// Persiste a planta e o evento `plantCreated` atomicamente.
  ///
  /// [extraEvents] permite gravar na mesma transação eventos que nasceram no
  /// cadastro (ex.: germinação informada no wizard).
  Future<Plant> createPlant(
    Plant plant, {
    List<PlantEvent> extraEvents = const [],
  });

  /// Grava um acontecimento na linha do tempo.
  Future<void> addEvent(PlantEvent event);

  /// Registra `phaseChanged` e atualiza o snapshot da fase.
  Future<Plant> changePhase({
    required String plantId,
    required PlantPhase newPhase,
    DateTime? occurredAt,
    String? notes,
  });

  /// Registra `plantEnded` e atualiza o status conforme o motivo.
  /// Nunca remove a planta nem seus eventos.
  Future<Plant> endPlant({
    required String plantId,
    required PlantEndReason reason,
    PlantEndCause? cause,
    DateTime? occurredAt,
    String? notes,
  });
}
