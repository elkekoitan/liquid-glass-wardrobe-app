# FitCheck Project Management Playbook















## Project Overview







- FitCheck is an AI-driven virtual try-on app built with Flutter 3.8+, Firebase, and Gemini AI.







- Runtime source lives under `lib/` with feature slices, shared providers, and the liquid glass design system; tests mirror the structure under `test/`.







- Assets, shaders, and environment templates live in `assets/`, `shaders/`, and `.env.example`, while deployment and docs live in `.github/` and `docs/`.







- Coolify is the primary deployment target with AWS/GCP as contingency; CI/CD relies on GitHub Actions.















## Current Snapshot (2025-09-19)







- Completed: authentication flows unified under `AuthProvider`, personalization toggles respected across login, OTP, and home; repository contributor guide (`AGENTS.md`) refreshed; secondary flows and shared components now route via `NavigationProvider` with analytics hooks.







- In progress: shared personalized scaffold deployed to start, canvas, and main screens; navigation now centralized via `NavigationProvider` with auth/profile/personalization guards; capsule carousel replaced with reusable picker.







- Risks: Gemini API key management still manual; shader performance unverified on low-end hardware; Firebase config awaiting production credentials.







- Next checkpoint: close Scripts 2.2A–2.2B, then kick off Script 2.3 (Gemini try-on foundation).















## Roadmap Phases







| Phase | Focus | Status | Exit Criteria |







| --- | --- | --- | --- |







| 1 | Foundation & Core Systems | Done | Design system, auth stack, base routing established |







| 2 | Core Application Features | Active | Main experience, AI module, navigation polished |







| 3 | Advanced Features | Pending | Wardrobe, shopping, social loops operational |







| 4 | Backend & Integration | Pending | Remote services wired, performance baselines met |







| 5 | Quality Assurance | Pending | Test coverage, analytics, accessibility sign-off |







| 6 | Deployment & Polish | Pending | Release automation, store assets, beta feedback |















## Execution Sequence







Work through the scripts sequentially; do not skip ahead without completing deliverables and validations.







1. Script 2.2A – Main Screens Layout Harmonization **(Complete)**







2. Script 2.2B – Navigation & Context Orchestration **(In Progress)**







3. Script 2.3 – Virtual Try-On Foundation







4. Script 3.1 – Wardrobe & Capsule Experience Baseline







5. Script 4.0 – Backend & Data Contracts







6. Script 5.0 – Quality, Analytics, & Accessibility







7. Script 6.0 – Deployment & Launch Readiness















## Task Scripts















### Script 2.2A – Main Screens Layout Harmonization *(Complete)*







**Goal**: Align the start, home, and canvas flows with the modern liquid-glass layout and personalization defaults.  







**Status Update**: Shared `PersonalizedScaffold`, `MainSectionHeader`, `TryOnActionRail`, and `CapsuleQuickPicker` integrated into start, canvas, main, and capsule screens; smoke test covers personalization transitions.  















### Script 2.2B – Navigation & Context Orchestration *(In Progress)*



**Goal**: Rationalize navigation flows and ensure state hand-off between onboarding, auth, and main surfaces.  



**Status Update**: Introduced `NavigationProvider` with auth/profile/personalization guards; MaterialApp now routes through the guarded navigator key; onboarding, auth, and main surfaces consume coordinated navigation helpers; secondary flows (start, canvas, photo upload, wardrobe, OTP) now pop via the provider; analytics/deep-link hooks fire on every route resolution.



**Remaining**:



1. Document navigation helper + analytics patterns in `docs/engineering_delivery_manual.md`.



2. Add regression coverage for deep-link entry once Script 2.3 scaffolding lands.



### Script 2.3 – Virtual Try-On Foundation *(Pending)*







**Goal**: Stand up the Gemini AI pipeline and canvas interaction loop.  







1. Expand `lib/services/gemini_service.dart` with async methods for pose generation, garment blending, and error surfaces; define request/response models in `lib/models/`.  







2. Add configuration keys to `.env.example` (for example `GEMINI_VTO_MODEL`, `GEMINI_TIMEOUT`) and ensure `FitCheckProvider.initializeGeminiService` reads them.  







3. Create a session orchestrator (`lib/providers/try_on_session_provider.dart`) to manage upload state, progress indicators, and personalization fallbacks.  







4. Integrate the orchestrator into `lib/screens/canvas_screen.dart` and `lib/screens/photo_upload/modern_photo_upload_screen.dart`, surfacing intermediate states (queued, processing, failed).  







5. Write service tests with mocks under `test/services/gemini_service_test.dart` plus widget tests covering canvas state transitions.  







6. Document API error handling in `docs/engineering_delivery_manual.md` and update this playbook with any new risks.















**Deliverables**: Gemini service API, session provider, stateful canvas, updated env template, automated tests.















### Script 3.1 – Wardrobe & Capsule Experience Baseline *(Pending)*







**Goal**: Deliver a minimal but functional wardrobe and capsule management loop.  







1. Model wardrobe collections by extending `lib/models/wardrobe_item.dart` and `lib/models/capsule_model.dart` with tags, availability, and personalization metadata.  







2. Build repository stubs in `lib/services/capsule_service.dart` and `lib/services/preferences_service.dart` that can operate offline with mock data.  







3. Enhance `lib/widgets/wardrobe_panel.dart` and `lib/widgets/outfit_stack.dart` to render the new metadata and respond to personalization toggles.  







4. Create capsule browsing flows in `lib/screens/capsules/capsule_gallery_screen.dart`, ensuring state sync with `CapsuleProvider`.  







5. Cover domain logic with unit tests (`test/models/capsule_model_test.dart`, `test/services/capsule_service_test.dart`) and add a widget test for the wardrobe panel.  







6. Update documentation here plus add usage notes to `README.md` if UI entry points change.















**Deliverables**: Updated models, offline-ready services, enhanced widgets, tests, doc updates.















### Script 4.0 – Backend & Data Contracts *(Pending)*







**Goal**: Connect the app to Firebase and remote services with reliable error handling.  







1. Finalize Firebase project configuration using `FIREBASE_SETUP.md`; add credentials placeholders to `.env.example`.  







2. Implement real network calls in `lib/services/auth_service.dart`, `lib/services/capsule_service.dart`, and `lib/providers/personalization_provider.dart` with retry and backoff policies.  







3. Define DTOs and mappers under `lib/models/` to isolate Firestore schemas from UI models.  







4. Instrument logging via `lib/services/analytics_service.dart`, ensuring failures and performance metrics are reported.  







5. Add integration tests (for example `test/integration/auth_flow_test.dart`) using Firebase emulators or mocks; ensure CI can run them headlessly.  







6. Record data contract decisions in `docs/engineering_delivery_manual.md` and update the risk register here.















### Script 5.0 – Quality, Analytics, & Accessibility *(Pending)*







**Goal**: Raise quality gates ahead of advanced feature work.  







1. Expand analyzer rules in `analysis_options.yaml` (consider enabling `prefer_single_quotes`, `avoid_redundant_argument_values`) and auto-fix the codebase.  







2. Establish golden test baselines for key widgets (`glass_button`, `glass_container`, `modern_navigation`) in `test/golden/`.  







3. Instrument analytics events via `AnalyticsService` for onboarding, canvas success/fail, and wardrobe interactions; validate payloads match the spec.  







4. Conduct an accessibility audit on start, auth, and main screens; log issues and remedies in `docs/accessibility_report.md`.  







5. Ensure coverage reporting is wired (`flutter test --coverage`) and surface the badge in `README.md`.  







6. Update this playbook with accessibility findings and coverage metrics.















**Deliverables**: Updated lint rules, golden tests, analytics events, accessibility report, coverage data.















### Script 6.0 – Deployment & Launch Readiness *(Pending)*







**Goal**: Automate release flows and prepare store collateral.  







1. Implement GitHub Actions workflows under `.github/workflows/` for analyze -> test -> build across platforms; integrate artifact uploads for Android/iOS.  







2. Configure Coolify deployment scripts and monitor hooks; document rollback procedure in `docs/CI_CD_SETUP.md`.  







3. Prepare App Store and Play Store assets (screenshots, copy) and store them under `docs/store/`; sync marketing copy with the product team.  







4. Set up beta distribution via TestFlight or Firebase App Distribution; include feedback template links in this file.  







5. Run end-to-end smoke tests on physical devices, capturing performance traces; attach summarized metrics here.  







6. Create a launch readiness checklist and store it in `docs/launch_checklist.md`, referencing it from the roadmap.















**Deliverables**: CI/CD workflows, deployment playbook, store assets, beta distribution plan, launch checklist.















## Quality Gates







- After every script run `flutter analyze`, `dart format lib test`, and `flutter test`; block progression on failures.







- Profile shader-heavy flows on a high-end and a low-end device; record FPS, memory, and jank metrics in `docs/performance_logs/`.







- Use Conventional Commits (`feat:`, `fix:`, `chore`) and include script references in commit bodies for traceability.







- Keep `PROJECT_MANAGEMENT.md` and `AGENTS.md` updated with outcomes, risks, and follow-up actions.















## Reporting Cadence







- Log daily progress summaries in `docs/daily_updates/` (create the folder if needed) using `YYYY-MM-DD.md`.







- Update the "Current Snapshot" and relevant script sections immediately after closing a task; include links to PRs and test runs.







- Surface blockers in Slack #fitcheck-delivery and mirror them in this document under Risks.















## Reference Artifacts







- `AGENTS.md` – contributor playbook.







- `FIREBASE_SETUP.md` – environment bootstrap details.







- `docs/engineering_delivery_manual.md` – deep architecture guidance.







- `create_assets.py` – automation for asset ingestion.







- `.env.example` – source of truth for configuration keys.















---















**Last Updated**: 2025-09-19T13:20:00Z  







**Current Phase**: Phase 2 – Core Application Features  







**Next Milestone**: Complete Script 2.2B (navigation alignment) and start Script 2.3 (Gemini try-on foundation).







