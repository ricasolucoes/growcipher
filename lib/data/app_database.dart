import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'gamification_schema.dart';

/// Banco local do GrowCipher.
///
/// Esquema versionado por migrations aditivas: cada versão é uma lista de
/// statements em [_migrations]. `onCreate` executa todas; `onUpgrade` executa
/// apenas as versões que faltam — nunca se recria o banco de forma
/// destrutiva. Quando o cofre criptografado (SQLCipher, Phase 2 do roadmap)
/// chegar, troca-se a factory/abertura mantendo o mesmo esquema.
class AppDatabase {
  AppDatabase({DatabaseFactory? factory})
    : _factory = factory ?? databaseFactory;

  final DatabaseFactory _factory;

  static const String fileName = 'growcipher.db';
  static const int version = 2;

  /// `_migrations[n - 1]` leva o banco da versão `n - 1` para a versão `n`.
  static const List<List<String>> _migrations = [
    // v1 — plantas + linha do tempo.
    [
      '''
      CREATE TABLE plants (
        id TEXT PRIMARY KEY,
        display_name TEXT,
        privacy_code TEXT NOT NULL,
        photo_ref TEXT,
        starting_point TEXT NOT NULL,
        origin TEXT NOT NULL,
        origin_details TEXT,
        strain TEXT,
        genetic_type TEXT NOT NULL,
        start_date INTEGER,
        start_date_is_approximate INTEGER NOT NULL DEFAULT 0,
        seed_obtained_date INTEGER,
        rooted_date INTEGER,
        environment TEXT NOT NULL,
        environment_place TEXT,
        environment_name TEXT,
        growing_medium TEXT NOT NULL,
        container_type TEXT,
        container_volume_liters REAL,
        irrigation_mode TEXT NOT NULL,
        irrigation_system TEXT,
        phase TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE plant_events (
        id TEXT PRIMARY KEY,
        plant_id TEXT NOT NULL REFERENCES plants(id),
        type TEXT NOT NULL,
        occurred_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        notes TEXT,
        payload TEXT NOT NULL DEFAULT '{}'
      )
      ''',
      '''
      CREATE INDEX idx_plant_events_plant_time
        ON plant_events(plant_id, occurred_at DESC)
      ''',
    ],
    // v2 — progressão local (estado, ledger de XP, contadores, conquistas).
    gamificationMigrationV2,
  ];

  /// Abre (criando/migrando se preciso) o banco. [path] é sobrescrevível
  /// para testes (`inMemoryDatabasePath`).
  Future<Database> open({String? path}) async {
    final resolvedPath =
        path ?? p.join(await _factory.getDatabasesPath(), fileName);

    return _factory.openDatabase(
      resolvedPath,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, version) => _apply(db, from: 0, to: version),
        onUpgrade: (db, oldVersion, newVersion) =>
            _apply(db, from: oldVersion, to: newVersion),
      ),
    );
  }

  Future<void> _apply(Database db, {required int from, required int to}) async {
    for (var v = from; v < to; v++) {
      for (final statement in _migrations[v]) {
        await db.execute(statement);
      }
    }
  }
}
