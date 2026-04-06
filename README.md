# Instocks Client

Client-only Flutter mobile app for Instocks investors.

## Scope

- Client login only
- Portfolio dashboard
- Portfolio list and detail view
- ROI and fund visibility
- Reports by portfolio/date
- Notifications center and preferences
- Profile management

## API Base URL

Pass the API base URL at build/run time:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
```

Example production value:

```bash
flutter run --dart-define=API_BASE_URL=https://api-portfolio.instocks.net/api
```

## Native Platforms

Flutter SDK is not installed in this environment, so the Dart app structure is scaffolded here manually.

After installing Flutter locally, generate the native host projects from this folder:

```bash
flutter create --platforms=android,ios .
flutter pub get
```

That will materialize the Android and iOS project files around the app code already present in `lib/`.

## Notificationsx

- In-app notification center is wired to backend client notification APIs.
- Local notifications can be displayed from app-fetched alerts while the app is active.
- Full background push on Android/iOS still requires FCM/APNS setup.
