import '../models/plant_enums.dart';
import 'insight.dart';

/// O que um modelo instalado no aparelho consegue fazer
/// (camadas 2 e 3 de `docs/IA.md` §1).
enum LocalInferenceCapability {
  /// Triagem de sintoma foliar sobre fotografias já locais.
  leafTriage,

  /// Perguntas em linguagem natural sobre o próprio diário.
  diaryQuestions,

  /// Resumo de ciclo em texto legível.
  cycleSummary,
}

/// Hipótese de triagem — nunca diagnóstico. Vira um `problemReported`
/// sugerido que o usuário confirma ou descarta.
class LeafTriageHypothesis {
  const LeafTriageHypothesis({
    required this.category,
    required this.confidence,
  });

  final ProblemCategory category;

  /// De 0 a 1.
  final double confidence;
}

/// Porta para inferência local.
///
/// Contrato que toda implementação assina, verificável em revisão de código
/// (`docs/IA.md` §2):
///
/// - nenhum `HttpClient`, socket ou plugin de rede no caminho de inferência;
/// - o modelo é lido do armazenamento local, e baixá-lo é um passo separado,
///   explícito, iniciado pelo usuário;
/// - nenhum artefato de inferência sai do aparelho, nem em relatório de erro;
/// - remover o modelo devolve o app à camada 1, sem tela quebrada.
///
/// O aplicativo é escrito contra esta porta, então *não ter modelo* é o
/// caminho normal — não um caso de erro.
abstract class LocalInference {
  Set<LocalInferenceCapability> get capabilities;

  bool supports(LocalInferenceCapability capability) =>
      capabilities.contains(capability);

  bool get isAvailable => capabilities.isNotEmpty;

  /// Hipóteses ordenadas por confiança, ou vazio se não houver modelo.
  Future<List<LeafTriageHypothesis>> triageLeafPhoto(String photoRef);

  /// Resposta a uma pergunta sobre o próprio histórico, ou `null` se não
  /// houver modelo de linguagem instalado.
  Future<String?> answerFromDiary({
    required String question,
    required List<PlantHistory> histories,
  });

  /// Resumo de um ciclo, ou `null` se não houver modelo.
  Future<String?> summarizeCycle(PlantHistory history);
}

/// Padrão do produto: nenhum modelo instalado.
///
/// A camada 1 (`InsightEngine`) continua entregando análise; as telas que
/// dependem de modelo apenas não oferecem a ação.
class UnavailableLocalInference implements LocalInference {
  const UnavailableLocalInference();

  @override
  Set<LocalInferenceCapability> get capabilities => const {};

  @override
  bool supports(LocalInferenceCapability capability) => false;

  @override
  bool get isAvailable => false;

  @override
  Future<List<LeafTriageHypothesis>> triageLeafPhoto(String photoRef) async =>
      const [];

  @override
  Future<String?> answerFromDiary({
    required String question,
    required List<PlantHistory> histories,
  }) async => null;

  @override
  Future<String?> summarizeCycle(PlantHistory history) async => null;
}
