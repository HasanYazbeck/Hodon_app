# AGENTS.md — hodon_app

## Project Overview
`hodon_app` is a Flutter application (Dart SDK `^3.11.4`, Flutter with Material Design). Currently at the scaffold stage: a single counter demo in `lib/main.dart`.

## Key Files
| Path | Purpose |
|------|---------|
| `lib/main.dart` | App entry point; `MyApp` (root widget) → `MyHomePage` (stateful counter) |
| `pubspec.yaml` | Dependencies & Flutter config |
| `analysis_options.yaml` | Lint rules (uses `flutter_lints ^6.0.0`) |
| `test/widget_test.dart` | Default widget test |

## Architecture
- **Single-file structure** — all UI lives in `lib/main.dart`. As the app grows, follow Flutter conventions: `lib/screens/`, `lib/widgets/`, `lib/models/`, `lib/services/`.
- State management: plain `setState` today. Introduce a solution (e.g., Riverpod, Bloc) when adding features.
- Theme: seeded `ColorScheme` via `ThemeData(colorScheme: ColorScheme.fromSeed(...))` in `MyApp.build`.

## Developer Workflows

```powershell
# Get dependencies
flutter pub get

# Run on a connected device / emulator
flutter run

# Hot reload (while running): press r in terminal, or save in IDE
# Hot restart: press R in terminal

# Run tests
flutter test

# Build release APK
flutter build apk --release

# Analyze code
flutter analyze
```

## Conventions
- Widgets use `const` constructors wherever possible (`const MyApp({super.key})`).
- Private state classes use the `_ClassName` prefix (e.g., `_MyHomePageState`).
- No external HTTP clients, routing packages, or platform channels are added yet — add them via `pubspec.yaml` and run `flutter pub get`.

## Adding Dependencies
Edit `pubspec.yaml` under `dependencies:`, then run `flutter pub get`. Example:
```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0
```

## Platform Targets
The project scaffolds all six platforms: Android, iOS, Web, Linux, macOS, Windows. Platform-specific code lives in the corresponding top-level directories.

