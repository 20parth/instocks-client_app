import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
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

  /// Check if device supports biometric OR device credential (PIN/Pattern/Password)
  Future<bool> canAuthenticate() async {
    try {
      // Check if device supports biometrics
      final canCheckBiometrics = await _auth.canCheckBiometrics;

      // Check if device is supported (can use PIN/Pattern/Password)
      final isDeviceSupported = await _auth.isDeviceSupported();

      // Return true if either biometrics OR device credentials are available
      final result = canCheckBiometrics || isDeviceSupported;

      debugPrint(
          'BiometricService: canCheckBiometrics=$canCheckBiometrics, isDeviceSupported=$isDeviceSupported, result=$result');

      return result;
    } catch (e) {
      debugPrint('BiometricService: canAuthenticate error: $e');
      return false;
    }
  }

  /// Check if device has security set up (biometric OR PIN/Pattern/Password)
  Future<bool> isDeviceSecured() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (e) {
      debugPrint('BiometricService: isDeviceSecured error: $e');
      return false;
    }
  }

  /// Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final types = await _auth.getAvailableBiometrics();
      debugPrint('BiometricService: Available biometrics: $types');
      return types;
    } catch (e) {
      debugPrint('BiometricService: getAvailableBiometrics error: $e');
      return [];
    }
  }

  /// Get user-friendly authentication type info
  Future<Map<String, dynamic>> getAuthInfo() async {
    try {
      final canCheckBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      final types = await getAvailableBiometrics();

      String label = 'Device Security';
      IconData icon = Icons.security_rounded;

      // Check for specific biometric types first
      if (types.contains(BiometricType.face)) {
        label = 'Face ID';
        icon = Icons.face_rounded;
      } else if (types.contains(BiometricType.fingerprint)) {
        label = 'Fingerprint';
        icon = Icons.fingerprint_rounded;
      } else if (types.contains(BiometricType.iris)) {
        label = 'Iris';
        icon = Icons.remove_red_eye_rounded;
      } else if (isDeviceSupported && !canCheckBiometrics) {
        // Device supports auth but no biometrics = PIN/Pattern/Password
        label = 'PIN, Pattern or Password';
        icon = Icons.pin_rounded;
      }

      return {
        'available': canCheckBiometrics || isDeviceSupported,
        'label': label,
        'icon': icon,
        'hasBiometric': canCheckBiometrics,
        'hasDeviceCredential': isDeviceSupported,
      };
    } catch (e) {
      debugPrint('BiometricService: getAuthInfo error: $e');
      return {
        'available': false,
        'label': 'Not Available',
        'icon': Icons.error_outline_rounded,
        'hasBiometric': false,
        'hasDeviceCredential': false,
      };
    }
  }

  /// Authenticate using biometric OR device credentials (PIN/Pattern/Password)
  /// biometricOnly=false allows fallback to PIN/Pattern/Password
  Future<bool> authenticate({
    String reason = 'Authenticate to access Instocks',
    bool biometricOnly = false,
  }) async {
    try {
      final canAuth = await canAuthenticate();
      if (!canAuth) {
        debugPrint(
            'BiometricService: Cannot authenticate - device not supported');
        return false;
      }

      debugPrint(
          'BiometricService: Starting authentication with reason: $reason');

      final result = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly, // Allow PIN/Pattern/Password fallback
          useErrorDialogs: true,
          sensitiveTransaction: false,
        ),
      );

      debugPrint('BiometricService: Authentication result: $result');
      return result;
    } catch (e) {
      debugPrint('BiometricService: authenticate error: $e');
      return false;
    }
  }
}
