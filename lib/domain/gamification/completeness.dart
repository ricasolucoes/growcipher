import '../models/plant.dart';
import '../models/plant_enums.dart';

/// Campos que compõem a completude do perfil de uma planta.
enum CompletenessField {
  displayName,
  photo,
  strain,
  geneticType,
  origin,
  originDetails,
  startDate,
  seedObtainedDate,
  rootedDate,
  environment,
  environmentPlace,
  environmentName,
  growingMedium,
  containerType,
  containerVolume,
  irrigationMode,
  irrigationSystem,
  phase,
}

/// Um item avaliado, com peso e a condição de "preenchido".
class CompletenessItem {
  const CompletenessItem({
    required this.field,
    required this.weight,
    required this.isFilled,
    this.appliesTo,
  });

  final CompletenessField field;
  final int weight;
  final bool Function(Plant plant) isFilled;

  /// Quando presente, o item só entra na conta para estes pontos de partida
  /// (não se cobra data de enraizamento de quem plantou semente).
  final Set<PlantStartingPoint>? appliesTo;

  bool appliesToPlant(Plant plant) =>
      appliesTo == null || appliesTo!.contains(plant.startingPoint);
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

/// Catálogo de itens e pesos (`docs/Gamificacao.md` §3).
///
/// Um enum em `unknown` conta como não preenchido: [Plant] colapsa "não sei"
/// e "ainda não respondi" no mesmo valor, e a completude mede informação
/// disponível, não intenção do usuário.
const List<CompletenessItem> completenessItems = [
  CompletenessItem(
    field: CompletenessField.displayName,
    weight: 1,
    isFilled: _hasDisplayName,
  ),
  CompletenessItem(
    field: CompletenessField.photo,
    weight: 2,
    isFilled: _hasPhoto,
  ),
  CompletenessItem(
    field: CompletenessField.strain,
    weight: 2,
    isFilled: _hasStrain,
  ),
  CompletenessItem(
    field: CompletenessField.geneticType,
    weight: 1,
    isFilled: _hasGeneticType,
  ),
  CompletenessItem(
    field: CompletenessField.origin,
    weight: 1,
    isFilled: _hasOrigin,
  ),
  CompletenessItem(
    field: CompletenessField.originDetails,
    weight: 1,
    isFilled: _hasOriginDetails,
  ),
  CompletenessItem(
    field: CompletenessField.startDate,
    weight: 2,
    isFilled: _hasStartDate,
  ),
  CompletenessItem(
    field: CompletenessField.seedObtainedDate,
    weight: 1,
    isFilled: _hasSeedObtainedDate,
    appliesTo: {PlantStartingPoint.seed},
  ),
  CompletenessItem(
    field: CompletenessField.rootedDate,
    weight: 1,
    isFilled: _hasRootedDate,
    appliesTo: {PlantStartingPoint.clone},
  ),
  CompletenessItem(
    field: CompletenessField.environment,
    weight: 2,
    isFilled: _hasEnvironment,
  ),
  CompletenessItem(
    field: CompletenessField.environmentPlace,
    weight: 1,
    isFilled: _hasEnvironmentPlace,
  ),
  CompletenessItem(
    field: CompletenessField.environmentName,
    weight: 1,
    isFilled: _hasEnvironmentName,
  ),
  CompletenessItem(
    field: CompletenessField.growingMedium,
    weight: 2,
    isFilled: _hasGrowingMedium,
  ),
  CompletenessItem(
    field: CompletenessField.containerType,
    weight: 1,
    isFilled: _hasContainerType,
  ),
  CompletenessItem(
    field: CompletenessField.containerVolume,
    weight: 1,
    isFilled: _hasContainerVolume,
  ),
  CompletenessItem(
    field: CompletenessField.irrigationMode,
    weight: 1,
    isFilled: _hasIrrigationMode,
  ),
  CompletenessItem(
    field: CompletenessField.irrigationSystem,
    weight: 1,
    isFilled: _hasIrrigationSystem,
  ),
  CompletenessItem(
    field: CompletenessField.phase,
    weight: 2,
    isFilled: _hasPhase,
  ),
];

bool _hasDisplayName(Plant p) => _hasText(p.displayName);
bool _hasPhoto(Plant p) => _hasText(p.photoRef);
bool _hasStrain(Plant p) => _hasText(p.strain);
bool _hasGeneticType(Plant p) => p.geneticType != PlantGeneticType.unknown;
bool _hasOrigin(Plant p) => p.origin != PlantOrigin.unknown;
bool _hasOriginDetails(Plant p) => _hasText(p.originDetails);
bool _hasStartDate(Plant p) => p.startDate != null;
bool _hasSeedObtainedDate(Plant p) => p.seedObtainedDate != null;
bool _hasRootedDate(Plant p) => p.rootedDate != null;
bool _hasEnvironment(Plant p) => p.environment != GrowingEnvironment.unknown;
bool _hasEnvironmentPlace(Plant p) => p.environmentPlace != null;
bool _hasEnvironmentName(Plant p) => _hasText(p.environmentName);
bool _hasGrowingMedium(Plant p) => p.growingMedium != GrowingMedium.unknown;
bool _hasContainerType(Plant p) => _hasText(p.containerType);
bool _hasContainerVolume(Plant p) => p.containerVolumeLiters != null;
bool _hasIrrigationMode(Plant p) =>
    p.irrigationMode != IrrigationMode.undefined;
bool _hasIrrigationSystem(Plant p) => p.irrigationSystem != null;
bool _hasPhase(Plant p) => p.phase != PlantPhase.unknown;

/// Retrato de completude de uma planta.
class PlantCompleteness {
  const PlantCompleteness({
    required this.earnedWeight,
    required this.totalWeight,
    required this.missing,
  });

  final int earnedWeight;
  final int totalWeight;

  /// O que falta, nomeado — barra de progresso sem lista é decoração
  /// (`docs/Gamificacao.md` §3).
  final List<CompletenessField> missing;

  double get fraction => totalWeight == 0 ? 0 : earnedWeight / totalWeight;

  int get percent => (fraction * 100).round();

  bool get isComplete => missing.isEmpty;

  /// Marcos já alcançados por esta planta, em ordem crescente.
  List<int> get reachedMilestones =>
      [50, 80, 100].where((milestone) => percent >= milestone).toList();
}

PlantCompleteness completenessOf(Plant plant) {
  var earned = 0;
  var total = 0;
  final missing = <CompletenessField>[];

  for (final item in completenessItems) {
    if (!item.appliesToPlant(plant)) continue;
    total += item.weight;
    if (item.isFilled(plant)) {
      earned += item.weight;
    } else {
      missing.add(item.field);
    }
  }

  return PlantCompleteness(
    earnedWeight: earned,
    totalWeight: total,
    missing: missing,
  );
}
