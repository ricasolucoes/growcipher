import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'data/sqlite_plant_repository.dart';
import 'domain/repositories/plant_repository.dart';
import 'domain/photos/photo_store.dart';
import 'data/local_photo_store.dart';

final appDatabaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in ProviderScope');
});

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SqlitePlantRepository(db);
});

final photoStoreProvider = Provider<PhotoStore>((ref) {
  return LocalPhotoStore();
});
