import 'database_factory_stub.dart'
    if (dart.library.io) 'database_factory_io.dart';

/// Configura a implementação SQLite apropriada para a plataforma atual.
Future<void> configureDatabaseFactory() => configureDatabaseFactoryImpl();
