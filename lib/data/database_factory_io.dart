import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Usa SQLite via FFI nas plataformas desktop sem plugin nativo do sqflite.
Future<void> configureDatabaseFactoryImpl() async {
  final isDesktopFfi =
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux;

  if (!isDesktopFfi) return;

  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}
