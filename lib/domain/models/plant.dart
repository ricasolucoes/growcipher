import 'plant_enums.dart';

/// Dados relativamente estáveis de uma planta.
///
/// Os acontecimentos cronológicos (rega, mudança de fase, encerramento…)
/// não vivem aqui: são [PlantEvent]s na linha do tempo. `phase` e `status`
/// são snapshots de conveniência — toda alteração deles precisa passar pelo
/// repositório, que registra o evento correspondente antes de atualizar o
/// snapshot.
class Plant {
  const Plant({
    required this.id,
    this.displayName,
    required this.privacyCode,
    this.photoRef,
    required this.startingPoint,
    this.origin = PlantOrigin.unknown,
    this.originDetails,
    this.strain,
    this.geneticType = PlantGeneticType.unknown,
    this.startDate,
    this.startDateIsApproximate = false,
    this.seedObtainedDate,
    this.rootedDate,
    this.environment = GrowingEnvironment.unknown,
    this.environmentPlace,
    this.environmentName,
    this.growingMedium = GrowingMedium.unknown,
    this.containerType,
    this.containerVolumeLiters,
    this.irrigationMode = IrrigationMode.undefined,
    this.irrigationSystem,
    this.phase = PlantPhase.unknown,
    this.status = PlantStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;

  /// Nome dado pelo usuário. Opcional: a planta pode viver só com o código.
  final String? displayName;

  /// Código local discreto (ex.: `GC-7F2A`), gerado no aparelho.
  final String privacyCode;

  /// Referência opaca para o `PhotoStore` (galeria privada, fase futura).
  final String? photoRef;

  final PlantStartingPoint startingPoint;
  final PlantOrigin origin;
  final String? originDetails;
  final String? strain;
  final PlantGeneticType geneticType;

  /// Início da planta sob os cuidados do usuário (plantio da semente, chegada
  /// do clone, início aproximado de um cultivo em andamento).
  final DateTime? startDate;
  final bool startDateIsApproximate;

  /// Quando a semente foi obtida, se o usuário souber.
  final DateTime? seedObtainedDate;

  /// Quando o clone enraizou, se o usuário souber.
  final DateTime? rootedDate;

  final GrowingEnvironment environment;
  final EnvironmentPlace? environmentPlace;
  final String? environmentName;
  final GrowingMedium growingMedium;
  final String? containerType;
  final double? containerVolumeLiters;
  final IrrigationMode irrigationMode;
  final IrrigationSystem? irrigationSystem;

  /// Snapshot da fase atual; o histórico fica nos eventos `phaseChanged`.
  final PlantPhase phase;

  /// Snapshot do status; encerramentos são registrados como `plantEnded`.
  final PlantStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;

  /// Como a planta se apresenta na interface: nome, ou o código local.
  String get displayLabel {
    final name = displayName?.trim();
    return (name == null || name.isEmpty) ? privacyCode : name;
  }

  Plant copyWith({
    PlantPhase? phase,
    PlantStatus? status,
    DateTime? updatedAt,
  }) {
    return Plant(
      id: id,
      displayName: displayName,
      privacyCode: privacyCode,
      photoRef: photoRef,
      startingPoint: startingPoint,
      origin: origin,
      originDetails: originDetails,
      strain: strain,
      geneticType: geneticType,
      startDate: startDate,
      startDateIsApproximate: startDateIsApproximate,
      seedObtainedDate: seedObtainedDate,
      rootedDate: rootedDate,
      environment: environment,
      environmentPlace: environmentPlace,
      environmentName: environmentName,
      growingMedium: growingMedium,
      containerType: containerType,
      containerVolumeLiters: containerVolumeLiters,
      irrigationMode: irrigationMode,
      irrigationSystem: irrigationSystem,
      phase: phase ?? this.phase,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
