---
wave: 1
depends_on: []
files_modified:
  - pubspec.yaml
  - lib/providers.dart
  - lib/data/app_database.dart
  - lib/core/security/secure_storage_service.dart
  - lib/core/security/local_auth_service.dart
  - lib/main.dart
  - ios/Runner/Info.plist
  - android/app/src/main/AndroidManifest.xml
  - android/app/src/main/kotlin/com/growcipher/growcipher/MainActivity.kt
autonomous: true
---

# Phase 2: Arquitetura de Banco e Segurança

## Goal
Implement master key generation/storage, local authentication (biometrics), and SQLCipher database encryption.

## Tasks

<task>
  <read_first>
    - pubspec.yaml
  </read_first>
  <action>
    <![CDATA[
    Run the following commands to update the dependencies:
    1. `flutter pub remove sqflite`
    2. `flutter pub add sqflite_sqlcipher flutter_secure_storage local_auth`
    ]]>
  </action>
  <acceptance_criteria>
    grep "sqflite_sqlcipher:" pubspec.yaml && grep "flutter_secure_storage:" pubspec.yaml && grep "local_auth:" pubspec.yaml
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - pubspec.yaml
  </read_first>
  <action>
    <![CDATA[
    Create the file `lib/core/security/secure_storage_service.dart` with a class `SecureStorageService`.
    This class should use `FlutterSecureStorage` to manage a 256-bit (32 bytes) master encryption key and user preferences.
    1. Provide a method: `Future<String> getMasterKey()`. If the key doesn't exist, it should generate a secure random 32-byte key (using `dart:math` Random.secure), encode it in Base64, save it to `flutter_secure_storage` under a key like 'db_master_key', and return it.
    2. Provide methods `Future<bool> isBiometricEnabled()` and `Future<void> setBiometricEnabled(bool enabled)` to store/retrieve a boolean flag indicating if biometrics are enabled (defaulting to false).
    ]]>
  </action>
  <acceptance_criteria>
    grep "class SecureStorageService" lib/core/security/secure_storage_service.dart && grep "isBiometricEnabled" lib/core/security/secure_storage_service.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/data/app_database.dart
  </read_first>
  <action>
    <![CDATA[
    Update `lib/data/app_database.dart`:
    1. Change the import `package:sqflite/sqflite.dart` to `package:sqflite_sqlcipher/sqflite.dart`.
    2. Modify the `open` method to accept an optional `String? password`.
    3. Pass the `password` to `_factory.openDatabase(..., password: password)`.
    4. Implement MVP behavior to handle old unencrypted databases: before returning the DB in `open`, wrap the `openDatabase` call in a try/catch. If an exception occurs (likely `DatabaseException` due to encryption mismatch from Phase 1 test DBs), call `await _factory.deleteDatabase(resolvedPath);` and then retry the `openDatabase` call.
    ]]>
  </action>
  <acceptance_criteria>
    grep "package:sqflite_sqlcipher/sqflite.dart" lib/data/app_database.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - pubspec.yaml
  </read_first>
  <action>
    <![CDATA[
    Create `lib/core/security/local_auth_service.dart` with a class `LocalAuthService`.
    It should wrap the `LocalAuthentication` package, providing a method `Future<bool> authenticate()` that checks for available biometrics (`canCheckBiometrics` or `isDeviceSupported()`) and calls `authenticate(localizedReason: 'Desbloquear o GrowCipher', options: const AuthenticationOptions(biometricOnly: false))`.
    If biometrics are not supported or not set up, it should gracefully allow the PIN/device passcode fallback due to `biometricOnly: false`.
    ]]>
  </action>
  <acceptance_criteria>
    grep "LocalAuthentication" lib/core/security/local_auth_service.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - lib/main.dart
    - lib/app.dart
    - lib/providers.dart
  </read_first>
  <action>
    <![CDATA[
    Update `lib/main.dart`, `lib/app.dart`, and `lib/providers.dart`:
    1. In `main()`, instantiate `SecureStorageService` and `LocalAuthService`.
    2. Check `await secureStorageService.isBiometricEnabled()`. If true, require authentication (`await localAuthService.authenticate()`) *before* running the app. If it returns false (user canceled), exit using `SystemChannels.platform.invokeMethod('SystemNavigator.pop');` (import `package:flutter/services.dart`).
    3. Call `await secureStorageService.getMasterKey()` to retrieve the database encryption key.
    4. Initialize the database by calling `final appDb = AppDatabase(); await appDb.open(password: key);`.
    5. Update `lib/providers.dart` to modify `appDatabaseProvider` to be an uninitialized or basic provider. Then, in `main.dart`, pass the initialized database to Riverpod using `ProviderScope(overrides: [appDatabaseProvider.overrideWithValue(appDb)])`.
    6. In `lib/app.dart`, wrap the main view in a `WidgetsBindingObserver` (e.g. by using a Stateful widget) that listens to `didChangeAppLifecycleState`. If the app resumes from the background (`AppLifecycleState.paused` -> `resumed`) and biometrics are enabled, trigger `LocalAuthService.authenticate()`.
    ]]>
  </action>
  <acceptance_criteria>
    grep "isBiometricEnabled" lib/main.dart && grep "overrideWithValue" lib/main.dart && grep "appDatabaseProvider" lib/providers.dart && grep "WidgetsBindingObserver" lib/app.dart
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - ios/Runner/Info.plist
  </read_first>
  <action>
    <![CDATA[
    Add the `NSFaceIDUsageDescription` key and a string value (e.g., "GrowCipher requer autenticação para proteger os dados do seu cultivo.") to `ios/Runner/Info.plist`.
    Make sure to insert it properly within the main `<dict>`.
    ]]>
  </action>
  <acceptance_criteria>
    grep "NSFaceIDUsageDescription" ios/Runner/Info.plist
  </acceptance_criteria>
</task>

<task>
  <read_first>
    - android/app/src/main/AndroidManifest.xml
    - android/app/src/main/kotlin/com/growcipher/growcipher/MainActivity.kt
  </read_first>
  <action>
    <![CDATA[
    Update Android configuration for `local_auth`:
    1. In `android/app/src/main/AndroidManifest.xml`, add `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>` inside the `<manifest>` tag.
    2. In `android/app/src/main/kotlin/com/growcipher/growcipher/MainActivity.kt`, update the class to extend `FlutterFragmentActivity` instead of `FlutterActivity`. You will need to change the import `io.flutter.embedding.android.FlutterActivity` to `io.flutter.embedding.android.FlutterFragmentActivity`.
    ]]>
  </action>
  <acceptance_criteria>
    grep "USE_BIOMETRIC" android/app/src/main/AndroidManifest.xml && grep "FlutterFragmentActivity" android/app/src/main/kotlin/com/growcipher/growcipher/MainActivity.kt
  </acceptance_criteria>
</task>

## Verification
- Dependencies successfully installed.
- Secure storage accurately generates and returns the key.
- SQLCipher is correctly configured to use the password.
- Application conditionally requires biometric or fallback auth on startup based on user preference.
- Riverpod provides the correctly initialized `AppDatabase`.

## Must Haves
- [ ] Database is completely unreadable without the master key (at-rest encryption).
- [ ] iOS target supports Face ID correctly via `Info.plist`.
- [ ] Android target supports biometrics via `FlutterFragmentActivity` and permissions.
