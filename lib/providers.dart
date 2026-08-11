import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/app_database.dart';
import 'data/sqlite_plant_repository.dart';
import 'domain/repositories/plant_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError('appDatabaseProvider must be overridden in ProviderScope');
});

final plantRepositoryProvider = Provider<PlantRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SqlitePlantRepository(db);
});
