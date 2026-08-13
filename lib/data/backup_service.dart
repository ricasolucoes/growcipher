import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../domain/photos/photo_store.dart';
import '../domain/repositories/plant_repository.dart';

class BackupService {
  BackupService(this._plantRepo, this._photoStore);

  final PlantRepository _plantRepo;
  final PhotoStore _photoStore;

  Future<File> createExport(String password) async {
    final plants = await _plantRepo.getPlants();
    final allEvents = await _plantRepo.getAllEvents();

    final data = {
      'version': 1,
      'plants': plants.map((p) => p.toMap()).toList(),
      'events': allEvents.map((e) => e.toMap()).toList(),
    };

    final bytes = utf8.encode(jsonEncode(data));
    final archive = Archive();

    archive.addFile(ArchiveFile('data.json', bytes.length, bytes));

    final photoPaths = await _photoStore.getAllPhotos();
    for (final path in photoPaths) {
      final file = File(path);
      if (await file.exists()) {
        final photoBytes = await file.readAsBytes();
        archive.addFile(
          ArchiveFile(p.basename(path), photoBytes.length, photoBytes),
        );
      }
    }

    final zipBytes = ZipEncoder().encode(archive);

    final keyBytes = sha256.convert(utf8.encode(password)).bytes;
    final key = encrypt.Key(Uint8List.fromList(keyBytes));
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );
    final encrypted = encrypter.encryptBytes(zipBytes!, iv: iv);

    final finalBytes = Uint8List.fromList([...iv.bytes, ...encrypted.bytes]);

    final tempDir = await getTemporaryDirectory();
    final backupFile = File(p.join(tempDir.path, 'growcipher_backup.enc'));

    await backupFile.writeAsBytes(finalBytes);

    return backupFile;
  }
}
