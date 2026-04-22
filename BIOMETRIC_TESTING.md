# Biometric Authentication Testing Guide

## Overview

The app now supports **all device security methods**:
- ✅ Fingerprint (Android/iOS)
- ✅ Face ID (iOS)
- ✅ Touch ID (iOS)
- ✅ PIN (Android/iOS)
- ✅ Pattern (Android)
- ✅ Password (Android/iOS)
- ✅ Iris scan (Samsung devices)

## How It Works

### First-Time Login Flow
1. User logs in with credentials
2. App checks if device supports biometric/PIN/Pattern
3. If supported and not set up before → Show **BiometricSetupScreen**
4. User can:
   - **Enable** → Authenticate once, then app lock is ON
   - **Skip** → Goes to dashboard, app lock stays OFF

### App Lock Behavior
- **When ENABLED:** Every time app launches or resumes, user must authenticate
- **When DISABLED:** App opens directly to dashboard (if logged in)

### Settings Management
- Go to **Profile → Security Settings**
- Toggle app lock ON/OFF anytime
- See which authentication method is available on device

---

## Testing on Android Emulator

### 1. Set Up Fingerprint in Emulator

```bash
# Open Android emulator
# Go to: Settings → Security → Fingerprint

# OR use ADB command:
adb -e emu finger touch 1
```

**Steps:**
1. Open emulator settings
2. Security → Fingerprint
3. Add a fingerprint (tap screen when prompted)
4. Set up a PIN/Pattern as backup

### 2. Test Fingerprint Authentication

**Run the app:**
```bash
flutter run
```

**Test scenarios:**
1. **First login with biometric available:**
   - Login with credentials
   - Should show BiometricSetupScreen with fingerprint icon
   - Tap "Enable App Lock"
   - Authenticate with fingerprint (use: `adb -e emu finger touch 1`)
   - Should go to dashboard
   - Close app and reopen → Should show lock screen

2. **Skip setup:**
   - Fresh install (clear app data)
   - Login with credentials
   - On BiometricSetupScreen, tap "Skip for Now"
   - Should go directly to dashboard
   - Close and reopen → No lock screen (goes to dashboard)

3. **Enable from settings:**
   - Go to Profile → Security Settings
   - Toggle "Fingerprint" switch ON
   - Authenticate with fingerprint
   - Should see success toast
   - Close app and reopen → Lock screen appears

4. **Disable from settings:**
   - Go to Profile → Security Settings
   - Toggle switch OFF
   - Should see confirmation toast
   - Close app and reopen → No lock screen

### 3. Test PIN/Pattern Fallback

When fingerprint fails, Android automatically offers PIN/Pattern option.

**Test:**
1. Enable app lock
2. Close app and reopen
3. On lock screen, tap "Unlock App"
4. Cancel fingerprint → Should show PIN/Pattern option
5. Enter PIN/Pattern → Should unlock

---

## Testing on Android Real Device

### Prerequisites
- Device with fingerprint sensor OR PIN/Pattern set up
- USB debugging enabled
- Device connected via USB

### Steps

1. **Set up device security:**
   - Settings → Security
   - Add fingerprint OR set PIN/Pattern

2. **Run app:**
   ```bash
   flutter run
   ```

3. **Test all scenarios** (same as emulator above)

4. **Test different security methods:**
   - Remove fingerprint, keep only PIN → App uses PIN
   - Add fingerprint → App uses fingerprint with PIN fallback
   - Remove all security → App shows "Not Available" message

---

## Testing on iOS Simulator

### 1. Enable Touch ID in Simulator

**While simulator is running:**
- Menu: `Features → Touch ID → Enrolled`
- This simulates a device with Touch ID set up

### 2. Test Touch ID Authentication

**Run the app:**
```bash
flutter run -d "iPhone 15 Pro"
```

**Test scenarios:**
1. **First login:**
   - Login with credentials
   - Should show BiometricSetupScreen with fingerprint icon (Touch ID)
   - Tap "Enable App Lock"
   - Simulator menu: `Features → Touch ID → Matching Touch`
   - Should authenticate and go to dashboard

2. **Lock screen unlock:**
   - Close app (Cmd+Shift+H)
   - Reopen app
   - Should show lock screen
   - Tap "Unlock App"
   - Simulator menu: `Features → Touch ID → Matching Touch`
   - Should unlock

3. **Failed authentication:**
   - On lock screen
   - Simulator menu: `Features → Touch ID → Non-matching Touch`
   - Should show error, stay locked

4. **Fallback to PIN:**
   - Cancel Touch ID prompt
   - iOS automatically shows passcode entry
   - Enter simulator passcode (default: `1234` or `0000`)

### 3. Enable Face ID in Simulator (iPhone X and later)

**For Face ID devices:**
- Menu: `Features → Face ID → Enrolled`
- Test same scenarios as Touch ID above
- BiometricSetupScreen will show Face ID icon and label

---

## Testing on iOS Real Device

### Prerequisites
- iPhone with Face ID or Touch ID
- Device enrolled in Xcode
- iOS 12.0 or later

### Steps

1. **Set up Face ID/Touch ID:**
   - Settings → Face ID & Passcode (or Touch ID)
   - Ensure Face ID or Touch ID is set up
   - Set a passcode as backup

2. **Run app:**
   ```bash
   flutter run -d <device-id>
   
   # List devices
   flutter devices
   ```

3. **Test Face ID:**
   - Login → BiometricSetupScreen shows "Face ID"
   - Enable → Look at device to authenticate
   - Lock screen → Look at device to unlock

4. **Test Touch ID:**
   - Same as Face ID, but use fingerprint

5. **Test passcode fallback:**
   - When prompted for Face ID/Touch ID
   - Tap "Enter Passcode"
   - Enter device passcode
   - Should authenticate

---

## Testing Different Scenarios

### Scenario 1: Device with NO Security

**Setup:**
- Remove all fingerprints
- Remove PIN/Pattern/Password

**Expected behavior:**
- BiometricSetupScreen shows "Biometric Not Available"
- Security Settings shows warning message
- Toggle is disabled
- App never locks

### Scenario 2: Device with ONLY PIN/Pattern

**Setup:**
- No fingerprint enrolled
- PIN or Pattern set up

**Expected behavior:**
- BiometricSetupScreen shows "PIN/Pattern/Password" with pin icon
- Can enable app lock
- Unlock uses PIN/Pattern

### Scenario 3: Device with Fingerprint + PIN

**Setup:**
- Fingerprint enrolled
- PIN set up as backup

**Expected behavior:**
- BiometricSetupScreen shows "Fingerprint" with fingerprint icon
- Primary method: Fingerprint
- Fallback: PIN (when fingerprint fails)

### Scenario 4: Fresh Install

**Setup:**
- Uninstall app
- Reinstall
- Clear app data: `adb shell pm clear com.instocks.client`

**Expected behavior:**
- First login → BiometricSetupScreen appears
- hasPromptedSetup = false
- Can enable or skip

### Scenario 5: Subsequent Logins

**Setup:**
- Already logged in before
- Already saw BiometricSetupScreen

**Expected behavior:**
- Login → Goes directly to dashboard
- No BiometricSetupScreen (already prompted)
- Can manage in Security Settings

---

## Common Issues & Fixes

### Issue: Black screen after skip

**Cause:** `onComplete` callback not called

**Fixed in:** `lib/features/auth/biometric_setup_screen.dart:99`
- Skip button now calls `widget.onComplete(false)`
- This triggers `dismissBiometricSetup()` in SessionController
- Dashboard appears correctly

### Issue: Toggle doesn't work in Settings

**Cause:** `onChanged` not handling state properly

**Fixed in:** `lib/features/profile/security_settings_screen.dart:160`
- Added `setState(() {})` after enable/disable
- Shows success/error toasts
- Properly updates UI

### Issue: Icons not showing

**Cause:** Biometric type detection logic incomplete

**Fixed in:** Multiple files
- BiometricSetupScreen detects all types: face, fingerprint, iris, strong, weak
- Shows appropriate icons for each type
- Fallback to generic security icon if type unknown

### Issue: Emulator shows "Not Available"

**Cause:** Fingerprint not enrolled in emulator

**Fix:**
```bash
# Enroll fingerprint in emulator
adb -e emu finger touch 1

# OR in emulator settings:
Settings → Security → Fingerprint → Add fingerprint
```

### Issue: iOS Simulator shows "Not Available"

**Cause:** Touch ID not enrolled

**Fix:**
- Simulator menu: `Features → Touch ID → Enrolled`

---

## Debugging Tips

### Enable Debug Logs

The app now prints debug logs for biometric operations:

```dart
BiometricService: canCheckBiometrics=true, isDeviceSupported=true, result=true
BiometricService: Available biometrics: [BiometricType.fingerprint]
BiometricService: Starting authentication with reason: Authenticate to access Instocks
BiometricService: Authentication result: true
```

**To see logs:**
```bash
# Android
flutter run --verbose

# Or filter logcat
adb logcat | grep "BiometricService"

# iOS
flutter run --verbose

# Or Xcode console
```

### Check SharedPreferences

**Android:**
```bash
adb shell
run-as com.instocks.client
cat shared_prefs/FlutterSharedPreferences.xml
```

**iOS:**
```bash
# In Xcode: Debug → View Memory → UserDefaults
```

**Look for:**
- `app_lock_enabled`: true/false
- `biometric_setup_prompted`: true/false

---

## Production Checklist

Before release, verify:

- [ ] First-time setup flow works (enable & skip)
- [ ] Lock screen appears when enabled
- [ ] Authentication works (fingerprint/Face ID/PIN)
- [ ] Toggle in Settings works (enable/disable)
- [ ] Fallback to PIN/Pattern works
- [ ] Error messages are user-friendly
- [ ] Works on emulator AND real device
- [ ] Works on Android AND iOS
- [ ] "Not Available" state handled gracefully
- [ ] Debug logs removed or disabled in release build
- [ ] Session persists correctly with biometric enabled
- [ ] App doesn't crash when biometric fails
- [ ] App doesn't crash when biometric not available

---

## Code Reference

### Key Files

- `lib/core/auth/biometric_service.dart` - Core biometric logic
- `lib/features/auth/session_controller.dart` - Login + biometric prompt flow
- `lib/features/auth/biometric_setup_screen.dart` - First-time setup UI
- `lib/features/profile/security_settings_screen.dart` - Settings toggle UI
- `lib/app/instocks_client_app.dart` - App lock wrapper + lock screen

### Key Methods

```dart
// Check if device supports auth
BiometricService.canAuthenticate() → bool

// Get available types (fingerprint, face, etc)
BiometricService.getAvailableBiometrics() → List<BiometricType>

// Authenticate user
BiometricService.authenticate(reason: String) → bool

// Enable/disable app lock
BiometricService.setAppLockEnabled(bool enabled)

// Check if already prompted
BiometricService.hasPromptedSetup → bool

// Mark as prompted
BiometricService.markSetupPrompted()
```

---

## Support

If biometric still doesn't work:

1. Check device has security set up (Settings → Security)
2. Check app permissions (Android: BIOMETRIC, iOS: Info.plist)
3. Check logs for errors (see Debugging Tips above)
4. Try on different device/emulator
5. Check local_auth package version: `flutter pub outdated`

**Permissions already configured:**
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

No additional configuration needed! 🎉
