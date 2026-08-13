---
wave: 5.2
depends_on:
  - 05-exporta-o-e-relat-rios-1-PLAN
files_modified:
  - pubspec.yaml
  - lib/domain/models/plant.dart
  - lib/domain/models/plant_event.dart
  - lib/domain/photos/photo_store.dart
  - lib/data/local_photo_store.dart
  - lib/data/backup_service.dart
  - lib/providers.dart
  - lib/features/settings/export_screen.dart
  - lib/features/home/home_screen.dart
  - lib/app.dart
autonomous: true
---

# Phase 5: Backup e Exportação Segura

## Objective
Implementar um sistema de exportação seguro onde os dados do usuário (plantas, eventos em JSON e fotos) são agrupados em um arquivo ZIP e criptografados localmente com AES-256 usando uma senha fornecida pelo usuário, gerando um `.enc` para compartilhamento externo.

## Tasks

```xml
<task>
  <read_first>
    - pubspec.yaml
  </read_first>
  <action>
    <![CDATA[
      Add the following dependencies to `pubspec.yaml` using the shell:
      `flutter pub add archive encrypt share_plus crypto`
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "archive:" pubspec.yaml
    grep -q "encrypt:" pubspec.yaml
    grep -q "share_plus:" pubspec.yaml
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/domain/models/plant.dart
    - lib/domain/models/plant_event.dart
  </read_first>
  <action>
    <![CDATA[
      Add `Map<String, dynamic> toMap()` serialization to models:
      1. In `lib/domain/models/plant.dart`, add `Map<String, dynamic> toMap()` returning all its fields (convert enums to `.name`, and dates to ISO strings via `?.toIso8601String()`).
      2. In `lib/domain/models/plant_event.dart`, add `Map<String, dynamic> toMap()` inside the `PlantEvent` base class returning `{'id': id, 'plantId': plantId, 'occurredAt': occurredAt.toIso8601String(), 'createdAt': createdAt.toIso8601String(), 'notes': notes, 'type': type.name, 'payload': payloadToMap()}`.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "Map<String, dynamic> toMap()" lib/domain/models/plant.dart
    grep -q "Map<String, dynamic> toMap()" lib/domain/models/plant_event.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/domain/photos/photo_store.dart
    - lib/data/local_photo_store.dart
  </read_first>
  <action>
    <![CDATA[
      Add a method to get all photos for the backup:
      1. In `lib/domain/photos/photo_store.dart`, add `Future<List<String>> getAllPhotos();` returning a list of paths.
      2. In `lib/data/local_photo_store.dart`, implement it by fetching `getApplicationDocumentsDirectory()`, listing files inside it, and returning their `.path` if they end with `.jpg`.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "getAllPhotos()" lib/domain/photos/photo_store.dart
    grep -q "getAllPhotos()" lib/data/local_photo_store.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/domain/repositories/plant_repository.dart
    - lib/data/sqlite_plant_repository.dart
  </read_first>
  <action>
    <![CDATA[
      Add a method to get all events for the backup:
      1. In `lib/domain/repositories/plant_repository.dart`, add `Future<List<PlantEvent>> getAllEvents();`.
      2. In `lib/data/sqlite_plant_repository.dart`, implement it by querying the `plant_events` table for all rows without a `plant_id` filter (e.g. `await _db.query('plant_events')`) and mapping them via `_eventFromRow`.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "getAllEvents()" lib/domain/repositories/plant_repository.dart
    grep -q "getAllEvents()" lib/data/sqlite_plant_repository.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/domain/repositories/plant_repository.dart
    - lib/domain/photos/photo_store.dart
  </read_first>
  <action>
    <![CDATA[
      Create `lib/data/backup_service.dart` containing `BackupService`:
      1. Imports: `dart:convert`, `dart:io`, `dart:typed_data`, `package:archive/archive.dart`, `package:crypto/crypto.dart`, `package:encrypt/encrypt.dart` as encrypt, `package:path_provider/path_provider.dart`, `package:path/path.dart` as p.
      2. Inject `PlantRepository _plantRepo` and `PhotoStore _photoStore`.
      3. Implement `Future<File> createExport(String password) async`:
         - Fetch all plants and events via `_plantRepo.getPlants()` and `_plantRepo.getAllEvents()`.
         - Build a JSON map: `{'version': 1, 'plants': plants.map((p) => p.toMap()).toList(), 'events': allEvents.map((e) => e.toMap()).toList()}`.
         - Serialize JSON to bytes `utf8.encode(jsonEncode(data))`.
         - Create an `Archive` and add `ArchiveFile('data.json', bytes.length, bytes)`.
         - Fetch photos via `_photoStore.getAllPhotos()`, read each file, and add it to the archive `ArchiveFile(p.basename(path), photoBytes.length, photoBytes)`.
         - Encode ZIP via `ZipEncoder().encode(archive)`.
         - Derive encryption key using SHA-256 on the password: `final keyBytes = sha256.convert(utf8.encode(password)).bytes;` `final key = encrypt.Key(Uint8List.fromList(keyBytes));`
         - Generate IV: `final iv = encrypt.IV.fromLength(16);`
         - Encrypt the ZIP bytes: `final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));` `final encrypted = encrypter.encryptBytes(zipBytes!, iv: iv);`
         - Construct final bytes: `iv.bytes + encrypted.bytes` (prepending IV).
         - Save to `growcipher_backup.enc` in `getTemporaryDirectory()` and return the `File`.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "class BackupService" lib/data/backup_service.dart
    grep -q "ZipEncoder" lib/data/backup_service.dart
    grep -q "encrypter.encryptBytes" lib/data/backup_service.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/providers.dart
    - lib/features/home/home_screen.dart
    - lib/app.dart
  </read_first>
  <action>
    <![CDATA[
      Wire the UI for exporting:
      1. In `lib/providers.dart`, add `final backupServiceProvider = Provider<BackupService>((ref) => BackupService(ref.watch(plantRepositoryProvider), ref.watch(photoStoreProvider)));`.
      2. Create `lib/features/settings/export_screen.dart` (StatefulWidget) with route `static const String route = '/export';`.
      3. Add a `TextField` (obscureText) for the password and a `FilledButton` to trigger the export.
      4. In the export logic, read `backupServiceProvider`, call `createExport(password)`, then share it via `Share.shareXFiles([XFile(file.path)], text: 'GrowCipher Backup')` from `share_plus`.
      5. Add an `IconButton` in `lib/features/home/home_screen.dart` AppBar actions with `Icons.import_export` or `Icons.settings` leading to `ExportScreen.route`.
      6. Register `ExportScreen.route => (_) => const ExportScreen()` in `lib/app.dart`'s `_onGenerateRoute`.
    ]]>
  </action>
  <acceptance_criteria>
    grep -q "backupServiceProvider" lib/providers.dart
    grep -q "class ExportScreen" lib/features/settings/export_screen.dart
    grep -q "ExportScreen.route" lib/app.dart
    grep -q "Icons.import_export" lib/features/home/home_screen.dart
  </acceptance_criteria>
</task>
```

## Verification
- Exporting the data generates a `growcipher_backup.enc` file.
- The user can share it via native share dialog (share_plus).
- It prompts for a password before exporting.

## Must Haves
- The JSON dump must contain everything needed for a future restore (all fields mapped).
- The AES IV must be prepended to the final `.enc` file (standard convention) to allow future decryption.
- Don't block the UI infinitely. Since encrypting/zipping is heavy, it might block the main thread, but a simple `await` is enough for MVP.
