# FitCheck Project Management Playbook

## Project Overview

- FitCheck is an AI-driven virtual try-on app built with Flutter 3.8+, Firebase, and Gemini AI.

- Runtime source lives under `lib/` with feature slices, shared providers, and the liquid glass design system; tests mirror the structure under `test/`.

- Assets, shaders, and environment templates live in `assets/`, `shaders/`, and `.env.example`, while deployment and docs live in `.github/` and `docs/`.

- Coolify is the primary deployment target with AWS/GCP as contingency; CI/CD relies on GitHub Actions.

## Current Snapshot (2025-09-19)

- Completed: Scripts 2.2A-2.2B delivered; NavigationProvider guards and analytics instrumentation shipped; Trend Pulse routing/provider wiring and home spotlight landed; StartScreen now rides TryOnSessionProvider with OTP viewport fixes.
- In progress: Script 3.1 - wardrobe and capsule metadata now lands across models, services, and UI with tests; Script 2.3 documentation and onboarding/start adoption still queued for close-out.
- Risks: Gemini key rotation remains manual; TryOnSessionProvider adoption incomplete across entry screens; wardrobe metadata sync relies on manual seed updates; shader performance on low-end hardware untested; Trend Pulse feed depends on asset hosting stability.
- Next checkpoint: Finish TryOnSessionProvider onboarding migration with coverage, then smoke the new wardrobe/capsule chips before promoting Script 3.1 follow-on flows.


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

1. Script 2.2A - Main Screens Layout Harmonization **(Complete)**

2. Script 2.2B - Navigation & Context Orchestration **(Complete)**

3. Script 2.3 - Virtual Try-On Foundation **(In Progress)**

4. Script 3.1 - Wardrobe & Capsule Experience Baseline

5. Script 4.0 - Backend & Data Contracts

6. Script 5.0 - Quality, Analytics, & Accessibility

7. Script 6.0 - Deployment & Launch Readiness

## Task Scripts

### Script 2.2A - Main Screens Layout Harmonization *(Complete)*

**Goal**: Align the start, home, and canvas flows with the modern liquid-glass layout and personalization defaults.  

**Status Update**: Shared `PersonalizedScaffold`, `MainSectionHeader`, `TryOnActionRail`, and `CapsuleQuickPicker` integrated into start, canvas, main, and capsule screens; smoke test covers personalization transitions.  

### Script 2.2B - Navigation & Context Orchestration *(Complete)*

**Goal**: Rationalize navigation flows and ensure state hand-off between onboarding, auth, and main surfaces.  
**Status Update**: NavigationProvider now owns auth/profile/personalization guards, analytics logging, and deep-link instrumentation; MaterialApp, onboarding, auth, and main surfaces route through shared helpers; smoke and provider tests updated.  
**Follow-up**:
1. Execute the deep-link regression plan after Script 2.3 stabilizes the Gemini session wiring.


### Script 2.3 - Virtual Try-On Foundation *(In Progress)*

**Goal**: Stand up the Gemini AI pipeline and canvas interaction loop.  
**Status Update**: GeminiService configuration, typed request/response models, and TryOnSessionProvider are in place; canvas and modern photo upload screens surface session progress with deterministic service tests in `test/services/gemini_service_test.dart`. Trend Pulse provider now ships in the global tree with a home screen spotlight for daily content validation.  
**Remaining**:
1. Archive emulator QA evidence (screenshots/notes) for Trend Pulse spotlight + OTP flow after the layout fix (Android API 34 run completed).

**Deliverables**: Gemini service API, session provider, stateful canvas, updated env template, automated tests.


### Script 3.1 - Wardrobe & Capsule Experience Baseline *(In Progress)*

**Goal**: Deliver a minimal but functional wardrobe and capsule management loop.  

1. Model wardrobe collections by extending `lib/models/wardrobe_item.dart` and `lib/models/capsule_model.dart` with tags, availability, and personalization metadata.  

2. Build repository stubs in `lib/services/capsule_service.dart` and `lib/services/preferences_service.dart` that can operate offline with mock data.  

3. Enhance `lib/widgets/wardrobe_panel.dart` and `lib/widgets/outfit_stack.dart` to render the new metadata and respond to personalization toggles.  

4. Create capsule browsing flows in `lib/screens/capsules/capsule_gallery_screen.dart`, ensuring state sync with `CapsuleProvider`.  

5. Cover domain logic with unit tests (`test/models/capsule_model_test.dart`, `test/services/capsule_service_test.dart`) and add a widget test for the wardrobe panel.  

6. Update documentation here plus add usage notes to `README.md` if UI entry points change.

**Deliverables**: Updated models, offline-ready services, enhanced widgets, tests, doc updates.

### Script 4.0 - Backend & Data Contracts *(Pending)*

**Goal**: Connect the app to Firebase and remote services with reliable error handling.  

1. Finalize Firebase project configuration using `FIREBASE_SETUP.md`; add credentials placeholders to `.env.example`.  

2. Implement real network calls in `lib/services/auth_service.dart`, `lib/services/capsule_service.dart`, and `lib/providers/personalization_provider.dart` with retry and backoff policies.  

3. Define DTOs and mappers under `lib/models/` to isolate Firestore schemas from UI models.  

4. Instrument logging via `lib/services/analytics_service.dart`, ensuring failures and performance metrics are reported.  

5. Add integration tests (for example `test/integration/auth_flow_test.dart`) using Firebase emulators or mocks; ensure CI can run them headlessly.  

6. Record data contract decisions in `docs/engineering_delivery_manual.md` and update the risk register here.

### Script 5.0 - Quality, Analytics, & Accessibility *(Pending)*

**Goal**: Raise quality gates ahead of advanced feature work.  

1. Expand analyzer rules in `analysis_options.yaml` (consider enabling `prefer_single_quotes`, `avoid_redundant_argument_values`) and auto-fix the codebase.  

2. Establish golden test baselines for key widgets (`glass_button`, `glass_container`, `modern_navigation`) in `test/golden/`.  

3. Instrument analytics events via `AnalyticsService` for onboarding, canvas success/fail, and wardrobe interactions; validate payloads match the spec.  

4. Conduct an accessibility audit on start, auth, and main screens; log issues and remedies in `docs/accessibility_report.md`.  

5. Ensure coverage reporting is wired (`flutter test --coverage`) and surface the badge in `README.md`.  

6. Update this playbook with accessibility findings and coverage metrics.

**Deliverables**: Updated lint rules, golden tests, analytics events, accessibility report, coverage data.

### Script 6.0 - Deployment & Launch Readiness *(Pending)*

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

- `AGENTS.md` - contributor playbook.

- `FIREBASE_SETUP.md` - environment bootstrap details.

- `docs/engineering_delivery_manual.md` - deep architecture guidance.

- `create_assets.py` - automation for asset ingestion.

- `.env.example` - source of truth for configuration keys.

---

**Last Updated**: 2025-09-19T18:30:00Z  

**Current Phase**: Phase 2 - Core Application Features  

**Next Milestone**: Close Script 2.3 onboarding migration and validate the new wardrobe/capsule metadata set to unlock follow-on Script 3.1 flows. 




