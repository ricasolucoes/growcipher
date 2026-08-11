/// Enums do domínio de plantas.
///
/// Nomenclatura interna em inglês; os rótulos exibidos ao usuário vêm da
/// camada de localização (`lib/l10n`). Vários enums possuem o membro
/// `unknown`: ele representa a resposta explícita "não sei", diferente de um
/// campo ainda não preenchido (que no [PlantDraft] é `null`).
library;

enum PlantStartingPoint { seed, seedling, clone, inProgress }

enum PlantGeneticType { autoflower, photoperiod, unknown }

enum GrowingEnvironment { indoor, outdoor, mixed, unknown }

/// Detalhe opcional do espaço de cultivo (grow tent, quarto, estufa…).
enum EnvironmentPlace { growTent, room, greenhouse, pot, soilGround, other }

enum GrowingMedium { soil, coco, hydroponic, aeroponic, other, unknown }

enum IrrigationMode { manual, automatic, mixed, undefined }

/// Sistema opcional quando a irrigação é automática (ou mista).
enum IrrigationSystem { drip, reservoir, scheduled, other }

enum PlantPhase {
  seed,
  germination,
  seedling,
  vegetative,
  flowering,
  harvest,
  unknown,
}

enum PlantStatus { active, completed, died, discarded, interrupted, archived }

enum PlantOrigin {
  purchased,
  ownProduction,
  giftOrTrade,
  foundSeed,
  receivedClone,
  other,
  unknown,
}

enum TreatmentType {
  pestControl,
  fungusControl,
  treatment,
  correction,
  supplement,
  other,
}

enum ProblemCategory {
  pest,
  disease,
  deficiency,
  excess,
  watering,
  temperature,
  humidity,
  lighting,
  physicalDamage,
  other,
  unknown,
}

enum PlantEndReason { harvestCompleted, died, discarded, interrupted, other }

enum PlantEndCause {
  pest,
  disease,
  watering,
  nutrition,
  environment,
  accident,
  unknown,
  other,
}

/// Converte o `name` persistido de volta para o enum, com fallback seguro
/// para registros gravados por versões futuras do app.
T enumFromName<T extends Enum>(Iterable<T> values, String? name, T fallback) {
  if (name == null) return fallback;
  for (final value in values) {
    if (value.name == name) return value;
  }
  return fallback;
}
