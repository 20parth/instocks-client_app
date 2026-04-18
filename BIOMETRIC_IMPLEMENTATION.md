# Biometric Authentication Implementation

## Overview

This document describes the biometric authentication (fingerprint, Face ID, Touch ID, PIN, Pattern, Password) implementation for the Instocks Client app, designed with a premium UI similar to PhonePe.

## Features Implemented

### 1. **First-Time Biometric Setup Flow**
- After successful login, users are prompted to set up biometric authentication
- Premium animated setup screen with gradient background
- Shows different icons based on available biometric types:
  - Face ID (iOS)
  - Fingerprint (Android/iOS)
  - Iris
  - PIN/Pattern/Password (Android device security)
- Users can skip setup and enable it later from settings
- Setup is only prompted once per device

### 2. **App Lock Screen**
- Premium lock screen with gradient background and glowing lock icon
- Shown when app is launched or resumed from background if biometric is enabled
- "Unlock App" button triggers device biometric authentication
- Security message at bottom: "Protected by device security"

### 3. **Enhanced Security Settings Screen**
- Located in Profile > Security
- Premium gradient header card showing current status
- Toggle switch to enable/disable biometric authentication
- Feature cards explaining benefits:
  - Quick Access
  - Enhanced Security
  - Privacy Guaranteed
- Easy disable option with confirmation dialog

### 4. **Cross-Platform Support**

#### Android
- Fingerprint scanner support
- PIN/Pattern/Password fallback
- Required permissions added to AndroidManifest.xml:
  ```xml
  <uses-permission android:name="android.permission.USE_BIOMETRIC"/>
  <uses-permission android:name="android.permission.USE_FINGERPRINT"/>
  ```

#### iOS
- Face ID support
- Touch ID support
- Usage description in Info.plist:
  ```xml
  <key>NSFaceIDUsageDescription</key>
  <string>Use Face ID to securely access your Instocks account</string>
  ```

## Implementation Details

### Files Modified/Created

1. **New Files:**
   - `lib/features/auth/biometric_setup_screen.dart` - First-time setup screen

2. **Modified Files:**
   - `android/app/src/main/AndroidManifest.xml` - Added biometric permissions
   - `lib/core/auth/biometric_service.dart` - Enhanced with setup tracking
   - `lib/features/auth/session_controller.dart` - Added biometric setup prompt logic
   - `lib/app/instocks_client_app.dart` - Updated app flow and lock screen UI
   - `lib/features/profile/security_settings_screen.dart` - Premium UI redesign
   - `lib/features/client/client_api.dart` - Added device token registration API
   - `lib/main.dart` - Updated dependency injection

### Architecture

```
User Login
    ↓
Session Controller checks if biometric setup should be prompted
    ↓
    ├─ If yes → Show BiometricSetupScreen
    │              ↓
    │              ├─ User enables → Save preference → Go to app
    │              └─ User skips → Mark as prompted → Go to app
    │
    └─ If no → Check if app lock is enabled
                   ↓
                   ├─ If yes → Show LockedScreen
                   │              ↓
                   │              User authenticates → Go to app
                   │
                   └─ If no → Go directly to app
```

### BiometricService API

```dart
class BiometricService {
  // Check if device supports biometric authentication
  Future<bool> canAuthenticate();
  
  // Check if device has security enabled
  Future<bool> isDeviceSecured();
  
  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics();
  
  // Trigger biometric authentication
  Future<bool> authenticate({String reason});
  
  // Get/set app lock enabled state
  bool get isAppLockEnabled;
  Future<void> setAppLockEnabled(bool enabled);
  
  // Track if setup was prompted
  bool get hasPromptedSetup;
  Future<void> markSetupPrompted();
}
```

### SessionController Flow

```dart
class SessionController {
  // After successful login:
  // 1. Check if we should prompt for biometric setup
  // 2. If conditions met, set shouldPromptBiometricSetup = true
  // 3. App shows BiometricSetupScreen
  
  bool get shouldPromptBiometricSetup;
  void dismissBiometricSetup(); // Called after setup screen is dismissed
}
```

## User Experience Flow

### First-Time Login
1. User logs in successfully
2. If device supports biometrics AND setup hasn't been prompted before:
   - Show premium biometric setup screen
   - User can enable or skip
3. User enters app

### Subsequent App Opens (with biometric enabled)
1. App shows lock screen with gradient and glowing icon
2. User taps "Unlock App"
3. Device biometric authentication is triggered
4. On success, user enters app
5. On failure, user can retry

### App Resume from Background (with biometric enabled)
1. When app resumes, authentication is checked
2. Lock screen is shown if not authenticated
3. User authenticates to continue

### Managing Biometric Settings
1. User goes to Profile > Security
2. Premium settings screen shows current status
3. User can toggle biometric on/off
4. Enabling requires authentication
5. Disabling shows confirmation dialog

## Device Token Registration API

For push notifications, the `ClientApi` now includes:

```dart
Future<void> registerDeviceToken({
  required String deviceToken,
  required String platform, // 'android' or 'ios'
  String? deviceName,
});
```

This calls the backend endpoint: `POST /api/client/device-tokens`

## UI Design Highlights

### Premium Features
- Gradient backgrounds (different for light/dark mode)
- Glowing icons with shadow effects
- Smooth animations on setup screen
- Material 3 design components
- Consistent with app's existing Inter font and color scheme

### Color Scheme
- Primary: #37C6F4 (cyan blue)
- Dark mode backgrounds: #09111F, #0E1727, #162944
- Light mode backgrounds: #F8FAFC, #E2E8F0, #CBD5E1

### Animations
- Scale and fade animations on setup screen
- Elastic ease-out for icon appearance
- 800ms animation duration for premium feel

## Testing Recommendations

### Android Testing
```bash
# Run with local API
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api

# Test on different Android versions:
# - Android 6.0+ for fingerprint
# - Android 9.0+ for BiometricPrompt
# - Test PIN/Pattern/Password fallback
```

### iOS Testing
```bash
# Run on simulator
flutter run -d ios --dart-define=API_BASE_URL=http://localhost:8000/api

# Test Face ID in simulator: Features > Face ID > Enrolled
# Test Touch ID in simulator: Features > Touch ID > Enrolled

# Physical device testing recommended for actual biometric hardware
```

### Test Cases
1. ✅ First login prompts biometric setup
2. ✅ Skip setup works and doesn't prompt again
3. ✅ Enable biometric from settings
4. ✅ App lock screen appears on app launch
5. ✅ App lock screen appears on resume from background
6. ✅ Correct biometric type icon shows (Face ID vs Fingerprint)
7. ✅ Disable biometric from settings
8. ✅ Device without biometric shows appropriate message
9. ✅ Authentication failure allows retry
10. ✅ Settings show current status correctly

## Production Deployment

### Build Commands

**Android:**
```bash
# Debug
flutter build apk --dart-define=API_BASE_URL=https://api-portfolio.instocks.net/api

# Release
flutter build appbundle --release --dart-define=API_BASE_URL=https://api-portfolio.instocks.net/api
```

**iOS:**
```bash
flutter build ios --release --dart-define=API_BASE_URL=https://api-portfolio.instocks.net/api
```

### Prerequisites
- Ensure backend is running at the configured API_BASE_URL
- Ensure `/api/client/device-tokens` endpoint is available for push notifications
- Test with real device hardware for accurate biometric testing

## Future Enhancements

Consider these additions:

1. **Biometric for Sensitive Actions**
   - Require authentication before viewing full portfolio details
   - Require authentication before logging out
   - Require authentication before changing profile

2. **Enhanced Security**
   - Add timeout for automatic re-lock
   - Add failed authentication attempt tracking
   - Add option to require authentication for specific features

3. **User Preferences**
   - Allow users to choose between different auth types
   - Add "Remember me for X minutes" option
   - Add biometric for individual portfolio access

## Known Limitations

1. iOS Simulator may not accurately represent all biometric scenarios
2. Some older Android devices may only support PIN/Pattern/Password
3. Biometric availability depends on device hardware and OS version
4. The backend export API (`/api/client/reports/export`) is not yet available

## Support

For issues or questions about biometric implementation:
1. Check device supports biometric authentication
2. Verify permissions are correctly set in manifests
3. Test on physical devices when possible
4. Review BiometricService logs in debug mode
