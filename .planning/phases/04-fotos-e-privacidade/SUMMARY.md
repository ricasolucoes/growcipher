# Phase 4 Summary: Fotos e Privacidade

## Tasks Completed
1. **Adicionar dependências**: Added `image_picker`, `flutter_image_compress`, `path_provider`, and `uuid` to `pubspec.yaml`. Configured iOS permissions in `Info.plist`.
2. **Ajustar PhotoStore e implementar LocalPhotoStore**: Refactored `PhotoStore` to return file paths. Implemented `LocalPhotoStore` using `path_provider` and `flutter_image_compress` to store images locally and strip EXIF data. Registered it as a provider.
3. **Atualizar Schema do Banco de Dados e Modelos**: Added `photoRef` to `Plant`'s `copyWith` method. Incremented database version to 2 and added a migration for `ALTER TABLE plant_events ADD COLUMN photo_ref TEXT`. Handled photo_ref serialization mapping in the repository.
4. **Integração de câmera/galeria no Wizard de Plantas**: Updated `PlantDraft` with `photoRef`. Added `addPhoto`, `takePhoto` and `chooseFromGallery` strings. Integrated `ImagePicker` into the wizard, storing the compressed photo path and assigning `photoRef` upon plant creation.
5. **Captura de Foto para Eventos (Quick Log)**: Enabled the `QuickLogAction.photo` action in Quick Log. Implemented `_PhotoEventForm` utilizing `ImagePicker` and saving `PhotoAddedEvent`.
6. **Exibição da foto no Perfil e Timeline**: Created `photoPathProvider` in `plant_profile_screen.dart`. Updated `_PlantHeader` and `_EventTile` to `ConsumerWidget`s to display loaded images via `Image.file`.

All tests passed successfully, and changes are fully operational locally.
