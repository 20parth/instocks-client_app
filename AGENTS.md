# AGENTS.md

Repository guide for coding agents working in `instocks_client_app`.

## Project Snapshot

- Stack: Flutter app written in Dart.
- State management: `provider` with `ChangeNotifier` controllers.
- Networking: `dio`.
- Persistence: `shared_preferences`.
- App purpose: client-only investor app for portfolios, ROI, reports, alerts, and profile data.

## Source Layout

- `lib/main.dart`: app bootstrap and dependency injection.
- `lib/app/`: top-level app widget and navigation entrypoints.
- `lib/core/`: cross-cutting config, network, models, storage, formatting, theme.
- `lib/features/`: feature-specific screens, controllers, and API helpers.
- `lib/shared/widgets/`: reusable UI widgets.
- `test/`: Flutter tests; platform folders contain Flutter hosts.

## Setup Commands

- Install dependencies: `flutter pub get`
- Regenerate platform hosts only if needed: `flutter create --platforms=android,ios .`

## Run Commands

- Run locally with default API URL: `flutter run`
- Run with explicit API URL: `flutter run --dart-define=API_BASE_URL=http://localhost:8000/api`
- Run production-like target: `flutter run --dart-define=API_BASE_URL=https://api-portfolio.instocks.net/api`
- Web run if needed: `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000/api`

## Build Commands

- Format before validation/builds: `dart format lib test`
- Analyze before builds: `flutter analyze`
- Android APK: `flutter build apk --dart-define=API_BASE_URL=<url>`
- Android app bundle: `flutter build appbundle --dart-define=API_BASE_URL=<url>`
- iOS: `flutter build ios --dart-define=API_BASE_URL=<url>`
- Web: `flutter build web --dart-define=API_BASE_URL=<url>`

## Test Commands

- Run all tests: `flutter test`
- Run one test file: `flutter test test/widget_test.dart`
- Run a single named test: `flutter test test/widget_test.dart --plain-name "Counter increments smoke test"`
- Expanded output if debugging CI: `flutter test -r expanded`

## Current Test Caveat

- `test/widget_test.dart` still references `MyApp`, but the app entry widget is `InstocksClientApp`.
- Expect that test to fail until it is updated to match the current bootstrap.

## Lint And Formatting Rules

- The repository includes `package:flutter_lints/flutter.yaml` via `analysis_options.yaml`.
- Explicit lint rules: `prefer_single_quotes`, `use_super_parameters`.
- Use `dart format` for formatting; do not hand-format against the formatter.
- Prefer keeping lines formatter-friendly rather than forcing custom wrapping.

## Import Conventions

- Order imports as: Dart SDK, package imports, then project-relative imports.
- Use package imports for third-party packages such as Flutter, Provider, Dio, Intl.
- This codebase currently uses relative imports for internal files; follow that local convention.
- Keep imports grouped with a blank line between external and internal imports.
- Remove unused imports immediately; `flutter analyze` should stay clean.

## File And Folder Conventions

- Put cross-cutting infrastructure in `lib/core/`.
- Put feature flows in `lib/features/<feature>/`.
- Put reusable presentational widgets in `lib/shared/widgets/`.
- Name screen files with `_screen.dart`.
- Name mutable state holders with `_controller.dart` and API wrappers with `_api.dart`.
- Keep models in `lib/core/models/` unless a model is truly feature-private.

## Naming Conventions

- Types and enums: `PascalCase`.
- Methods, variables, parameters, and fields: `camelCase`.
- Private members: prefix with `_`.
- Constants use `camelCase` unless they are compile-time static values exposed as API.
- Screen widgets end in `Screen`.
- Top-level app widget ends in `App`.

## Type Conventions

- Prefer explicit types for public APIs and stored fields.
- Use `final` for immutable references; this codebase heavily favors `final` fields.
- Use nullable types only when data is genuinely optional.
- At API boundaries, parse dynamic JSON into typed models quickly.
- Follow the existing pattern of factory constructors like `fromJson` and `toJson`.
- Keep `Map<String, dynamic>` at serialization boundaries and convert IDs with `(json['id'] as num?)?.toInt()` style.
- For inconsistent numeric payloads, use helper methods like `_toDouble`.

## State Management Conventions

- `provider` is the current state-management approach; do not introduce another framework casually.
- App-wide dependencies are injected in `lib/main.dart` with `Provider` and `ChangeNotifierProvider`.
- Use `context.read<T>()` for one-off actions and `context.watch<T>()` for reactive rebuilds.
- Keep mutable controller state private and expose read-only getters.
- Call `notifyListeners()` immediately after meaningful state changes.
- Reset submit/loading flags with `try/finally`.

## Widget Conventions

- Prefer `const` constructors and `const` widget instances wherever possible.
- Keep screens focused; extract repeated UI into shared widgets like `AppCard` and `MetricTile`.
- Use `SafeArea`, sensible padding, and scrollable containers for mobile-first layouts.
- Match the existing Material 3 + custom dark theme approach unless the task requires a redesign.
- Preserve current typography and color direction unless intentionally updating the design system.

## Async And Error Handling

- Network and storage operations are async; keep UI responsive while awaiting them.
- In widgets, check `mounted` before showing UI feedback after an await.
- Surface user-facing failures with `SnackBar` or equivalent UI feedback.
- Swallow exceptions only for deliberate best-effort cleanup paths, such as logout.
- Bootstrap flows may clear invalid persisted auth state if backend validation fails.

## Networking Conventions

- Use `ApiClient` for shared Dio setup and auth header injection.
- Keep endpoint-specific logic in `ClientApi` or another focused API wrapper.
- Respect the `API_BASE_URL` compile-time define from `AppConfig`.
- Default base URL is `http://localhost:8000/api`; override it for non-local runs.
- Backend responses are expected to wrap useful payloads under `data`.

## Testing Expectations

- Prefer `flutter_test` widget tests for UI behavior.
- Add or update tests when changing navigation, bootstrapping, or async controller logic.
- For a specific widget test file, use `flutter test path/to/file.dart`.
- For one test name, use `--plain-name` to target the case directly.
- If a change affects app startup, ensure the test harness provides required providers.

## Agent-Specific Guidance

- Before editing, read the surrounding file and follow existing local patterns.
- Make minimal, targeted changes; avoid broad refactors unless the task asks for them.
- Do not introduce new dependencies without clear need.
- Keep compile-time configuration in `AppConfig` or another central config point.
- Update docs or tests when behavior changes materially.

## Repository Rule Files

- No `.cursorrules`, `.cursor/rules/`, or `.github/copilot-instructions.md` files were found.
- If any are added later, treat them as higher-priority instructions and merge them into this guide.

## Practical Defaults For Agents

- First pass after code changes: `dart format lib test`
- Validation pass after code changes: `flutter analyze`
- Test pass after behavior changes: `flutter test`
- Single-test workflow: `flutter test <file> --plain-name "<test name>"`
- Integration run: `flutter run --dart-define=API_BASE_URL=<url>`

## Known Architecture Notes

- The app is client-only; non-client roles should be rejected during login.
- Auth state is persisted with `SharedPreferences`.
- Session bootstrap rehydrates cached auth state, then validates it with `/auth/me`.
- Navigation currently uses a `NavigationBar` with an `IndexedStack` shell.
- The codebase favors straightforward imperative Flutter code over abstraction-heavy patterns.
