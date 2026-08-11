import '../../domain/models/plant_enums.dart';
import '../../domain/models/plant_event.dart';
import '../../l10n/generated/app_localizations.dart';

/// Rótulos pt-BR dos enums do domínio.
///
/// A nomenclatura interna fica em inglês; tudo que o usuário vê passa por
/// aqui e vem dos ARBs.
extension PlantEnumLabels on AppLocalizations {
  String startingPointLabel(PlantStartingPoint value) => switch (value) {
    PlantStartingPoint.seed => startingPointSeed,
    PlantStartingPoint.seedling => startingPointSeedling,
    PlantStartingPoint.clone => startingPointClone,
    PlantStartingPoint.inProgress => startingPointInProgress,
  };

  /// Origem com concordância de gênero: clone é "Comprado/Outro/Recebido";
  /// semente, muda e planta são femininas.
  String originLabel(PlantOrigin value, {PlantStartingPoint? startingPoint}) {
    final masculine = startingPoint == PlantStartingPoint.clone;
    return switch (value) {
      PlantOrigin.purchased => masculine ? originPurchasedM : originPurchasedF,
      PlantOrigin.ownProduction => originOwnProduction,
      PlantOrigin.giftOrTrade => originGiftOrTrade,
      PlantOrigin.foundSeed => originFoundSeed,
      PlantOrigin.receivedClone => originReceivedClone,
      PlantOrigin.other => masculine ? originOtherM : originOtherF,
      PlantOrigin.unknown => dontKnow,
    };
  }

  String geneticTypeLabel(PlantGeneticType value) => switch (value) {
    PlantGeneticType.autoflower => geneticTypeAutoflower,
    PlantGeneticType.photoperiod => geneticTypePhotoperiod,
    PlantGeneticType.unknown => dontKnow,
  };

  String environmentLabel(GrowingEnvironment value) => switch (value) {
    GrowingEnvironment.indoor => environmentIndoor,
    GrowingEnvironment.outdoor => environmentOutdoor,
    GrowingEnvironment.mixed => environmentMixed,
    GrowingEnvironment.unknown => dontKnow,
  };

  String environmentPlaceLabel(EnvironmentPlace value) => switch (value) {
    EnvironmentPlace.growTent => envGrowTent,
    EnvironmentPlace.room => envRoom,
    EnvironmentPlace.greenhouse => envGreenhouse,
    EnvironmentPlace.pot => envPot,
    EnvironmentPlace.soilGround => envSoil,
    EnvironmentPlace.other => envOther,
  };

  String growingMediumLabel(GrowingMedium value) => switch (value) {
    GrowingMedium.soil => mediumSoil,
    GrowingMedium.coco => mediumCoco,
    GrowingMedium.hydroponic => mediumHydroponic,
    GrowingMedium.aeroponic => mediumAeroponic,
    GrowingMedium.other => mediumOther,
    GrowingMedium.unknown => dontKnow,
  };

  String irrigationModeLabel(IrrigationMode value) => switch (value) {
    IrrigationMode.manual => irrigationManual,
    IrrigationMode.automatic => irrigationAutomatic,
    IrrigationMode.mixed => irrigationMixed,
    IrrigationMode.undefined => irrigationUndefined,
  };

  String irrigationSystemOptionLabel(IrrigationSystem value) => switch (value) {
    IrrigationSystem.drip => irrigationDrip,
    IrrigationSystem.reservoir => irrigationReservoir,
    IrrigationSystem.scheduled => irrigationScheduled,
    IrrigationSystem.other => envOther,
  };

  String phaseLabel(PlantPhase value) => switch (value) {
    PlantPhase.seed => phaseSeed,
    PlantPhase.germination => phaseGermination,
    PlantPhase.seedling => phaseSeedling,
    PlantPhase.vegetative => phaseVegetative,
    PlantPhase.flowering => phaseFlowering,
    PlantPhase.harvest => phaseHarvest,
    PlantPhase.unknown => dontKnow,
  };

  String statusLabel(PlantStatus value) => switch (value) {
    PlantStatus.active => statusActive,
    PlantStatus.completed => statusCompleted,
    PlantStatus.died => statusDied,
    PlantStatus.discarded => statusDiscarded,
    PlantStatus.interrupted => statusInterrupted,
    PlantStatus.archived => statusArchived,
  };

  String treatmentTypeOptionLabel(TreatmentType value) => switch (value) {
    TreatmentType.pestControl => treatmentPestControl,
    TreatmentType.fungusControl => treatmentFungusControl,
    TreatmentType.treatment => treatmentGeneric,
    TreatmentType.correction => treatmentCorrection,
    TreatmentType.supplement => treatmentSupplement,
    TreatmentType.other => envOther,
  };

  String problemCategoryOptionLabel(ProblemCategory value) => switch (value) {
    ProblemCategory.pest => problemPest,
    ProblemCategory.disease => problemDisease,
    ProblemCategory.deficiency => problemDeficiency,
    ProblemCategory.excess => problemExcess,
    ProblemCategory.watering => problemWatering,
    ProblemCategory.temperature => problemTemperature,
    ProblemCategory.humidity => problemHumidity,
    ProblemCategory.lighting => problemLighting,
    ProblemCategory.physicalDamage => problemPhysicalDamage,
    ProblemCategory.other => envOther,
    ProblemCategory.unknown => dontKnow,
  };

  String endReasonOptionLabel(PlantEndReason value) => switch (value) {
    PlantEndReason.harvestCompleted => endReasonHarvestCompleted,
    PlantEndReason.died => endReasonDied,
    PlantEndReason.discarded => endReasonDiscarded,
    PlantEndReason.interrupted => endReasonInterrupted,
    PlantEndReason.other => endReasonOther,
  };

  String endCauseOptionLabel(PlantEndCause value) => switch (value) {
    PlantEndCause.pest => causePest,
    PlantEndCause.disease => causeDisease,
    PlantEndCause.watering => causeWatering,
    PlantEndCause.nutrition => causeNutrition,
    PlantEndCause.environment => causeEnvironment,
    PlantEndCause.accident => causeAccident,
    PlantEndCause.unknown => dontKnow,
    PlantEndCause.other => envOther,
  };

  String eventTypeLabel(PlantEventType value) => switch (value) {
    PlantEventType.plantCreated => eventPlantCreated,
    PlantEventType.germinated => eventGerminated,
    PlantEventType.watered => eventWatered,
    PlantEventType.fed => eventFed,
    PlantEventType.treatmentApplied => eventTreatment,
    PlantEventType.measurementAdded => eventMeasurement,
    PlantEventType.transplanted => eventTransplant,
    PlantEventType.phaseChanged => eventPhaseChanged,
    PlantEventType.photoAdded => eventPhotoAdded,
    PlantEventType.observationAdded => eventObservation,
    PlantEventType.problemReported => eventProblem,
    PlantEventType.taskCompleted => eventTaskDone,
    PlantEventType.harvested => eventHarvested,
    PlantEventType.plantEnded => eventPlantEnded,
  };
}
