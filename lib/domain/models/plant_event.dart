import 'plant_enums.dart';

/// Tipos de acontecimento da linha do tempo.
enum PlantEventType {
  plantCreated,
  germinated,
  watered,
  fed,
  treatmentApplied,
  measurementAdded,
  transplanted,
  phaseChanged,
  photoAdded,
  observationAdded,
  problemReported,
  taskCompleted,
  harvested,
  plantEnded,
}

/// Um acontecimento cronológico de uma planta.
///
/// A linha do tempo é entidade de primeira classe: o histórico nunca é
/// representado pela alteração destrutiva do snapshot em [Plant]. Cada
/// subtipo carrega um payload tipado, serializado por [payloadToMap] e
/// reconstruído por [PlantEvent.fromRecord].
sealed class PlantEvent {
  const PlantEvent({
    required this.id,
    required this.plantId,
    required this.occurredAt,
    required this.createdAt,
    this.notes,
  });

  final String id;
  final String plantId;

  /// Quando o fato aconteceu (informado pelo usuário).
  final DateTime occurredAt;

  /// Quando o registro foi gravado no aparelho.
  final DateTime createdAt;

  final String? notes;

  PlantEventType get type;

  /// Campos específicos do subtipo, prontos para serialização.
  Map<String, Object?> payloadToMap() => const {};

  /// Reconstrói o subtipo correto a partir do registro persistido.
  static PlantEvent fromRecord({
    required String id,
    required String plantId,
    required String typeName,
    required DateTime occurredAt,
    required DateTime createdAt,
    String? notes,
    Map<String, Object?> payload = const {},
  }) {
    final type = enumFromName(
      PlantEventType.values,
      typeName,
      PlantEventType.observationAdded,
    );

    double? asDouble(String key) => (payload[key] as num?)?.toDouble();
    String? asString(String key) => payload[key] as String?;

    switch (type) {
      case PlantEventType.plantCreated:
        return PlantCreatedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
        );
      case PlantEventType.germinated:
        return GerminatedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
        );
      case PlantEventType.watered:
        return WateredEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          amount: asDouble('amount'),
          unit: asString('unit'),
          solutionType: asString('solutionType'),
        );
      case PlantEventType.fed:
        return FedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          product: asString('product'),
          amount: asDouble('amount'),
          unit: asString('unit'),
        );
      case PlantEventType.treatmentApplied:
        return TreatmentAppliedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          treatmentType: enumFromName(
            TreatmentType.values,
            asString('treatmentType'),
            TreatmentType.other,
          ),
          product: asString('product'),
          amount: asDouble('amount'),
          unit: asString('unit'),
          method: asString('method'),
        );
      case PlantEventType.measurementAdded:
        return MeasurementAddedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          temperatureC: asDouble('temperatureC'),
          humidityPercent: asDouble('humidityPercent'),
          ph: asDouble('ph'),
          ec: asDouble('ec'),
          vpd: asDouble('vpd'),
          dli: asDouble('dli'),
        );
      case PlantEventType.transplanted:
        return TransplantedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          containerType: asString('containerType'),
          containerVolumeLiters: asDouble('containerVolumeLiters'),
        );
      case PlantEventType.phaseChanged:
        return PhaseChangedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          previousPhase: enumFromName(
            PlantPhase.values,
            asString('previousPhase'),
            PlantPhase.unknown,
          ),
          newPhase: enumFromName(
            PlantPhase.values,
            asString('newPhase'),
            PlantPhase.unknown,
          ),
        );
      case PlantEventType.photoAdded:
        return PhotoAddedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          photoRef: asString('photoRef'),
        );
      case PlantEventType.observationAdded:
        return ObservationAddedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
        );
      case PlantEventType.problemReported:
        return ProblemReportedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          category: enumFromName(
            ProblemCategory.values,
            asString('category'),
            ProblemCategory.unknown,
          ),
          photoRef: asString('photoRef'),
        );
      case PlantEventType.taskCompleted:
        return TaskCompletedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          taskDescription: asString('taskDescription'),
        );
      case PlantEventType.harvested:
        return HarvestedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          wetWeight: asDouble('wetWeight'),
          dryWeight: asDouble('dryWeight'),
          unit: asString('unit'),
        );
      case PlantEventType.plantEnded:
        return PlantEndedEvent(
          id: id,
          plantId: plantId,
          occurredAt: occurredAt,
          createdAt: createdAt,
          notes: notes,
          reason: enumFromName(
            PlantEndReason.values,
            asString('reason'),
            PlantEndReason.other,
          ),
          cause: payload['cause'] == null
              ? null
              : enumFromName(
                  PlantEndCause.values,
                  asString('cause'),
                  PlantEndCause.unknown,
                ),
        );
    }
  }
}

class PlantCreatedEvent extends PlantEvent {
  const PlantCreatedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
  });

  @override
  PlantEventType get type => PlantEventType.plantCreated;
}

class GerminatedEvent extends PlantEvent {
  const GerminatedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
  });

  @override
  PlantEventType get type => PlantEventType.germinated;
}

class WateredEvent extends PlantEvent {
  const WateredEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    this.amount,
    this.unit,
    this.solutionType,
  });

  final double? amount;
  final String? unit;
  final String? solutionType;

  @override
  PlantEventType get type => PlantEventType.watered;

  @override
  Map<String, Object?> payloadToMap() => {
    'amount': amount,
    'unit': unit,
    'solutionType': solutionType,
  };
}

class FedEvent extends PlantEvent {
  const FedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    this.product,
    this.amount,
    this.unit,
  });

  final String? product;
  final double? amount;
  final String? unit;

  @override
  PlantEventType get type => PlantEventType.fed;

  @override
  Map<String, Object?> payloadToMap() => {
    'product': product,
    'amount': amount,
    'unit': unit,
  };
}

class TreatmentAppliedEvent extends PlantEvent {
  const TreatmentAppliedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    required this.treatmentType,
    this.product,
    this.amount,
    this.unit,
    this.method,
  });

  final TreatmentType treatmentType;
  final String? product;
  final double? amount;
  final String? unit;
  final String? method;

  @override
  PlantEventType get type => PlantEventType.treatmentApplied;

  @override
  Map<String, Object?> payloadToMap() => {
    'treatmentType': treatmentType.name,
    'product': product,
    'amount': amount,
    'unit': unit,
    'method': method,
  };
}

/// Medições ambientais/da solução. Todas opcionais: registra-se só o que
/// foi medido. Novas métricas entram como novos campos tipados.
class MeasurementAddedEvent extends PlantEvent {
  const MeasurementAddedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    this.temperatureC,
    this.humidityPercent,
    this.ph,
    this.ec,
    this.vpd,
    this.dli,
  });

  final double? temperatureC;
  final double? humidityPercent;
  final double? ph;
  final double? ec;
  final double? vpd;
  final double? dli;

  @override
  PlantEventType get type => PlantEventType.measurementAdded;

  @override
  Map<String, Object?> payloadToMap() => {
    'temperatureC': temperatureC,
    'humidityPercent': humidityPercent,
    'ph': ph,
    'ec': ec,
    'vpd': vpd,
    'dli': dli,
  };
}

class TransplantedEvent extends PlantEvent {
  const TransplantedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    this.containerType,
    this.containerVolumeLiters,
  });

  final String? containerType;
  final double? containerVolumeLiters;

  @override
  PlantEventType get type => PlantEventType.transplanted;

  @override
  Map<String, Object?> payloadToMap() => {
    'containerType': containerType,
    'containerVolumeLiters': containerVolumeLiters,
  };
}

class PhaseChangedEvent extends PlantEvent {
  const PhaseChangedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    required this.previousPhase,
    required this.newPhase,
  });

  final PlantPhase previousPhase;
  final PlantPhase newPhase;

  @override
  PlantEventType get type => PlantEventType.phaseChanged;

  @override
  Map<String, Object?> payloadToMap() => {
    'previousPhase': previousPhase.name,
    'newPhase': newPhase.name,
  };
}

class PhotoAddedEvent extends PlantEvent {
  const PhotoAddedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    this.photoRef,
  });

  /// Referência para o `PhotoStore`; nula enquanto a galeria privada
  /// (fase futura do roadmap) não existir.
  final String? photoRef;

  @override
  PlantEventType get type => PlantEventType.photoAdded;

  @override
  Map<String, Object?> payloadToMap() => {'photoRef': photoRef};
}

class ObservationAddedEvent extends PlantEvent {
  const ObservationAddedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
  });

  @override
  PlantEventType get type => PlantEventType.observationAdded;
}

class ProblemReportedEvent extends PlantEvent {
  const ProblemReportedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    required this.category,
    this.photoRef,
  });

  final ProblemCategory category;
  final String? photoRef;

  @override
  PlantEventType get type => PlantEventType.problemReported;

  @override
  Map<String, Object?> payloadToMap() => {
    'category': category.name,
    'photoRef': photoRef,
  };
}

class TaskCompletedEvent extends PlantEvent {
  const TaskCompletedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    this.taskDescription,
  });

  final String? taskDescription;

  @override
  PlantEventType get type => PlantEventType.taskCompleted;

  @override
  Map<String, Object?> payloadToMap() => {'taskDescription': taskDescription};
}

class HarvestedEvent extends PlantEvent {
  const HarvestedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    this.wetWeight,
    this.dryWeight,
    this.unit,
  });

  final double? wetWeight;
  final double? dryWeight;
  final String? unit;

  @override
  PlantEventType get type => PlantEventType.harvested;

  @override
  Map<String, Object?> payloadToMap() => {
    'wetWeight': wetWeight,
    'dryWeight': dryWeight,
    'unit': unit,
  };
}

class PlantEndedEvent extends PlantEvent {
  const PlantEndedEvent({
    required super.id,
    required super.plantId,
    required super.occurredAt,
    required super.createdAt,
    super.notes,
    required this.reason,
    this.cause,
  });

  final PlantEndReason reason;

  /// Causa opcional quando a planta morreu.
  final PlantEndCause? cause;

  @override
  PlantEventType get type => PlantEventType.plantEnded;

  @override
  Map<String, Object?> payloadToMap() => {
    'reason': reason.name,
    'cause': cause?.name,
  };
}
