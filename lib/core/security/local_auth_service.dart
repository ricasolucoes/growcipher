import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  final LocalAuthentication _auth;

  LocalAuthService({LocalAuthentication? auth}) 
      : _auth = auth ?? LocalAuthentication();

  Future<bool> authenticate() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      
      if (!isSupported && !canCheck) {
        return false;
      }

      return await _auth.authenticate(
        localizedReason: 'Desbloquear o GrowCipher',
        biometricOnly: false,
      );
    } catch (e) {
      return false;
    }
  }
}
