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
- Domínio puro: tabela de XP, curva de nível, completude por planta, catálogo de conquistas, motor de avaliação.
- Persistência no esquema v2: estado, ledger de XP reconstruível, contadores e conquistas destravadas.
- Tela de progresso e realimentação no fluxo de registro (o que falta preencher, quanto vale).
- Restrições não negociáveis em `docs/Gamificacao.md` §5.

## Phase 3.6: Inteligência no Aparelho — Camada 1 (pilar)
- Motor determinístico de insights sobre o histórico do próprio usuário: cadência de rega, duração de fase, medição fora da linha de base, perfil incompleto, problema sem desfecho, janela de colheita.
- Porta `LocalInference` para as camadas opcionais, com implementação nula como padrão do produto.
- Sem download de modelo, sem rede em nenhum caminho.

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
