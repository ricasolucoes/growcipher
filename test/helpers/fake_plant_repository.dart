import 'package:growcipher/domain/identifiers.dart';
import 'package:growcipher/domain/models/plant.dart';
import 'package:growcipher/domain/models/plant_enums.dart';
import 'package:growcipher/domain/models/plant_event.dart';
import 'package:growcipher/domain/repositories/plant_repository.dart';

/// Implementação em memória do [PlantRepository] para widget tests —
/// respeita as mesmas invariantes da implementação SQLite.
class FakePlantRepository implements PlantRepository {
  final Map<String, Plant> plants = {};
  final List<PlantEvent> events = [];

  @override
  Future<List<Plant>> getPlants() async =>
      plants.values.toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Future<Plant?> getPlant(String id) async => plants[id];

  @override
  Future<List<PlantEvent>> getEvents(String plantId) async =>
      events.where((event) => event.plantId == plantId).toList()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  @override
  Future<Plant> createPlant(
    Plant plant, {
    List<PlantEvent> extraEvents = const [],
  }) async {
    plants[plant.id] = plant;
    events.add(
      PlantCreatedEvent(
        id: generateLocalId(),
        plantId: plant.id,
        occurredAt: plant.createdAt,
        createdAt: plant.createdAt,
      ),
    );
    events.addAll(extraEvents);
    return plant;
  }

  @override
  Future<void> addEvent(PlantEvent event) async {
    events.add(event);
  }

  @override
  Future<Plant> changePhase({
    required String plantId,
    required PlantPhase newPhase,
    DateTime? occurredAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final plant = plants[plantId]!;
    events.add(
      PhaseChangedEvent(
        id: generateLocalId(),
        plantId: plantId,
        occurredAt: occurredAt ?? now,
        createdAt: now,
        notes: notes,
        previousPhase: plant.phase,
        newPhase: newPhase,
      ),
    );
    final updated = plant.copyWith(phase: newPhase, updatedAt: now);
    plants[plantId] = updated;
    return updated;
  }

  @override
  Future<Plant> endPlant({
    required String plantId,
    required PlantEndReason reason,
    PlantEndCause? cause,
    DateTime? occurredAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final plant = plants[plantId]!;
    events.add(
      PlantEndedEvent(
        id: generateLocalId(),
        plantId: plantId,
        occurredAt: occurredAt ?? now,
        createdAt: now,
        notes: notes,
        reason: reason,
        cause: cause,
      ),
    );
    final status = switch (reason) {
      PlantEndReason.harvestCompleted => PlantStatus.completed,
      PlantEndReason.died => PlantStatus.died,
      PlantEndReason.discarded => PlantStatus.discarded,
      PlantEndReason.interrupted ||
      PlantEndReason.other => PlantStatus.interrupted,
    };
    final updated = plant.copyWith(status: status, updatedAt: now);
    plants[plantId] = updated;
    return updated;
  }
}
