import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  BiometricService(this._prefs);

  final SharedPreferences _prefs;
  final LocalAuthentication _auth = LocalAuthentication();

  static const _enabledKey = 'app_lock_enabled';
  static const _setupPromptedKey = 'biometric_setup_prompted';

  bool get isAppLockEnabled => _prefs.getBool(_enabledKey) ?? false;
  bool get hasPromptedSetup => _prefs.getBool(_setupPromptedKey) ?? false;

  Future<void> setAppLockEnabled(bool enabled) async {
    await _prefs.setBool(_enabledKey, enabled);
  }

  Future<void> markSetupPrompted() async {
    await _prefs.setBool(_setupPromptedKey, true);
  }

  Future<bool> canAuthenticate() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canCheck || isDeviceSupported;
    } catch (e) {
      debugPrint('Biometric check error: $e');
      return false;
    }
  }

  Future<bool> isDeviceSecured() async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) return false;
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('Device security check error: $e');
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Get biometrics error: $e');
      return [];
    }
  }

  Future<bool> authenticate({
    String reason = 'Authenticate to access Instocks',
  }) async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) return false;

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } catch (e) {
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }
}
