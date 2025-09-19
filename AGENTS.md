# Repository Guidelines

## Project Structure & Module Organization
FitCheck is a Flutter app kept under `lib/`, split into `core/` (config, routing, shared services), `design_system/` (tokens and glass UI primitives), domain flows in `features/`, and presentation layers across `screens/`, `widgets/`, `providers/`, `services/`, `models/`, and `utils/`. Shared assets stay in `assets/` with shader programs in `shaders/`; generated artifacts belong under `build/`. Tests mirror the source tree inside `test/`, and process documentation lives in `docs/`, including delivery scripts and progress logs.

## Build, Test, and Development Commands
- `flutter pub get` installs or syncs package dependencies.
- `flutter analyze` runs static analysis; keep the output clean.
- `dart format lib test` (or `flutter format`) applies the enforced style guide.
- `flutter test` executes unit and widget suites; add `--coverage` when publishing metrics.
- `flutter run -d <device>` launches the app locally; pair with `--profile` for shader tuning.

## Coding Style & Naming Conventions
Indent with two spaces and prefer trailing commas on multiline widget trees to stabilise diffs. Files remain in `snake_case.dart`; types use `PascalCase`, while providers and services carry descriptive suffixes such as `AuthProvider` or `GeminiService`. Use `const` constructors when feasible, avoid raw `print`, and surface telemetry through helpers in `lib/core/services/`.

## Testing Guidelines
Extend coverage in `test/`, mirroring source paths (`test/navigation_provider_test.dart` pairs with `lib/providers/navigation_provider.dart`). Favour focused unit tests for business logic and widget or smoke tests for navigation flows (see `test/main_screen_smoke_test.dart`). Run `flutter test` before each push, stabilise asynchronous dependencies with fakes, and document notable gaps in the progress log.

## Commit & Pull Request Guidelines
Follow Conventional Commits (`feat:`, `fix:`, `chore:`) with imperative subjects scoped to a single change. Summarise behaviour in PR descriptions, attach screenshots or recordings for UI updates, and note any Firebase or asset impacts. Confirm `flutter analyze` and `flutter test` outputs, and update collateral such as `FIREBASE_SETUP.md`, `pubspec.yaml`, or `create_assets.py` whenever configuration shifts.

## Agent Workflow Notes
Record milestones and blockers in `PROJECT_MANAGEMENT.md` and `docs/progress_log.md` so the next contributor inherits context. When scripts outline active tasks, reference their status explicitly and refresh checklists rather than duplicating them. Call out security or data-handling concerns early to keep the Gemini try-on pipeline reviewable.
