import 'package:flutter/material.dart';

import 'app.dart';
import 'data/app_database.dart';
import 'data/database_factory.dart';
import 'data/gamified_plant_repository.dart';
import 'data/sqlite_gamification_repository.dart';
import 'data/sqlite_plant_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDatabaseFactory();

  // Banco local, offline — nada sai do aparelho.
  final database = await AppDatabase().open();

  // A progressão local decora o repositório de plantas: todo evento que
  // entra na linha do tempo pontua, e nada de cultivo depende disso para
  // funcionar (`docs/Gamificacao.md`).
  final repository = GamifiedPlantRepository(
    inner: SqlitePlantRepository(database),
    gamification: SqliteGamificationRepository(database),
    onProgressError: (error, stack) =>
        debugPrint('progressão indisponível neste registro: $error'),
  );

  runApp(GrowCipherApp(repository: repository));
}
