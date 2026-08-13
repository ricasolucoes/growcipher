# Roadmap: GrowCipher

## Phase 1: Setup e Infraestrutura Base (Atual)
- Bootstrap do projeto Flutter com package/organization configurados.
- Criação das pastas de documentação e planejamento (GSD).
- Estruturação base de pastas do aplicativo em Dart (bloc/provider/riverpod, models, repositories).

## Phase 2: Arquitetura de Banco e Segurança
- Implementar o armazenamento de chaves mestre (KeyStore/Keychain).
- Inicialização do SQLite com SQLCipher (Criptografia at-rest).
- Configuração de login local e biometria (`local_auth`).

## Phase 3: Gestão de Plantas
- Cadastro de plantas, genéticas e informações iniciais.
- Linha do tempo de eventos de cada planta.
- Sistema de registro rápido (Rega, Nutrição).

## Phase 3.5: Progressão Local (pilar)
- [x] Domínio puro: tabela de XP, curva de nível, completude por planta, catálogo de 32 conquistas, motor de avaliação (`lib/domain/gamification/`).
- [x] Persistência no esquema v2: estado, ledger de XP idempotente, contadores e conquistas destravadas (`lib/data/sqlite_gamification_repository.dart`).
- [x] `GamifiedPlantRepository` decorando o repositório de plantas, ativo em `main.dart` — todo evento gravado pontua.
- [ ] **Interface** (pendente, mexe em arquivos compartilhados):
  - `AppScope` recebe `GamificationRepository` (opcional, para os testes de widget seguirem construindo o app sem ela).
  - Rota e tela de progresso: nível e barra do nível, sequência atual e melhor marca, conquistas destravadas por família, plantas com perfil incompleto.
  - Entrada na home (ícone na AppBar) e realimentação no registro rápido: quanto o evento pagou e qual campo ainda vale XP.
  - ARB: nome e descrição das 32 conquistas + rótulos dos 8 insights, no padrão de `enum_labels.dart` (domínio emite id, interface traduz).
- Restrições não negociáveis em `docs/Gamificacao.md` §5.

## Phase 3.6: Inteligência no Aparelho — Camada 1 (pilar)
- [x] Motor determinístico de insights sobre o histórico do próprio usuário: cadência de rega, duração de fase, medição fora da linha de base, perfil incompleto, foto ausente, problema sem desfecho, janela de colheita, sequência em risco (`lib/domain/ai/insight_engine.dart`).
- [x] Porta `LocalInference` para as camadas opcionais, com `UnavailableLocalInference` como padrão do produto.
- [x] Sem download de modelo, sem rede em nenhum caminho.
- [ ] **Interface** (pendente): faixa de insights na home e no perfil da planta, com a evidência numérica visível e ação de dispensar. Textos no ARB, indexados por `InsightKind`.

## Phase 4: Fotos e Privacidade
- Câmera e seleção de fotos.
- Processamento seguro (remover metadados EXIF offline).
- Armazenamento das imagens na pasta local (fora da galeria do usuário).

## Phase 5: Exportação e Relatórios
- Estatísticas locais.
- Exportação segura dos dados (backup e compartilhamento com senha).

## Phase 6: Inteligência no Aparelho — Camadas 2 e 3
- Pesquisa e escolha de runtime (LiteRT/ONNX para visão; llama.cpp via FFI ou equivalente para linguagem).
- Download opcional, verificado por hash, removível, com o app degradando para a camada 1 na ausência do modelo.
- Visão: triagem de sintoma foliar sobre fotos já locais, saída como hipótese que vira `problemReported` sugerido.
- Linguagem: consulta ao próprio diário, resumo de ciclo e redação do relatório de exportação.
- Auditoria do contrato de privacidade (`docs/IA.md` §2): nenhum caminho de inferência toca rede.
