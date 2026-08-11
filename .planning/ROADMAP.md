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

## Phase 4: Fotos e Privacidade
- Câmera e seleção de fotos.
- Processamento seguro (remover metadados EXIF offline).
- Armazenamento das imagens na pasta local (fora da galeria do usuário).

## Phase 5: Exportação e Relatórios
- Estatísticas locais.
- Exportação segura dos dados (backup e compartilhamento com senha).
