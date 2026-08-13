---
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - ios/Runner/Info.plist
  - lib/domain/models/plant.dart
  - lib/domain/models/plant_draft.dart
  - lib/domain/photos/photo_store.dart
  - lib/data/local_photo_store.dart
  - lib/data/app_database.dart
  - lib/data/sqlite_plant_repository.dart
  - lib/providers.dart
  - lib/features/plant_wizard/plant_wizard_screen.dart
  - lib/features/plant_profile/plant_profile_screen.dart
  - lib/features/quick_log/quick_log.dart
  - lib/features/quick_log/quick_log_forms.dart
  - lib/l10n/app_pt.arb
autonomous: true
---

# Phase 4: Fotos e Privacidade

## Tasks

### 1. Adicionar dependências
Add required packages for picking, compressing, and saving images.

<task>
<read_first>
- pubspec.yaml
- ios/Runner/Info.plist
</read_first>
<action>
1. Run `flutter pub add image_picker flutter_image_compress path_provider uuid` to add the dependencies to `pubspec.yaml`.
2. Add `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` keys and string values to `ios/Runner/Info.plist` to request permissions on iOS.
</action>
<acceptance_criteria>
grep "image_picker:" pubspec.yaml && grep "flutter_image_compress:" pubspec.yaml && grep "path_provider:" pubspec.yaml && grep "NSCameraUsageDescription" ios/Runner/Info.plist
</acceptance_criteria>
</task>

### 2. Ajustar PhotoStore e implementar LocalPhotoStore
Refactor the abstract `PhotoStore` to work with file paths. Implement it using `path_provider` and `flutter_image_compress` to save images to the app's document directory (which prevents them from showing in the user's gallery) and strip EXIF data. Update Riverpod providers.

<task>
<read_first>
- lib/domain/photos/photo_store.dart
- lib/providers.dart
</read_first>
<action>
1. Edit `lib/domain/photos/photo_store.dart`:
   - Change `savePhoto(Uint8List bytes)` to `savePhoto(String tempPath)`.
   - Change `readPhoto(String photoRef)` to `getPhotoPath(String photoRef)` returning a `Future<String?>`.
2. Create `lib/data/local_photo_store.dart` implementing `PhotoStore`:
   - Inject or create a way to get the documents directory via `getApplicationDocumentsDirectory()`.
   - In `savePhoto`: Generate a `uuid.v4() + '.jpg'` for the filename (`photoRef`). Use `FlutterImageCompress.compressAndGetFile` from the `tempPath` to the final path in the documents directory. `flutter_image_compress` automatically strips EXIF data by default. Return the filename.
   - In `getPhotoPath`: Rebuild the absolute path using the documents directory + `photoRef` (filename) and return it. Check if the file exists using `File.exists()`, return null if it doesn't.
   - In `deletePhoto`: Delete the file if it exists.
3. Edit `lib/providers.dart`:
   - Add `final photoStoreProvider = Provider<PhotoStore>((ref) { return LocalPhotoStore(); });`.
</action>
<acceptance_criteria>
grep "getPhotoPath" lib/domain/photos/photo_store.dart && grep "class LocalPhotoStore" lib/data/local_photo_store.dart && grep "photoStoreProvider" lib/providers.dart
</acceptance_criteria>
</task>

### 3. Atualizar Schema do Banco de Dados e Modelos
Ensure `photoRef` is fully integrated into the `Plant` model and create a migration to add `photo_ref` to the `plant_events` table (and `plants` table if needed, though already present).

<task>
<read_first>
- lib/domain/models/plant.dart
- lib/data/app_database.dart
- lib/data/sqlite_plant_repository.dart
</read_first>
<action>
1. Edit `lib/domain/models/plant.dart` to verify the `photoRef` property is passed through the `copyWith` method.
2. Edit `lib/data/app_database.dart`:
   - Increment `version` to 2.
   - Add a new migration to `_migrations` that executes `ALTER TABLE plant_events ADD COLUMN photo_ref TEXT`.
3. Edit `lib/data/sqlite_plant_repository.dart`:
   - Ensure the repository reads/writes `photo_ref` during `_eventToRow` and `_eventFromRow` (e.g., mapping `photo_ref` from `PhotoAddedEvent` instead of just from the payload, or preserving it in the DB schema).
</action>
<acceptance_criteria>
grep "ALTER TABLE plant_events ADD COLUMN photo_ref" lib/data/app_database.dart
</acceptance_criteria>
</task>

### 4. Integração de câmera/galeria no Wizard de Plantas
Allow picking a photo when creating a new plant, process it, and save the resulting `photoRef` to the database.

<task>
<read_first>
- lib/domain/models/plant_draft.dart
- lib/features/plant_wizard/plant_wizard_screen.dart
- lib/l10n/app_pt.arb
</read_first>
<action>
1. Edit `lib/domain/models/plant_draft.dart`:
   - Add a `String? photoRef;` property to the `PlantDraft` class.
   - Update the `toPlant()` method to pass `photoRef` to the `Plant` constructor. (This relies on the `Plant` model verification in Task 3).
2. Edit `lib/l10n/app_pt.arb` to add strings for "Adicionar foto" (`addPhoto`), "Tirar foto" (`takePhoto`), "Escolher da galeria" (`chooseFromGallery`).
3. Edit `lib/features/plant_wizard/plant_wizard_screen.dart`:
   - Add state for holding a picked file path (e.g. `String? _tempPhotoPath`).
   - Add an ImagePicker instance or use it dynamically.
   - In `_buildIdentity`, replace the "disabled" photo `ListTile` with a working UI. When tapped, show a bottom sheet or dialog offering "Camera" or "Gallery" options.
   - Use `ImagePicker().pickImage` to get the image.
   - If picked, store the path in `_tempPhotoPath`. If `_tempPhotoPath != null`, show a thumbnail of it (`Image.file(File(_tempPhotoPath))`).
   - During `_createPlant()`, if `_tempPhotoPath` is not null, use `await ref.read(photoStoreProvider).savePhoto(_tempPhotoPath!)` to get the `photoRef`.
   - Assign the `photoRef` to `_draft.photoRef` before calling `_draft.toPlant()`.
</action>
<acceptance_criteria>
grep "ImagePicker" lib/features/plant_wizard/plant_wizard_screen.dart && grep "photoStoreProvider" lib/features/plant_wizard/plant_wizard_screen.dart
</acceptance_criteria>
</task>

### 5. Captura de Foto para Eventos (Quick Log)
Enable adding a `PhotoAddedEvent` from the Quick Log timeline action, allowing users to capture photos for events.

<task>
<read_first>
- lib/features/quick_log/quick_log.dart
- lib/features/quick_log/quick_log_forms.dart
</read_first>
<action>
1. Edit `lib/features/quick_log/quick_log.dart`:
   - Change `enabled: false` to `enabled: true` for the `QuickLogAction.photo` action.
   - Remove the `sublabel` "Em breve" from the photo action.
2. Edit `lib/features/quick_log/quick_log_forms.dart`:
   - Add a case for `QuickLogAction.photo` in `QuickLogForm` that displays a `_PhotoEventForm` widget.
   - In `_PhotoEventForm`, implement UI to pick a photo (Camera/Gallery) using `ImagePicker`.
   - On save, compress and save the photo using `ref.read(photoStoreProvider).savePhoto(tempPath)`.
   - Return a `PhotoAddedEvent` populated with the resulting `photoRef`.
</action>
<acceptance_criteria>
grep "enabled: true" lib/features/quick_log/quick_log.dart && grep "QuickLogAction.photo" lib/features/quick_log/quick_log_forms.dart
</acceptance_criteria>
</task>

### 6. Exibição da foto no Perfil e Timeline
Display the saved photo on the plant's profile and support `PhotoAddedEvent` in the timeline if it has a photo.

<task>
<read_first>
- lib/features/plant_profile/plant_profile_screen.dart
</read_first>
<action>
1. Edit `lib/features/plant_profile/plant_profile_screen.dart`.
2. Create a small Riverpod `FutureProvider.family<String?, String>` named `photoPathProvider` in the file (or outside) to resolve a `photoRef` to an absolute path using `ref.watch(photoStoreProvider).getPhotoPath(photoRef)`.
3. Convert `_PlantHeader` to a `ConsumerWidget` in order to access `ref.watch`. If `plant.photoRef` is not null, use `ref.watch(photoPathProvider(plant.photoRef!))` to asynchronously load the file path. While loading, show a placeholder. When loaded, display `Image.file(File(path))` in a circular avatar or rounded box.
4. Convert `_EventTile` to a `ConsumerWidget` in order to access `ref.watch`. If `event is PhotoAddedEvent` and `event.photoRef != null`, also use the provider to display a small thumbnail in the timeline.
</action>
<acceptance_criteria>
grep "photoPathProvider" lib/features/plant_profile/plant_profile_screen.dart && grep "Image.file" lib/features/plant_profile/plant_profile_screen.dart
</acceptance_criteria>
</task>
