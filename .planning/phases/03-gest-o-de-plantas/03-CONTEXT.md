# Phase 3: Gestão de Plantas - Context

**Gathered:** 2026-08-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Cadastro de plantas, genéticas e informações iniciais. Linha do tempo de eventos de cada planta. Sistema de registro rápido (Rega, Nutrição).
</domain>

<decisions>
## Implementation Decisions

### Modelo de Dados e Relacionamentos
- A planta pode ter múltiplos eventos de rega/nutrição por dia, registrados com timestamp exato.
- A linha do tempo será carregada via consulta paginada no banco SQLite ordenada por data descrescente (evitando carregar tudo em memória).
- A foto da planta é opcional no cadastro, podendo ser adicionada depois (Phase 4).

### UX do Registro Rápido
- O registro rápido (Rega, Nutrição) deve ser acessível tanto da tela de detalhes da planta quanto do Dashboard principal.
- O state do form do registro rápido será mantido de forma efêmera com Riverpod (`StateProvider`/`Notifier`) atrelado ao ciclo de vida da bottom sheet.
- A confirmação de sucesso no registro será via SnackBar discreto e atualização otimista na interface.

### Claude's Discretion
None

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `AppDatabase` class in `lib/data/app_database.dart`
- Riverpod providers in `lib/providers.dart`
- UI screens in `lib/features/` (`plant_wizard_screen.dart`, `plant_profile_screen.dart`, `quick_log_forms.dart`)

### Established Patterns
- Riverpod for DI and state management.
- Standard `sqflite` (SQLCipher) database layer.

### Integration Points
- Implement methods in `SqlitePlantRepository` to query timeline paginated and insert events with timestamp.
- Bind `plant_wizard_screen.dart` to insert into DB instead of printing / mocking.
- Bind `quick_log_forms.dart` to insert events into DB and use a SnackBar on success.
- Update `plant_profile_screen.dart` and `home_screen.dart` to reflect real DB data.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

- Camera and photo processing is deferred to Phase 4.
</deferred>
