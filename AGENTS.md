# Repository Guidelines

## Project Structure & Module Organization
FitCheck is a Flutter app. Runtime code lives in `lib/` with focused submodules: `core/` for config, router, and shared services; `design_system/` for tokens and reusable glass components; `features/` for domain flows such as auth and home; `screens/`, `widgets/`, `providers/`, `services/`, and `models/` for layered UI, state, and integration code. Assets and shaders reside under `assets/` and `shaders/`, while tests live in `test/` mirroring the source folders.

## Build, Test, and Development Commands
- `flutter pub get` installs or refreshes dependencies.
- `flutter analyze` enforces static analysis; keep the output clean.
- `dart format lib test` (or `flutter format`) applies standard formatting.
- `flutter test` executes unit and widget suites; add `--coverage` before publishing metrics.
- `flutter run -d <device>` launches the app; use `--profile` when validating shader performance.

## Coding Style & Naming Conventions
The repo extends `flutter_lints` via `analysis_options.yaml`; stick to two-space indentation, trailing commas on multi-line widgets, `const` constructors where practical, and avoid unused imports. Filenames use `snake_case.dart`; classes, enums, and extensions use `PascalCase`, while providers and services keep explicit suffixes (for example `AuthProvider`, `GeminiService`). Do not print secrets—log through the facilities in `lib/core/services/`.

## Testing Guidelines
Add or update tests in `test/`, matching the source path (`test/auth_provider_test.dart` mirrors `lib/providers/auth_provider.dart`). Cover new logic with unit tests and pair UI changes with widget or golden tests for glass components (see `docs/engineering_delivery_manual.md` scenarios). Keep existing tests green locally before pushing; investigate flakes immediately and supply fixtures or fakes when networking is involved.

## Commit & Pull Request Guidelines
Follow Conventional Commits as shown in history (`feat:`, `fix:`, `chore:`). Keep subjects imperative and scoped to a single change. Pull requests must include a concise summary, local test evidence (`flutter test`), linked issue or task ID, and screenshots or recordings for UI updates. Document configuration adjustments (.env, Firebase, assets) and update `FIREBASE_SETUP.md` or `create_assets.py` instructions when behavior shifts.

## Security & Configuration Tips
Never commit real secrets; copy `.env.example` when onboarding and store keys securely. Follow `FIREBASE_SETUP.md` for authentication, storage, and Gemini AI setup. When introducing assets, respect the size budgets defined in `docs/engineering_delivery_manual.md`, register them in `pubspec.yaml`, and ensure accessibility variants are supplied where applicable.
