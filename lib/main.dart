import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/services.dart';
import 'app.dart';
import 'core/security/local_auth_service.dart';
import 'core/security/secure_storage_service.dart';
import 'data/app_database.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final secureStorageService = const SecureStorageService();
  final localAuthService = LocalAuthService();

  final biometricEnabled = await secureStorageService.isBiometricEnabled();
  if (biometricEnabled) {
    final authenticated = await localAuthService.authenticate();
    if (!authenticated) {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return;
    }
  }

  final key = await secureStorageService.getMasterKey();
  final appDb = AppDatabase();
  final database = await appDb.open(password: key);

  runApp(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const GrowCipherApp(),
    ),
  );
}
