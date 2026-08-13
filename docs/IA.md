# Inteligência no aparelho

Pilar do produto. O GrowCipher analisa o cultivo, mas a análise acontece no aparelho ou não acontece — o cofre não vaza para um endpoint de inferência.

As invariantes estão em [[Principios]] → *Inteligência no aparelho*: nenhuma inferência remota, nenhum treino com dados do usuário, degradação graciosa, análise sobre o próprio histórico, sugestão nunca ordem. O que segue é o desenho.

---

## 1. Três camadas

A IA do produto não é um modelo, é uma pilha. Cada camada funciona sozinha; as de cima são opcionais e nunca são pré-requisito para as de baixo.

### Camada 1 — Determinística (sempre presente)

Zero download, zero modelo, roda em qualquer aparelho. É estatística sobre o histórico do próprio usuário, e entrega a maior parte do valor:

| Insight | Como sai do histórico |
|---|---|
| Rega atrasada | Mediana do intervalo entre regas *daquela planta*; alerta quando o intervalo atual passa de 1,5× |
| Fase mais longa que o usual | Duração da fase atual contra a mediana das plantas anteriores do mesmo usuário |
| Medição fora da faixa | Desvio contra a linha de base do próprio usuário para aquela métrica, não contra tabela agronômica |
| Perfil incompleto | Completude da planta abaixo de 60%, com os campos faltantes nomeados |
| Sem foto recente | Última fotografia há mais tempo que a cadência habitual do usuário |
| Problema sem desfecho | `problemReported` sem evento de acompanhamento em 3 dias |
| Janela de colheita | Projeção a partir dos ciclos que o próprio usuário já fechou com a mesma genética |
| Sequência em risco | Nenhum registro hoje e sequência ativa (único insight que a camada de progressão dispara) |

A regra é dura: **nenhuma faixa "ideal" universal embutida**. O aplicativo não sabe o pH certo para a sua planta; ele sabe o pH que *você* costuma medir e avisa quando a medição de hoje destoa.

### Camada 2 — Visão no aparelho (opcional, download explícito)

Classificador pequeno (dezenas de MB, LiteRT/ONNX) sobre fotografias já armazenadas localmente: triagem de sintoma foliar — deficiência, excesso, praga, fungo, estresse hídrico, estresse de luz. Saída é sempre *hipótese com confiança*, cruzada com o que o histórico registra, e vira um `problemReported` sugerido que o usuário confirma ou descarta.

### Camada 3 — Linguagem no aparelho (opcional, download explícito)

Modelo de linguagem pequeno rodando local (llama.cpp via FFI ou equivalente), sem rede em nenhuma hipótese. Serve para: perguntar ao próprio diário em linguagem natural, resumir um ciclo em texto legível, e redigir o relatório de exportação. Nunca para diagnosticar sozinho — o modelo lê o histórico, não substitui a camada 1.

Escolha de runtime e de modelo é decisão da fase de pesquisa correspondente no roadmap. O que já está decidido: download opcional, removível, verificado por hash, e nenhuma chamada de rede em tempo de inferência.

## 2. Contrato de privacidade

Qualquer implementação das camadas 2 e 3 assina o mesmo contrato, verificável em revisão de código:

- Sem `HttpClient`, sem socket, sem plugin que fale rede no caminho de inferência.
- O modelo é lido de armazenamento local; o download é um passo separado, explícito, iniciado pelo usuário, e falha fechado.
- Nenhum artefato de inferência (prompt, embedding, log) sai do aparelho, nem em relatório de erro.
- Desinstalar o modelo devolve o aplicativo ao comportamento da camada 1, sem tela quebrada.
- Nenhum insight é telemetria: o que o motor conclui morre no aparelho.

## 3. Arquitetura

- `lib/domain/ai/insight.dart` — `Insight` tipado: espécie, severidade, planta, evidência numérica. **Sem texto pronto** — o domínio emite identificador e parâmetros, a interface traduz via ARB, como `enum_labels.dart` faz com os enums.
- `lib/domain/ai/insight_engine.dart` — camada 1, função pura sobre plantas + eventos + relógio. Sem I/O, testável direto.
- `lib/domain/ai/local_inference.dart` — porta para as camadas 2 e 3, com implementação nula (`UnavailableLocalInference`) como padrão do produto. O aplicativo é escrito contra a porta, então a ausência de modelo é o caminho normal, não um caso de erro.

Como a camada 1 vive do histórico do próprio usuário, ela fica melhor exatamente na medida em que a [[Gamificacao]] convence o usuário a registrar mais. Os dois pilares se alimentam: quem registra detalhe ganha análise melhor, e análise melhor dá motivo para registrar detalhe.

Ver também: [[Funcionalidades]], [[MVP]] e [[Principios]].
