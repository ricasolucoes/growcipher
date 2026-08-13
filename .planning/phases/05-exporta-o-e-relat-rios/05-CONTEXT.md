# Phase 5: Exportação e Relatórios - Context

**Gathered:** 2026-08-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Estatísticas locais. Exportação segura dos dados (backup e compartilhamento com senha).
</domain>

<decisions>
## Implementation Decisions

### Backup e Exportação
- **Formato de Exportação:** Arquivo ZIP contendo o dump em JSON dos dados das plantas e eventos, junto com os arquivos das imagens.
- **Criptografia do Backup:** O arquivo ZIP será criptografado via AES-256 (usando um package Flutter para encrypt/zip ou chamadas nativas) com senha definida pelo usuário no momento da exportação, garantindo segurança na nuvem ou no compartilhamento.

### Estatísticas Locais
- **Métricas e UX:** Exibir no Dashboard principal métricas básicas como Total de Plantas, Plantas Ativas e Eventos Registrados, mantendo as queries SQL leves para não impactar a performance.

### Claude's Discretion
None

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `SqlitePlantRepository` for accessing plants and events.
- `LocalPhotoStore` for accessing photo files.
- `home_screen.dart` (Dashboard) for placing statistics.

### Established Patterns
- UI layers reading from Riverpod providers (e.g. `FutureProvider` for stats).
- Path-based file operations in the documents directory.

### Integration Points
- Create a `BackupService` to handle the generation of JSON dumps, copying photos, compressing into a ZIP, and AES-256 encrypting it with a password.
- Expose a `StatsService` or methods on `PlantRepository` to compute metrics via COUNT queries.
- Connect the export action to the UI (e.g. settings screen or floating action button).
- Share the final export file using `share_plus` or similar package.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

- None.
</deferred>
