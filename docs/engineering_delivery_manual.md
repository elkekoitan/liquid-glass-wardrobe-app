# Engineering Delivery Manual
Version: 2025-09-17
Owners: Engineering Lead, Motion & Proto Engineer, Design Ops

## 1. Architecture Principles
- Clean Architecture with feature modules (`otp`, `capsules`, `settings`) and shared services.
- State management via Provider/StateNotifier; dependency injection via `get_it` or Riverpod providers.
- Theming driven by exported design tokens (`shared/theming/tokens.dart`).
- Analytics service wrapper capturing capsule/accessibility context.

### 1.1 Directory Layout
```
lib/
  core/
    config/
    network/
    analytics/
  features/
    otp/
      presentation/ (screens, widgets, providers)
      domain/ (entities, usecases)
      data/ (repositories, datasources)
    capsules/
    settings/
  shared/
    widgets/
    theming/
    utils/
shaders/
assets/
```

### 1.2 Testing Strategy
- Unit tests for use cases (OTP submit, capsule scheduling).
- Widget tests for OTP states (default, error, expired, reduced motion).
- Golden tests for glass components across themes.
- Integration tests with fake backend verifying `otp_*` events.
- CI: `flutter analyze`, `flutter format`, `flutter test` prior to merge; profile build for performance.

## 2. Design ? Engineering Handoff
- Inputs: Annotated Figma frames, motion prototypes (Lottie/MP4), token JSON, copy sheet, analytics plan.
- Handoff ticket includes scope summary, due date, links; design pre-review ensures completeness.
- Weekly build sync demos progress and flags deviations; design QA executed with feature flag before release.
- Asset repo structure:
```
assets/
  textures/{theme}/
  lottie/{flow}/
  audio/{type}/
```
- Manifest JSON tracks files, sizes, accessibility variants.

## 3. Shader & Visual Effects
### 3.1 Shader Stack
- Base blur via BackdropFilter (`sigmaX/Y` 12-24 depending on elevation).
- Custom `refraction.frag` for liquid distortion (`distortionStrength` 0.05 default).
- `highlight_sweep.frag` for hero light pass (disable when reduced motion true).
- Cache `FragmentProgram` instances on app init; fallback to static textures on constrained devices.

### 3.2 Parameters
| Param | Range | Default | Notes |
| --- | --- | --- | --- |
| `blurSigma` | 8-24 | 18 | Align with elevation level |
| `distortionStrength` | 0.02-0.08 | 0.05 | Increase cautiously to avoid artifacts |
| `noiseAmount` | 0-0.15 | 0.08 | Adds analog imperfection |
| `highlightSpeed` | 0.5-1.5 | 1.0 | Adjust per capsule mood |
| `colorTint` | [0-1] RGBA | theme-driven | Capsule palette source |

### 3.3 Performance Guardrails
- Restrict to ?3 BackdropFilters per view stack.
- Wrap expensive widgets with `RepaintBoundary`.
- Profile on iPhone 14 Pro, Pixel 8, iPhone 12, Pixel 6, Galaxy S21, Moto G Power.
- Provide developer toggle to disable shaders (settings > developer) for troubleshooting.

## 4. Performance Benchmark Plan
- Metrics: FPS ?60 (min 55), frame build <16ms (max 24ms), jank <2/min, runtime memory <250MB, CPU <40%.
- Scenarios: OTP default, OTP reduced motion, capsule switcher, settings toggles, slow network asset fetch.
- Tooling: Flutter DevTools, Perfetto, Xcode Instruments; capture 60s traces in profile builds.
- Reporting: Sprint summary with trend charts; high-severity issues filed immediately, include before/after metrics.
- Future: Automate via Firebase Test Lab, integrate synthetic asset latency monitoring.

## 5. Prototype & QA Pipeline
- Prototype types: Figma (flow), Principle/ProtoPie (motion/haptics), Flutter dev build (performance).
- Testing workflow: Define objectives ? script tasks ? recruit (?5) ? conduct remote/in-person sessions ? synthesize findings.
- Evaluation criteria: Task completion/time, emotional response, motion comfort, accessibility compliance, visual fidelity.
- Data handling: Store recordings securely, purge after 90 days without consent.

## 6. Asset Production & Delivery
- Use `asset_manifest_template.json` per capsule to track backgrounds, overlays, illustrations, motion, audio, accessibility variants.
- File limits: Background <512KB, Lottie <300KB, audio normalized to -16 LUFS.
- QA flags: Visual (resolution, naming), motion (fps), audio (levels), accessibility variant availability.

## 7. Analytics Implementation
- Event wrapper ensures consistent payload: `AnalyticsService.logEvent(name, params)`.
- Required params: `capsule_id`, `theme_variant`, `accessibility_flags`, `device_type`, `app_version`.
- Debug toggle prints events in dev builds; gating ensures no PII captured.
- Dashboards (Looker) pull from Segment; QA harness validates events in staging before release.

## 8. Security & Resilience
- OTP network layer via `dio` with retries (max 3) and exponential backoff.
- Ensure transport encryption, minimal logging (mask OTP digits).
- Feature flags for capsules allow instant rollback; fallback theme and static assets ready.

## 9. Collaboration Cadence
- Engineering ? Design sync Tuesdays 11:00 (see `engineering_sync_notes`).
- Performance review in Friday Gallery Walk when new assets shipped.
- Incident response playbook (see Operations doc) defines on-call responsibilities.

## 10. Future Enhancements
- Explore GPU compute shaders for particle effects and dynamic caustics.
- Investigate Material You accent harmonization for Android 12+.
- Evaluate Rive integration for lighter runtime animations.
- Automate analytic event schema validation pre-commit.

## 11. Contacts
- Engineering Lead: TBD
- Motion & Proto Engineer: TBD
- Design Ops: TBD
- Product Analytics: TBD
## 12. Production Architecture Blueprint
- **Authentication & OTP**: Firebase Auth + Cloud Functions (phase 0) or AWS Cognito + Lambda (phase 1). Endpoints:
  - `POST /auth/login` (email/password) → returns session + OTP challenge ID.
  - `POST /auth/otp/verify` (challenge_id, code) → success/failure, rotates tokens.
  - `POST /auth/otp/resend` (challenge_id, method) → triggers SMS/email/push via Twilio/SES/Firebase Cloud Messaging.
- **Capsule Service**: Firestore collection `capsules` with seasonal/week/event metadata; Cloud Function `GET /capsules?date=...` caches next 3 capsules. Long term: move to GraphQL API (Hasura/Supabase) for flexible queries.
- **Personalization Store**: User document `user_settings/{uid}` caching capsule overrides, accessibility toggles. Sync via `PATCH /users/{uid}/settings`.
- **Analytics Pipeline**: Segment forwarder capturing client events → Looker dashboards. MVP uses analytics proxy Cloud Function `POST /analytics` for environments without direct Segment key.
- **Asset Delivery**: Capsules host textures/Lottie/audio on Firebase Storage (public CDN) with signed URLs. Naming scheme `capsules/{capsule_id}/{asset}`, manifest JSON stored alongside.

**Security & Compliance Notes**
- OTP codes stored hashed with TTL (Redis via Upstash) to prevent plain-text exposure.
- All endpoints require HTTPS + Firebase Auth token (or Cognito JWT). Enforce rate limits (5/min) on resend endpoints.
- Log PII separately with redaction; capsule metadata safe for caching.

**Implementation Sequence**
1. Choose stack (Firebase-first, AWS expansion optional) and scaffold Cloud Functions repo.
2. Define shared DTOs (Dart/TypeScript) for OTP challenge and capsule models.
3. Set up environment config in Flutter (`lib/core/config/app_config.dart`) to switch base URLs.
4. Integrate Dio client with interceptors for auth refresh + logging.
5. Replace mock services stepwise: Auth → OTP → Capsule → Settings → Analytics.
