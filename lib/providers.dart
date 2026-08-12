import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_sqlcipher/sqflite.dart';
import 'data/sqlite_plant_repository.dart';
import 'domain/repositories/plant_repository.dart';

final appDatabaseProvider = Provider<Database>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in ProviderScope');
});

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SqlitePlantRepository(db);
});
