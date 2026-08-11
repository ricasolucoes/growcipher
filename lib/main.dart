import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_database.dart';
import 'data/sqlite_plant_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Banco local, offline — nada sai do aparelho.
  final database = await AppDatabase().open();

  runApp(GrowCipherApp(repository: SqlitePlantRepository(database)));
}
