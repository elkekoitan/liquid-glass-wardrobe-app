# Repository Guidelines

## Project Structure & Module Organization
FitCheck is a Flutter workspace anchored in `lib/`. Shared configuration and services live in `lib/core/`, state providers under `lib/providers/`, and UI flows within `lib/screens/` and `lib/widgets/`. Gemini integrations sit in `lib/services/gemini_service.dart` with supporting models in `lib/models/`. Tests mirror this layout in `test/`. Keep documents in `docs/`, static assets under `assets/`, shaders in `shaders/`, and environment samples in `.env.example`.

## Build, Test, and Development Commands
Run `flutter pub get` after dependency changes. Use `flutter analyze` to enforce lint rules before every commit. Format Dart sources with `dart format lib test`. Execute `flutter test` (append `--coverage` when capturing metrics). Launch locally with `flutter run -d windows` or `flutter run -d chrome` to validate flows end-to-end.

## Coding Style & Naming Conventions
Indent with two spaces. Use trailing commas in multiline widget trees to stabilize diffs. Follow `snake_case.dart` for files, `PascalCase` for types, and `camelCase` for members. Providers and services carry descriptive suffixes (e.g., `NavigationProvider`, `GeminiService`). Prefer `const` constructors where possible and route diagnostics through helpers in `lib/core/services/` instead of `print`.

## Testing Guidelines
Add tests under `test/` mirroring source paths (e.g., `test/services/gemini_service_test.dart`). Widget tests should gate async flows with fakes or `pumpAndSettle`. Run the full suite with `flutter test` before pushing and document notable gaps or flakiness in `docs/progress_log.md`. Consult `docs/deep_link_regression_plan.md` when altering navigation or deep links.

## Commit & Pull Request Guidelines
Adopt Conventional Commits such as `feat: add outfit carousel`. Scope each commit to one behavioral change. PRs must summarize manual verification, link relevant scripts or issues, and include screenshots for UI updates. Confirm `flutter analyze` and `flutter test` pass, and update `.env.example`, `PROJECT_MANAGEMENT.md`, and `AGENTS.md` when workflows or configuration shift.

## Security & Configuration Tips
Store secrets outside the repo; reference `.env.example` when introducing new keys. Document environment changes in `docs/engineering_delivery_manual.md` and note progress in `docs/progress_log.md` so the next agent can continue Script 2.3 without rework.
