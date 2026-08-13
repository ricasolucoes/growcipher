# Phase 4: Fotos e Privacidade - Context

**Gathered:** 2026-08-12
**Status:** Ready for planning

<domain>
## Phase Boundary

Câmera e seleção de fotos. Processamento seguro (remover metadados EXIF offline). Armazenamento das imagens na pasta local (fora da galeria do usuário).
</domain>

<decisions>
## Implementation Decisions

### Câmera e Processamento
- A captura e seleção de fotos será feita com o package `image_picker` (câmera e galeria).
- Para processamento e privacidade offline, o package `flutter_image_compress` será utilizado para remover os metadados (EXIF) e comprimir o tamanho do arquivo antes de salvar.

### Armazenamento Local e UX
- As fotos serão salvas no diretório de documentos do app (através de `path_provider`), isolado da galeria pública do SO.
- A relação da foto com a planta (e futuramente eventos) será mantida salvando o caminho local do arquivo na tabela do banco SQLite (na coluna photoPath ou similar em Plants e Events).

### Claude's Discretion
None

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- `Plant` and `PlantEvent` models in `lib/domain/models/`.
- `SqlitePlantRepository` for DB access.
- `plant_profile_screen.dart` to display the photo.

### Established Patterns
- Riverpod for dependency injection (`lib/providers.dart`).

### Integration Points
- Add `photoPath` (String, nullable) to `plants` table (migration needed in `AppDatabase`) and `events` table.
- Implement an image service provider (e.g. `ImageService` wrapping `image_picker` and `path_provider` + `flutter_image_compress`).
- Update UI in `plant_wizard_screen.dart` (or a dedicated widget) to allow picking and saving a photo on creation.
- Display the local image using `Image.file(File(path))` in `plant_profile_screen.dart`.

</code_context>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

- None.
</deferred>
