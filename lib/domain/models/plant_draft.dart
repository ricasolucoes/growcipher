import '../identifiers.dart';
import 'plant.dart';
import 'plant_enums.dart';

/// Estado temporário do wizard de criação de planta.
///
/// Guarda as respostas até a confirmação final na revisão — nada é
/// persistido antes de [toPlant]. Campos `null` ainda não foram respondidos;
/// respostas explícitas de "não sei" usam o membro `unknown` do enum (ou a
/// flag própria, no caso das datas), para distinguir desconhecido de
/// não preenchido.
class PlantDraft {
  PlantDraft({String? privacyCode})
    : privacyCode = privacyCode ?? generatePrivacyCode();

  PlantStartingPoint? startingPoint;

  String? displayName;
  String privacyCode;

  PlantOrigin? origin;
  String? originDetails;

  /// Resposta do passo de genética ("Você conhece a genética?").
  bool? knowsGenetics;
  String? strain;
  PlantGeneticType? geneticType;

  DateTime? startDate;
  bool startDateIsApproximate = false;

  /// O usuário respondeu explicitamente "não sei" para a data de início.
  bool startDateUnknown = false;

  DateTime? seedObtainedDate;
  DateTime? germinationDate;
  DateTime? rootedDate;

  GrowingEnvironment? environment;
  EnvironmentPlace? environmentPlace;
  String? environmentName;

  GrowingMedium? growingMedium;
  String? containerType;
  double? containerVolumeLiters;

  PlantPhase? phase;

  IrrigationMode? irrigationMode;
  IrrigationSystem? irrigationSystem;

  /// Fase sugerida a partir do ponto de partida; o usuário pode alterar.
  PlantPhase get suggestedPhase => switch (startingPoint) {
    PlantStartingPoint.seed => PlantPhase.seed,
    PlantStartingPoint.seedling => PlantPhase.seedling,
    PlantStartingPoint.clone => PlantPhase.seedling,
    PlantStartingPoint.inProgress => PlantPhase.unknown,
    null => PlantPhase.unknown,
  };

  /// Único dado realmente obrigatório para criar a planta.
  bool get canCreate => startingPoint != null;

  /// Materializa a planta. Tudo que não foi respondido vira o default
  /// semântico (`unknown`/`undefined`) — o usuário nunca é bloqueado por
  /// não saber uma informação.
  Plant toPlant({required String id, required DateTime now}) {
    assert(canCreate, 'PlantDraft sem ponto de partida definido');

    final name = displayName?.trim();
    return Plant(
      id: id,
      displayName: (name == null || name.isEmpty) ? null : name,
      privacyCode: privacyCode,
      startingPoint: startingPoint!,
      origin: origin ?? PlantOrigin.unknown,
      originDetails: _clean(originDetails),
      strain: knowsGenetics == true ? _clean(strain) : null,
      geneticType:
          (knowsGenetics == true ? geneticType : null) ??
          PlantGeneticType.unknown,
      startDate: startDateUnknown ? null : startDate,
      startDateIsApproximate: !startDateUnknown && startDateIsApproximate,
      seedObtainedDate: seedObtainedDate,
      rootedDate: rootedDate,
      environment: environment ?? GrowingEnvironment.unknown,
      environmentPlace: environmentPlace,
      environmentName: _clean(environmentName),
      growingMedium: growingMedium ?? GrowingMedium.unknown,
      containerType: _clean(containerType),
      containerVolumeLiters: containerVolumeLiters,
      irrigationMode: irrigationMode ?? IrrigationMode.undefined,
      irrigationSystem: irrigationMode == IrrigationMode.manual
          ? null
          : irrigationSystem,
      phase: phase ?? suggestedPhase,
      status: PlantStatus.active,
      createdAt: now,
      updatedAt: now,
    );
  }

  static String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}
