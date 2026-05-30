import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();
  String? _lastError;

  String? get lastError => _lastError;

  Future<bool> canAuthenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck || isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> hasEnrolledBiometrics() async {
    try {
      final availableBiometrics = await _auth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate({required String reason}) async {
    _lastError = null;
    try {
      final result = await _auth.authenticate(
        localizedReason: reason,
      );
      return result;
    } catch (e, st) {
      _lastError = e.toString();
      // keep stack for developer inspection
      // ignore: avoid_print
      print('BiometricAuthService.authenticate error: $_lastError');
      // ignore: avoid_print
      print(st);
      return false;
    }
  }
}
