# Trend Pulse Deep Link Regression Plan

## Objectives
- Verify that guarded navigation respects authentication, profile completion, and personalization gates when landing on `AppRouter.trendPulse`.
- Ensure analytics events (`navigation_guard_redirect`, `navigation_resolved`, `trend_pulse_loaded`, `trend_pulse_cta_tap`) fire with expected payloads for each entry path.
- Confirm that personalization preferences (high contrast, reduced motion) toggle the Trend Pulse UI variants on deep-link entry.

## Test Matrix
| Scenario | Entry Route | Auth State | Profile State | Personalization State | Expected Result |
| --- | --- | --- | --- | --- | --- |
| TP-001 | `fitcheck://trend-pulse` | Logged out | N/A | Initial | Redirect to login, guard analytics logged |
| TP-002 | `fitcheck://trend-pulse` | Authenticated | Profile incomplete | Personalization pending | Redirect to profile setup, guard analytics logged |
| TP-003 | `fitcheck://trend-pulse` | Authenticated | Profile complete | Personalization incomplete | Redirect to personalization settings, guard analytics logged |
| TP-004 | `fitcheck://trend-pulse` | Authenticated | Profile complete | Personalization ready (default) | Trend Pulse screen loads daily drop |
| TP-005 | `fitcheck://trend-pulse` | Authenticated | Profile complete | High contrast + reduced motion | Screen loads with static cards, no animations |
| TP-006 | `fitcheck://trend-pulse?cta=save` | Authenticated | Profile complete | Personalization ready | Trend Pulse loads, `trend_pulse_loaded` and CTA-specific analytics fire upon tap |

## Instrumentation Checks
1. `NavigationProvider.handleDeepLink` should resolve route and emit `navigation_deeplink` with `requested_route: AppRouter.trendPulse`.
2. Guard redirects must include `reason` values (`auth`, `profile`, `personalization`).
3. On successful load, `TrendPulseProvider` logs `trend_pulse_loaded` with counts.
4. CTA taps (`Suit Up`, `Save To Locker`) log `trend_pulse_cta_tap` with `cta_tag` and `daily_drop_id`.
5. Saga focus and ticker callbacks log `trend_pulse_saga_focus` / `trend_pulse_ticker`.

## Manual Execution Steps
1. Configure test builds with deep-link harness (Flutter run --dart-define=ENABLE_DEEP_LINK_TESTS=true).
2. Use `adb shell am start -W -a android.intent.action.VIEW -d "fitcheck://trend-pulse" com.fitcheck.app` (Android) or `xcrun simctl openurl booted fitcheck://trend-pulse` (iOS).
3. Manipulate auth/profile states via debug menu to cover matrix.
4. Capture analytics payloads from debug console (`AnalyticsService.logEvent`).
5. Record screenshots for both default and high-contrast variants.

## Automation Hooks
- Add widget test exercising `NavigationProvider.handleDeepLink` once deep-link harness is available (Script 2.3 dependency).
- Extend `test/providers/trend_pulse_provider_test.dart` with deep-link analytics expectations when dependency injection supports fake analytics sink.
- Integrate scenario TP-004 into smoke test suite after canvas scaffolding is complete.

## Follow-Up
- Update this plan upon completion of Script 2.3 to reference actual automation.
- Link execution evidence in `docs/progress_log.md` when regression is run before release.
