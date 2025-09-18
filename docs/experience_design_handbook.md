# Experience Design Handbook
Version: 2025-09-17
Owners: Creative Director, Lead UI Artisan, Principal UX Strategist

## 1. Vision & Narrative
- **Promise**: Frictionless yet sensorial multifactor authentication that feels like entering a couture-grade vault.
- **Narrative Pillars**: Ethereal trust, couture detail, ritualized joy.
- **Experience Arcs**:
  - *Arrive ? Delight ? Verify ? Continue Story*.
  - *Seasonal capsule onboarding ? Daily verification ritual ? Surprise moment*.
- **Personas**:
  - *Style Maven*: Seeks premium, calm OTP ritual with clear confirmations.
  - *On-the-go Creator*: Needs fast, low-motion flow and dependable fallbacks.
  - *Security Guardian*: Values transparent status, accessibility controls for teams.

## 2. Competitive Signals & Differentiators
- Enterprise MFA tools (Google, Microsoft, Okta) deliver trust but lack warmth and personalization.
- Lifestyle security apps (Authy, 1Password) show polish yet inconsistent storytelling.
- Cross-industry inspiration (Revolut, Aesop, Nowness, Nothing) informs glass textures, motion choreography, editorial tone.
- **Differentiation Pillars**: Living capsules, analog + digital fusion, multisensory depth, ritual framing.

## 3. Design Language System
### 3.1 Color Architecture
| Tier | Palette | Hex | Use |
| --- | --- | --- | --- |
| Base Glass | Mist Quartz | #E8EEF2 | Primary substrate (40% opacity) |
| Dark Anchor | Abyss Slate | #0D1218 | Text, deep backgrounds |
| Accent | Prism Orchid | #C69EFF | CTAs, progress rings (?10%) |
| Accent | Neon Tide | #00E0D2 | Focus states, capsule indicators |
| Support | Ember Veil | #FFB082 | Success, seasonal handoff |
| Alert | Copper Pulse | #FF6F61 | Error glow |

**Gradient Recipes**: Aurora Veil (Mist Quartz ? Prism Orchid 120?), Glacial Shift (Abyss Slate ? Neon Tide radial), Afterglow (Ember Veil ? Copper Pulse 45? with 5% noise).

### 3.2 Typography
- Primary: "S?hne" variable (300-700). Fallback: Inter, SF Pro, Roboto.
- Display 36/40, Body 16/24, Caption 12/16. Tabular figures for OTP digits.
- Enable stylistic alternates for seasonal headlines; keep OTP copy utilitarian.

### 3.3 Iconography & Illustration
- 1.5pt line icons with 4px radius, inner shadow 12%.
- Signature illustration: analog ink blots blended with volumetric light.
- Each capsule includes *one* signature detail (texture or illustration) plus *one* dynamic element (parallax, light flare).

### 3.4 Layout & Components
- Baseline grid 8px (4px micro adjustments). Safe zones 24px top/bottom.
- Glass elevation levels: 0 background (blur 48), 1 passive (blur 24), 2 primary cards (blur 18 + inner glow), 3 CTA/dialogs (blur 14 + Neon Tide outline).

**Core Components**
- **OTP Hero Card**: Level 2 glass, 24px radius, gradient mask header, Neon Tide timer chip, seasonal illustration.
- **OTP Digit Cell**: 64?72px pill, Mist Quartz 30% fill (idle), Neon Tide glow (focus), Copper Pulse shake (error), cascade highlight on paste.
- **Timer Chip**: Abyss Slate 60% background, Neon Tide text; pulses Copper Pulse final 10s.
- **Capsule Switcher**: Horizontal parallax (background speed 0.6?), capsule chips 96?128px with dot intensity motif.
- **Microcopy Panel**: Two-column layout, seasonal badge slot, high-contrast fallback.

### 3.5 Microcopy Voice
- **Principles**: Sensory precision, warm assurance, concise storytelling.
- **Templates**: `Welcome back, {name}. Your style vault awaits.` / `Verified. Let the look unfold.` / `Digits didn?t align. Let?s try again.`
- **Seasonal Keywords**:
  - Spring: bloom, dew, dawn.
  - Summer: blaze, horizon, pulse.
  - Autumn: ember, dusk, hush.
  - Winter: frost, glow, hush.
  - New Year: prism, countdown, ignite.
- Accessibility: Lead with instruction before metaphor, Grade 7-8 reading level.

## 4. Motion & Sensory System
- **Timing Sets**: Enter 320ms ease-out; Exit 240ms ease-in; Micro-confirm 120ms spring.
- **Primitives**:
  - OTP digit ripple (scale 1.0?1.08, blur 0?12, 260ms, light haptic, soft tick audio).
  - Capsule slide transition (480ms, parallax offset 40%, medium haptic, capsule swipe audio).
  - Error glow (Copper Pulse ? Ember Veil, shake 5?, sharp double haptic).
  - Hero light sweep (1600ms loop, disable on reduced motion).
- **Haptic Map**: Light (UIImpactFeedbackStyle.light / HapticFeedbackType.lightImpact), Medium, Sharp Double for errors.
- **Reduced Motion**: Swap slide for crossfade (260ms linear), disable hero sweep.
- **Audio Palette**: Soft glass chimes (A4/C5), success triad, error hush.

## 5. Experience Architecture
### 5.1 Journey Stages
1. **Anticipation**: Notifications and previews build mood. KPIs: notification CTR, preview views.
2. **Verification**: OTP screen clarity, sensory feedback, accessibility aids. KPIs: completion time, error rate.
3. **Celebration**: Success ripple, share invitation, preview next capsule. KPIs: satisfaction score, share rate.
4. **Continuation**: Capsule gallery, personalization toggles, weekly drops. KPIs: capsule adoption, settings usage.

### 5.2 Accessibility
- Contrast ratio ? 4.5:1, high-contrast palette (Abyss Slate + Neon Tide).
- Screen reader labels: "OTP digit {n}"; timers announced.
- Reduced motion toggle accessible within two taps; disables parallax, hero sweep.
- Validation plan covers automation (Axe), expert audits, user panel of eight quarterly, assistive tech matrix (VoiceOver, TalkBack, zoom, keyboard).

## 6. Capsule System
- **Seasonal Series**: Spring Renewal (frosted quartz, morning dew), Summer Vivid Heat (molten glass, lens flare), Autumn Ember Nights (velvet grain, fogged glass), Winter Glacial Glow (crystalline shards, warm candle).
- **Weekly Capsules**: Monday Reset (mist grey + mint, breath ripple), Wednesday Pulse (electric cyan + plum, pulse beat), Friday Afterglow (champagne gold + indigo, sparkle confetti).
- **Special Moments**: New Year Prism, Valentine Rose Dust, Black Friday Obsidian.
- Capsule storyboards include hero screen, supporting screen, motion frame, microcopy variations.

## 7. Research & Insights Highlights
- Trend radar tracks visual design, motion, materials, user behavior; weekly digest tags palette/material/motion/tone/accessibility.
- Persona deep dive and diary studies indicate 65% adoption uplift with capsules vs. default.
- Upcoming research: Winter capsule co-creation (Oct 1), personalization micro-survey (Sep 25), accessibility case updates (Oct 5).

## 8. Measurement Framework
- **Experience Quality**: OTP completion ? 98%, median time < 6s, error recovery > 95%.
- **Emotional Engagement**: Capsule adoption ? 60%, feedback ? 4.5/5, streak retention uplift.
- **Accessibility**: Reduced motion usage ? 20%, high contrast ? 15%, zero critical defects.
- **Operational**: Release on-time ? 95%, QA defect escape < 3%.
- Dashboards (OTP Quality, Capsule Engagement, Accessibility, Operational Efficiency) built in Looker with Segment events and Airtable QA data.

## 9. Governance & QA
- QA checklist covers visual, motion, accessibility, copy, data; each release logs screenshot/video evidence.
- Motion QA target ?55 FPS across iPhone 13+, Pixel 6+, Galaxy S22.
- Accessibility scorecard appended to release notes; issues remediated < 1 sprint.
- Design Ops maintains heritage board and design token versioning; weekly design language standup and bi-weekly release notes.

## 10. Deliverables & Timeline
- **Design Language Expansion**: Updated Figma library, texture kit v2, motion spec (2 weeks).
- **Seasonal Capsule Pilot**: Spring capsule + weekly variants + prototype video (3 weeks).
- **Verification QA Sprint**: Accessibility report, device benchmarks, copy QA (2 weeks).

## 11. Appendices
- **Appendix A**: Component specs (OTP hero, digit input, timer chip, capsule card).
- **Appendix B**: Copy token list and localization guardrails.
- **Appendix C**: Motion library JSON snippet (see repo `assets/lottie`).
- **Appendix D**: Accessibility test matrix and assistive tech mapping.
## 12. Visual Research & Moodboard Targets
- **OTP Luxury Rituals**: Reference Gucci Vault login, Nothing OS Glyph prompts, Aesop checkout transitions. Capture screenshots of hero storytelling + code input.
- **Capsule Galleries**: Study Farfetch capsule collections, Apple Fitness+ weekly boards, Nike SNKRS drops for layout rhythm and microcopy cadence.
- **Personalization Settings**: Review Notion theme selector, Tesla comfort settings, Headspace accessibility toggles for slider/preview combos.
- **Motion & Haptics**: Analyze Motionographer features on liquid/chrome transitions; capture easing curves + light sweeps for reuse.
- **Sound Palette**: Source low-volume chimes from Ableton Packs, Nothing phone sound design, and custom field recordings (glass taps) for success cues.

**Moodboard Workflow**
1. Research agent gathers 6–8 references per theme (OTP, capsule, personalization, motion, sound) every Thursday.
2. Creative Director curates into master board in Figma (separate pages per flow) by Friday 12:00.
3. Lead UI + Motion annotate design implications (color, material, timing) before Monday Capsule Kickoff.
4. Heritage board updated monthly with best-in-class inspiration + shipped screenshots for parity tracking.
