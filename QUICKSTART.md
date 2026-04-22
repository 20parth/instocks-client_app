# Quick Start Guide

## Running the App

### Prerequisites
- Flutter SDK installed
- Backend server running (Laravel)
- Android/iOS device or emulator

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Start Your Backend Server

**IMPORTANT:** The backend must accept external connections:

```bash
# Navigate to your backend directory
cd /path/to/instocks-backend

# Run with host 0.0.0.0 to accept connections from devices
php artisan serve --host=0.0.0.0 --port=8000
```

### Step 3: Configure API URL

The `.env` file is already configured with your local IP: `192.168.0.153`

**For Emulator:**
```bash
# Edit .env and uncomment:
API_BASE_URL=http://localhost:8000/api
```

**For Real Device (Current Default):**
```bash
# .env is already set to:
API_BASE_URL=http://192.168.0.153:8000/api
```

**For Production:**
```bash
# Edit .env and uncomment:
API_BASE_URL=https://api-portfolio.instocks.net/api
```

### Step 4: Run the App

**On Emulator:**
```bash
flutter run
```

**On Real Device (USB Debugging Enabled):**
```bash
flutter run
```

**On Specific Device:**
```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Step 5: Test Error Handling

The app now has **global error handling** with user-friendly toast messages:

1. Try logging in with wrong credentials → Should show: "Invalid credentials. Please try again."
2. Stop backend server and try to login → Should show: "Unable to connect to server. Please check your internet connection."
3. All errors are now user-friendly, not technical DioException messages!

---

## Features Implemented

### ✅ Biometric Authentication
- Fingerprint/Face ID/Touch ID support
- Premium UI similar to PhonePay
- First-time setup prompt on login
- App lock functionality

### ✅ Modern UI/UX
- Material 3 design system
- Dark theme: Pure black (#000000) with cyan (#00D4FF) accents
- Light theme: iOS-style (#F2F2F7) with blue (#0A84FF) accents
- Glassmorphism effects
- Smooth animations (600-1200ms duration)

### ✅ Redesigned Screens
- **Login Screen:** Animated gradient background, glass-morphic form, particle effects
- **Reports Screen:** Tabbed interface (Statement, ROI, Funds), date filters, portfolio selector
- **Security Settings:** Premium UI with biometric toggle

### ✅ Error Handling
- Global error interceptor in ApiClient
- User-friendly toast messages
- HTTP status code mapping:
  - 401 → "Invalid credentials"
  - 404 → "Resource not found"
  - 500 → "Server error"
  - Connection errors → "No internet connection"

### ✅ All Client APIs
- Portfolio management
- Transaction history
- ROI reports
- Funds tracking
- Notifications
- Profile management
- Device token registration (push notifications)

---

## Troubleshooting

### "Unable to connect to server" on Real Device
1. Make sure backend is running with `--host=0.0.0.0`
2. Check that your device is on the same WiFi network as your computer
3. Verify the IP in `.env` matches your computer's IP:
   ```bash
   # Mac
   ipconfig getifaddr en0
   
   # Windows
   ipconfig
   ```

### Biometric Not Working
- **Android:** Check `android/app/src/main/AndroidManifest.xml` has biometric permission
- **iOS:** Check `ios/Runner/Info.plist` has Face ID usage description
- Ensure device has biometric hardware and it's set up

### App Shows Technical Errors
- Make sure you ran `flutter pub get` after adding fluttertoast
- Check that `lib/core/utils/error_handler.dart` exists
- Verify `ApiClient` has the error interceptor

---

## Build Commands

### Android APK
```bash
flutter build apk --dart-define=API_BASE_URL=http://192.168.0.153:8000/api
```

### Android App Bundle
```bash
flutter build appbundle --dart-define=API_BASE_URL=http://192.168.0.153:8000/api
```

### iOS
```bash
flutter build ios --dart-define=API_BASE_URL=http://192.168.0.153:8000/api
```

### Production Build
```bash
flutter build apk --dart-define=API_BASE_URL=https://api-portfolio.instocks.net/api
```

---

## Testing

```bash
# Run all tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format lib test
```

---

## Project Structure

```
lib/
├── app/                    # App entry point and shell
├── core/                   # Cross-cutting concerns
│   ├── auth/              # Biometric service
│   ├── config/            # App configuration
│   ├── models/            # Data models
│   ├── network/           # API client
│   ├── storage/           # Persistence
│   ├── theme/             # Theme system
│   └── utils/             # Error handler, formatters
├── features/              # Feature modules
│   ├── auth/              # Login, biometric setup
│   ├── home/              # Dashboard, shell
│   ├── portfolio/         # Portfolio management
│   ├── reports/           # Statement, ROI, funds
│   ├── notifications/     # Notifications
│   └── profile/           # Profile, security settings
└── shared/                # Reusable widgets
    └── widgets/           # Glass cards, metric tiles
```

---

## Support

For issues or questions:
1. Check AGENTS.md for detailed project documentation
2. Check NETWORK_SETUP.md for network configuration help
3. Check BIOMETRIC_IMPLEMENTATION.md for biometric setup details
