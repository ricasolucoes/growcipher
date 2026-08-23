/// Contrato comum dos formulários do registro rápido.
///
/// Cada tipo de acontecimento tem a sua entrada: um objeto imutável com o que
/// o usuário digitou (texto cru, ainda sem conversão) e escolheu. A entrada
/// sabe fazer duas coisas, ambas sem Flutter e sem banco:
///
/// - [validate] — o que ainda falta para poder salvar;
/// - [build] — a gravação correspondente, quando não falta nada.
///
/// É o que tira a regra de dentro do widget: o formulário só monta a entrada a
/// partir dos controllers e pergunta. Nada neste arquivo importa Flutter.
library;

import '../../../domain/models/plant_enums.dart';
import '../../../domain/models/plant_event.dart';
import '../../../domain/repositories/plant_repository.dart';

/// Identidade e tempo que o formulário não decide.
///
/// Vêm de fora no momento de salvar (id gerado, "agora" do relógio) para que
/// [QuickLogInput.build] continue determinística e testável.
class QuickLogStamp {
  const QuickLogStamp({
    required this.plantId,
    required this.eventId,
    required this.occurredAt,
    required this.createdAt,
  });

  final String plantId;

  /// Id do evento principal do formulário.
  final String eventId;

  /// Quando o fato aconteceu (escolha do usuário, ou "agora").
  final DateTime occurredAt;

  /// Quando o registro está sendo gravado.
  final DateTime createdAt;
}

/// O que impede um formulário de salvar.
///
/// A interface não mostra mensagem de erro: o botão "Salvar" apenas fica
/// desabilitado. O enum existe para o teste dizer *qual* regra reprovou.
enum QuickLogError {
  /// Mudança de fase sem a nova fase escolhida.
  phaseRequired,

  /// Observação sem texto.
  observationRequired,

  /// Encerramento sem motivo escolhido.
  endReasonRequired,
}

/// Entrada de um formulário do registro rápido.
abstract interface class QuickLogInput {
  /// Regras não atendidas. Lista vazia = pronto para salvar.
  List<QuickLogError> validate();

  /// Materializa a gravação. Só pode ser chamada com [validate] vazio.
  QuickLogSubmission build(QuickLogStamp stamp);
}

extension QuickLogInputValidity on QuickLogInput {
  /// Atalho para o `saveEnabled` do formulário.
  bool get isValid => validate().isEmpty;
}

/// O que um formulário válido pede ao repositório.
///
/// Nem todo acontecimento é só um evento: mudança de fase e encerramento
/// também atualizam o snapshot da planta, e a colheita pode encerrar o ciclo.
/// Essas diferenças ficam aqui, em valores comparáveis num teste, em vez de
/// espalhadas em chamadas dentro de cada `State`.
sealed class QuickLogSubmission {
  const QuickLogSubmission();

  /// Junta gravações que acontecem no mesmo "Salvar", na ordem da lista.
  factory QuickLogSubmission.all(List<QuickLogSubmission> parts) =>
      CompositeSubmission(parts);

  Future<void> apply(PlantRepository repository);
}

/// Acrescenta um evento à linha do tempo.
final class AddEventSubmission extends QuickLogSubmission {
  const AddEventSubmission(this.event);

  final PlantEvent event;

  @override
  Future<void> apply(PlantRepository repository) => repository.addEvent(event);
}

/// Muda a fase da planta (evento + snapshot, no repositório).
final class ChangePhaseSubmission extends QuickLogSubmission {
  const ChangePhaseSubmission({
    required this.plantId,
    required this.newPhase,
    required this.occurredAt,
    this.notes,
  });

  final String plantId;
  final PlantPhase newPhase;
  final DateTime occurredAt;
  final String? notes;

  @override
  Future<void> apply(PlantRepository repository) => repository.changePhase(
    plantId: plantId,
    newPhase: newPhase,
    occurredAt: occurredAt,
    notes: notes,
  );
}

/// Encerra o ciclo da planta (evento + status, no repositório).
final class EndPlantSubmission extends QuickLogSubmission {
  const EndPlantSubmission({
    required this.plantId,
    required this.reason,
    required this.occurredAt,
    this.cause,
    this.notes,
  });

  final String plantId;
  final PlantEndReason reason;
  final DateTime occurredAt;
  final PlantEndCause? cause;
  final String? notes;

  @override
  Future<void> apply(PlantRepository repository) => repository.endPlant(
    plantId: plantId,
    reason: reason,
    cause: cause,
    occurredAt: occurredAt,
    notes: notes,
  );
}

/// Sequência de gravações de um único "Salvar" (ver [QuickLogSubmission.all]).
final class CompositeSubmission extends QuickLogSubmission {
  const CompositeSubmission(this.parts);

  final List<QuickLogSubmission> parts;

  @override
  Future<void> apply(PlantRepository repository) async {
    for (final part in parts) {
      await part.apply(repository);
    }
  }
}

/// Texto do usuário sem espaços nas pontas; vazio vira `null`.
///
/// Campo em branco significa "não informado", nunca string vazia no banco.
String? textOrNull(String? raw) {
  final text = raw?.trim();
  return (text == null || text.isEmpty) ? null : text;
}
