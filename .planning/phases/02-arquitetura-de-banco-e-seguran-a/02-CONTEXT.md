# Phase 2: Arquitetura de Banco e Segurança - Context

**Gathered:** 2026-08-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Implementação do armazenamento de chaves mestre (KeyStore/Keychain), inicialização do SQLite com SQLCipher para criptografia at-rest, e configuração de login local e biometria (`local_auth`).
</domain>

<decisions>
## Implementation Decisions

### Armazenamento da Chave e Criptografia
- A chave mestre é gerada aleatoriamente na primeira instalação.
- A chave é armazenada no `flutter_secure_storage` usando KeyStore/Keychain nativos.
- O banco de dados existente (desenvolvimento) não-criptografado será apagado e recriado, pois é MVP e os dados são de teste.

### Autenticação Local (Biometria)
- A autenticação biométrica é opcional, ativada nas configurações iniciais.
- O comportamento de fallback caso a biometria falhe/não exista é usar o PIN/senha do próprio dispositivo via `local_auth`.
- A autenticação é exigida apenas no app startup ou após longo período em background.

### Claude's Discretion
None

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppDatabase` class in `lib/data/app_database.dart`
- Riverpod providers in `lib/providers.dart`

### Established Patterns
- Riverpod for DI, standard `sqflite` database initialization.

### Integration Points
- `appDatabaseProvider` needs to be updated to generate/fetch the key and pass it to SQLCipher.
- The app's startup flow (likely in `lib/main.dart` or `lib/app.dart` or initial screen) needs to integrate `local_auth` prompt se ativado.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>
