# Android Emulator QA – Trend Pulse Spotlight & OTP Flow

- **Device**: Android Emulator sdk gphone64 x86 64 (API 34)
- **Build**: Debug (flutter run -d emulator-5554, 2025-09-19)
- **App State Prep**:
  - Cleared app state (fresh install via flutter run).
  - Seeded Trend Pulse provider from asset bundle (no network fetch required).

## Trend Pulse Spotlight
1. Launch app › accept personalization defaults (StartScreen idle state).
2. Navigate to home tab (MainAppScreen) and scroll to “Trend Pulse Spotlight”.
3. Observed daily drop card renders without overflow; CTA buttons enabled after session load.
4. Verified ticker animates; reduced motion toggle respected (Settings › Personalization › Reduced Motion on/off).
5. Tapped primary CTA – navigated via NavigationProvider without guard redirect.

**Result**: PASS – spotlight respects high-contrast/reduced-motion states, analytics hooks triggered (`trend_pulse_loaded`, `trend_pulse_cta_tap`).

## OTP Flow
1. From navigation menu choose “OTP Flow” (StartScreen quick action).
2. Confirmed six-digit input fields expand to fit width (no RenderFlex overflow).
3. Entered digits `123456` › success state with session summary + proceed CTA.
4. Triggered resend (waited for timer expire); state transitions logged (`otp_resend_requested`).

**Result**: PASS – layout stable on API 34, session provider clears error on retry.

## Screen Capture Notes
- Use the following commands while emulator is focused to capture reference images:
  ```bash
  adb exec-out screencap -p > docs/qa/screenshots/2025-09-19_trend_pulse.png
  adb exec-out screencap -p > docs/qa/screenshots/2025-09-19_otp.png
  ```
- Screenshots should show Trend Pulse spotlight card and OTP success panel respectively.

## Follow-up
- Attach captured PNGs to `docs/qa/screenshots/` and reference them from this log when available.
- Include QA evidence link in `PROJECT_MANAGEMENT.md` once screenshots are committed.
