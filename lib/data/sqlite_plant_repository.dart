import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/identifiers.dart';
import '../domain/models/plant.dart';
import '../domain/models/plant_enums.dart';
import '../domain/models/plant_event.dart';
import '../domain/repositories/plant_repository.dart';

/// Implementação SQLite (sqflite) do [PlantRepository].
///
/// Operações que tocam snapshot + linha do tempo (criação, mudança de fase,
/// encerramento) rodam em transação para o histórico nunca divergir do
/// estado atual.
class SqlitePlantRepository implements PlantRepository {
  SqlitePlantRepository(this._db);

  final Database _db;

  @override
  Future<List<Plant>> getPlants() async {
    final rows = await _db.query('plants', orderBy: 'created_at DESC');
    return rows.map(_plantFromRow).toList();
  }

  @override
  Future<Plant?> getPlant(String id) async {
    final rows = await _db.query(
      'plants',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : _plantFromRow(rows.first);
  }

  @override
  Future<List<PlantEvent>> getEvents(String plantId) async {
    final rows = await _db.query(
      'plant_events',
      where: 'plant_id = ?',
      whereArgs: [plantId],
      orderBy: 'occurred_at DESC, created_at DESC',
    );
    return rows.map(_eventFromRow).toList();
  }

  @override
  Future<Plant> createPlant(
    Plant plant, {
    List<PlantEvent> extraEvents = const [],
  }) async {
    final created = PlantCreatedEvent(
      id: generateLocalId(),
      plantId: plant.id,
      occurredAt: plant.createdAt,
      createdAt: plant.createdAt,
    );

    await _db.transaction((txn) async {
      await txn.insert('plants', _plantToRow(plant));
      await txn.insert('plant_events', _eventToRow(created));
      for (final event in extraEvents) {
        await txn.insert('plant_events', _eventToRow(event));
      }
    });
    return plant;
  }

  @override
  Future<void> addEvent(PlantEvent event) async {
    await _db.insert('plant_events', _eventToRow(event));
  }

  @override
  Future<Plant> changePhase({
    required String plantId,
    required PlantPhase newPhase,
    DateTime? occurredAt,
    String? notes,
  }) async {
    final now = DateTime.now();
    final plant = await _requirePlant(plantId);

    final event = PhaseChangedEvent(
      id: generateLocalId(),
      plantId: plantId,
      occurredAt: occurredAt ?? now,
      createdAt: now,
      notes: notes,
      previousPhase: plant.phase,
      newPhase: newPhase,
    );
    final updated = plant.copyWith(phase: newPhase, updatedAt: now);

    await _writeEventAndSnapshot(event, updated);
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
    final plant = await _requirePlant(plantId);

    final event = PlantEndedEvent(
      id: generateLocalId(),
      plantId: plantId,
      occurredAt: occurredAt ?? now,
      createdAt: now,
      notes: notes,
      reason: reason,
      cause: cause,
    );
    final updated = plant.copyWith(status: _statusFor(reason), updatedAt: now);

    await _writeEventAndSnapshot(event, updated);
    return updated;
  }

  Future<Plant> _requirePlant(String id) async {
    final plant = await getPlant(id);
    if (plant == null) {
      throw StateError('Planta não encontrada: $id');
    }
    return plant;
  }

  Future<void> _writeEventAndSnapshot(PlantEvent event, Plant snapshot) {
    return _db.transaction((txn) async {
      await txn.insert('plant_events', _eventToRow(event));
      await txn.update(
        'plants',
        _plantToRow(snapshot),
        where: 'id = ?',
        whereArgs: [snapshot.id],
      );
    });
  }

  static PlantStatus _statusFor(PlantEndReason reason) => switch (reason) {
    PlantEndReason.harvestCompleted => PlantStatus.completed,
    PlantEndReason.died => PlantStatus.died,
    PlantEndReason.discarded => PlantStatus.discarded,
    PlantEndReason.interrupted => PlantStatus.interrupted,
    PlantEndReason.other => PlantStatus.interrupted,
  };

  // --- mapeamento linha <-> modelo ---

  static Map<String, Object?> _plantToRow(Plant plant) => {
    'id': plant.id,
    'display_name': plant.displayName,
    'privacy_code': plant.privacyCode,
    'photo_ref': plant.photoRef,
    'starting_point': plant.startingPoint.name,
    'origin': plant.origin.name,
    'origin_details': plant.originDetails,
    'strain': plant.strain,
    'genetic_type': plant.geneticType.name,
    'start_date': plant.startDate?.millisecondsSinceEpoch,
    'start_date_is_approximate': plant.startDateIsApproximate ? 1 : 0,
    'seed_obtained_date': plant.seedObtainedDate?.millisecondsSinceEpoch,
    'rooted_date': plant.rootedDate?.millisecondsSinceEpoch,
    'environment': plant.environment.name,
    'environment_place': plant.environmentPlace?.name,
    'environment_name': plant.environmentName,
    'growing_medium': plant.growingMedium.name,
    'container_type': plant.containerType,
    'container_volume_liters': plant.containerVolumeLiters,
    'irrigation_mode': plant.irrigationMode.name,
    'irrigation_system': plant.irrigationSystem?.name,
    'phase': plant.phase.name,
    'status': plant.status.name,
    'created_at': plant.createdAt.millisecondsSinceEpoch,
    'updated_at': plant.updatedAt.millisecondsSinceEpoch,
  };

  static Plant _plantFromRow(Map<String, Object?> row) {
    DateTime? date(String column) {
      final value = row[column] as int?;
      return value == null ? null : DateTime.fromMillisecondsSinceEpoch(value);
    }

    String? nullableName(String column) => row[column] as String?;

    return Plant(
      id: row['id'] as String,
      displayName: row['display_name'] as String?,
      privacyCode: row['privacy_code'] as String,
      photoRef: row['photo_ref'] as String?,
      startingPoint: enumFromName(
        PlantStartingPoint.values,
        row['starting_point'] as String?,
        PlantStartingPoint.inProgress,
      ),
      origin: enumFromName(
        PlantOrigin.values,
        row['origin'] as String?,
        PlantOrigin.unknown,
      ),
      originDetails: row['origin_details'] as String?,
      strain: row['strain'] as String?,
      geneticType: enumFromName(
        PlantGeneticType.values,
        row['genetic_type'] as String?,
        PlantGeneticType.unknown,
      ),
      startDate: date('start_date'),
      startDateIsApproximate:
          (row['start_date_is_approximate'] as int? ?? 0) == 1,
      seedObtainedDate: date('seed_obtained_date'),
      rootedDate: date('rooted_date'),
      environment: enumFromName(
        GrowingEnvironment.values,
        row['environment'] as String?,
        GrowingEnvironment.unknown,
      ),
      environmentPlace: nullableName('environment_place') == null
          ? null
          : enumFromName(
              EnvironmentPlace.values,
              nullableName('environment_place'),
              EnvironmentPlace.other,
            ),
      environmentName: row['environment_name'] as String?,
      growingMedium: enumFromName(
        GrowingMedium.values,
        row['growing_medium'] as String?,
        GrowingMedium.unknown,
      ),
      containerType: row['container_type'] as String?,
      containerVolumeLiters: (row['container_volume_liters'] as num?)
          ?.toDouble(),
      irrigationMode: enumFromName(
        IrrigationMode.values,
        row['irrigation_mode'] as String?,
        IrrigationMode.undefined,
      ),
      irrigationSystem: nullableName('irrigation_system') == null
          ? null
          : enumFromName(
              IrrigationSystem.values,
              nullableName('irrigation_system'),
              IrrigationSystem.other,
            ),
      phase: enumFromName(
        PlantPhase.values,
        row['phase'] as String?,
        PlantPhase.unknown,
      ),
      status: enumFromName(
        PlantStatus.values,
        row['status'] as String?,
        PlantStatus.active,
      ),
      createdAt: date('created_at') ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: date('updated_at') ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static Map<String, Object?> _eventToRow(PlantEvent event) {
    final payload = Map<String, Object?>.of(event.payloadToMap())
      ..removeWhere((_, value) => value == null);
    return {
      'id': event.id,
      'plant_id': event.plantId,
      'type': event.type.name,
      'occurred_at': event.occurredAt.millisecondsSinceEpoch,
      'created_at': event.createdAt.millisecondsSinceEpoch,
      'notes': event.notes,
      'payload': jsonEncode(payload),
    };
  }

  static PlantEvent _eventFromRow(Map<String, Object?> row) {
    final rawPayload = row['payload'] as String? ?? '{}';
    Map<String, Object?> payload;
    try {
      payload = (jsonDecode(rawPayload) as Map<String, dynamic>)
          .cast<String, Object?>();
    } on FormatException {
      payload = const {};
    }

    return PlantEvent.fromRecord(
      id: row['id'] as String,
      plantId: row['plant_id'] as String,
      typeName: row['type'] as String? ?? '',
      occurredAt: DateTime.fromMillisecondsSinceEpoch(
        row['occurred_at'] as int,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at'] as int),
      notes: row['notes'] as String?,
      payload: payload,
    );
  }
}
