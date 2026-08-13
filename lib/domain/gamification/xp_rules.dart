import '../models/plant_event.dart';

/// De onde veio uma concessão de XP.
enum XpSource {
  /// Evento gravado na linha do tempo (valor base do tipo).
  eventLogged,

  /// Campos opcionais preenchidos no evento — o incentivo ao detalhe.
  fieldDetail,

  /// Nota livre escrita no evento.
  noteWritten,

  /// Marco de completude do perfil de uma planta (50%, 80%, 100%).
  profileCompleted,

  /// Primeiro registro de um dia novo.
  streakDay,

  /// Conquista destravada.
  achievement,
}

/// Uma concessão de XP.
///
/// [key] é estável e única por concessão: a persistência usa isso para
/// garantir idempotência (o mesmo evento reprocessado não paga duas vezes).
class XpAward {
  const XpAward({
    required this.key,
    required this.source,
    required this.amount,
    this.plantId,
  });

  final String key;
  final XpSource source;
  final int amount;
  final String? plantId;
}

/// XP base por tipo de evento.
///
/// `problemReported` e `plantEnded` pagam bem de propósito: quem registra o
/// que deu errado entrega o dado mais valioso do histórico
/// (`docs/Gamificacao.md` §2).
const Map<PlantEventType, int> baseXpByEventType = {
  PlantEventType.plantCreated: 50,
  PlantEventType.germinated: 20,
  PlantEventType.watered: 8,
  PlantEventType.fed: 10,
  PlantEventType.treatmentApplied: 12,
  PlantEventType.measurementAdded: 12,
  PlantEventType.transplanted: 20,
  PlantEventType.phaseChanged: 25,
  PlantEventType.photoAdded: 15,
  PlantEventType.observationAdded: 10,
  PlantEventType.problemReported: 15,
  PlantEventType.taskCompleted: 8,
  PlantEventType.harvested: 80,
  PlantEventType.plantEnded: 30,
};

const int xpPerFilledField = 4;
const int xpPerNote = 3;

const Map<int, int> xpByCompletenessMilestone = {50: 40, 80: 60, 100: 100};

const int xpStreakBase = 10;
const int xpStreakPerDay = 2;
const int xpStreakCap = 50;

/// Chaves de payload que o próprio tipo de evento exige — não contam como
/// detalhe preenchido pelo usuário.
const Map<PlantEventType, Set<String>> _requiredPayloadKeys = {
  PlantEventType.phaseChanged: {'previousPhase', 'newPhase'},
  PlantEventType.treatmentApplied: {'treatmentType'},
  PlantEventType.problemReported: {'category'},
  PlantEventType.plantEnded: {'reason'},
};

Iterable<MapEntry<String, Object?>> _optionalPayload(PlantEvent event) {
  final required = _requiredPayloadKeys[event.type] ?? const <String>{};
  return event
      .payloadToMap()
      .entries
      .where((entry) => !required.contains(entry.key));
}

/// Quantos campos opcionais o usuário preencheu neste evento.
int detailFieldsOf(PlantEvent event) =>
    _optionalPayload(event).where((entry) => entry.value != null).length;

/// Verdadeiro quando o evento tem campos opcionais e todos foram preenchidos
/// — a métrica por trás das conquistas de registro detalhado.
bool isFullyDetailed(PlantEvent event) {
  final optional = _optionalPayload(event).toList();
  if (optional.isEmpty) return false;
  return optional.every((entry) => entry.value != null);
}

bool hasNote(PlantEvent event) => (event.notes?.trim().isNotEmpty) ?? false;

/// XP que um evento paga: base do tipo + detalhe + nota.
List<XpAward> awardsForEvent(PlantEvent event) {
  final awards = <XpAward>[
    XpAward(
      key: 'event:${event.id}:base',
      source: XpSource.eventLogged,
      amount: baseXpByEventType[event.type] ?? 5,
      plantId: event.plantId,
    ),
  ];

  final detailFields = detailFieldsOf(event);
  if (detailFields > 0) {
    awards.add(
      XpAward(
        key: 'event:${event.id}:detail',
        source: XpSource.fieldDetail,
        amount: detailFields * xpPerFilledField,
        plantId: event.plantId,
      ),
    );
  }

  if (hasNote(event)) {
    awards.add(
      XpAward(
        key: 'event:${event.id}:note',
        source: XpSource.noteWritten,
        amount: xpPerNote,
        plantId: event.plantId,
      ),
    );
  }

  return awards;
}
