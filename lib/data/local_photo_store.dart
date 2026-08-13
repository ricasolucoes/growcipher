import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as p;
import '../domain/photos/photo_store.dart';

class LocalPhotoStore implements PhotoStore {
  final _uuid = const Uuid();

  @override
  Future<String> savePhoto(String tempPath) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final photoRef = '${_uuid.v4()}.jpg';
    final targetPath = p.join(docsDir.path, photoRef);

    // Compress and strip EXIF
    await FlutterImageCompress.compressAndGetFile(
      tempPath,
      targetPath,
      quality: 85,
    );

    return photoRef;
  }

  @override
  Future<String?> getPhotoPath(String photoRef) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final targetPath = p.join(docsDir.path, photoRef);
    
    final file = File(targetPath);
    if (await file.exists()) {
      return targetPath;
    }
    return null;
  }

  @override
  Future<void> deletePhoto(String photoRef) async {
    final docsDir = await getApplicationDocumentsDirectory();
    final targetPath = p.join(docsDir.path, photoRef);
    
    final file = File(targetPath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
