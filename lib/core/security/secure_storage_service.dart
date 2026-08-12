import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  const SecureStorageService({FlutterSecureStorage storage = const FlutterSecureStorage()}) 
      : _storage = storage;

  Future<String> getMasterKey() async {
    final existingKey = await _storage.read(key: 'db_master_key');
    if (existingKey != null) {
      return existingKey;
    }

    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    final newKey = base64UrlEncode(bytes);
    
    await _storage.write(key: 'db_master_key', value: newKey);
    return newKey;
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }
}
