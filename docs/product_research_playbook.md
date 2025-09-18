# Product & Research Playbook
Version: 2025-09-17
Owners: Product Lead, Principal UX Strategist, Research Agent

## 1. Product Overview
- **Product**: FitCheck Liquid Glass OTP (iOS & Android).
- **Mission**: Deliver secure, emotionally resonant MFA rituals synchronized with fashion capsules.
- **Key Personas**: Style Maven, On-the-go Creator, Security Guardian (see Experience Handbook ?1).

## 2. Core Product Requirements
### 2.1 OTP Verification Flow (PRD Summary)
- *Objective*: Premium, low-friction OTP journey.
- *Success Metrics*: Completion median <6s, success rate ?98%, premium perception ?90%.
- *Functional Scope*: OTP entry (4/6 digits), method metadata, auto-submit, paste detection, resend with cooldown, alternate methods, analytics events (`otp_*`).
- *Non-Functional*: 60 FPS target, asset payload <200KB, localization ready, WCAG AA.
- *UX Requirements*: Ambient welcome, capsule storytelling, timer states, success ripple, error coaching.

### 2.2 Seasonal & Weekly Capsule Engine
- *Objective*: Rotating themes across seasons, weeks, and special events.
- *Metrics*: Capsule adoption ?60%, production lead time <4 days, zero missed events.
- *Features*: Capsule scheduling API, theme metadata (palette, motion, copy tokens), manual overrides, accessibility variants, analytics (`capsule_*`).
- *Content Pipeline*: Brief ? production ? QA ? release; backlog states (idea, sprint, production, QA ready, scheduled, live, archive).

### 2.3 Personalization & Accessibility Settings
- *Objective*: User control over capsules and comfort settings.
- *Features*: Default/day-specific capsule selection, toggles (`reduced_motion`, `high_contrast`, `sound_effects`, `haptics`), instant preview, sync to profile.
- *Metrics*: Settings adoption >70%, accessibility satisfaction ?4.5/5.
- *Analytics*: `settings_view`, `settings_change`, `accessibility_toggle`, `capsule_override`.

## 3. Research Operations
### 3.1 Repository Structure
- Collections: Interviews, Surveys, Trend Radar, Accessibility Panel, Analytics Insights.
- Tagging: persona (style_maven/creator/guardian), emotion, theme, priority.
- Workflow: Upload artifact ? tag ? link to backlog/PRD ? share in Monday digest ? archive after 12 months.

### 3.2 Current Insights (Sep 2025)
- Diary study: Reduced motion toggle needs higher prominence; led to settings sprint.
- Analytics: Capsules active deliver 12% faster completions vs. default theme.
- Trend radar: Analog ink overlays trending; action item to commission illustrator.

### 3.3 Upcoming Research
| Date | Initiative | Owner |
| --- | --- | --- |
| 2025-09-25 | Personalization micro-survey | UX Strategist |
| 2025-10-01 | Winter capsule co-creation workshop | Research Agent |
| 2025-10-05 | Accessibility case study refresh | Accessibility Champion |

## 4. Analytics Framework
- **Pillars**: Experience quality, emotional engagement, accessibility & comfort, operational efficiency.
- **KPI Highlights**:
  - OTP completion rate ?98%.
  - Capsule feedback ?4.5/5.
  - Reduced motion adoption ?20%.
  - Release on-time ?95%.
- **Funnels**:
  - OTP: `view ? digit_entered ? success/error ? method_switch ? success_fallback`.
  - Capsule: `view ? select ? active ? feedback`.
  - Settings: `view ? change ? toggle ? sync_success`.
- **Dashboards** (Looker): OTP Quality, Capsule Engagement, Accessibility Scorecard, Operational Efficiency.
- **Data Governance**: `snake_case` event params, include `capsule_id`, `theme_variant`, `a11y_flags`, raw event retention 13 months.

## 5. Journey & Persona Artifacts
- **Journey Map**: Anticipation (marketing touchpoints), Verification (OTP screen), Celebration (success reveal), Continuation (gallery & settings). Pain points: OTP expiry, motion discomfort, personalization awareness. Delight: signature illustration, weekly preview.
- **Persona Snapshots**: Motivations, behaviors, needs, accessibility considerations consolidated in Experience Handbook (?1).

## 6. Capsule Calendar (Rolling 12 Weeks)
| Week | Capsule | Type | Key Milestones | Touchpoints |
| --- | --- | --- | --- | --- |
| W38 | Monday Reset | Weekly | QA Sep 15, Release Sep 18 | IG teaser Sep 17 |
| W39 | Wednesday Pulse | Weekly | Release Sep 25 | In-app banner Sep 23 |
| W40 | Friday Afterglow | Weekly | Release Oct 3 | Email Oct 1 |
| W41 | Autumn Ember Nights | Seasonal | Production Oct 8-10 | Blog Oct 10 |
| W44 | Halloween Veil | Special | Release Oct 27 | Social drop Oct 27 |
| W48 | Black Friday Obsidian | Special | Release Nov 24 | Push + email Nov 24 |
| W49 | Winter Glacial Glow | Seasonal | Release Dec 4 | Campaign Dec 3 |

## 7. Backlog & Prioritization
- **States**: Idea Pool ? Concept Sprint ? Production ? QA Ready ? Scheduled ? Live ? Archive.
- **Sample Backlog**:
  - SPR-01 Morning Dew (Spring, production, release Mar 1).
  - SUM-01 Neon Mirage (concept sprint, release Jun 10).
  - WK-MON Monday Reset (scheduled Sep 22; QA complete).
  - EVT-NY New Year Prism (idea pool, needs marketing alignment).
- **Risk Register** (top items): schedule overlap between seasonal & special (mitigate with 3-week buffer), shader FPS drops (fallback textures + benchmarks), localization lag (early engagement), telemetry inconsistencies (standardize event wrapper).

## 8. Testing & Validation
- **Prototype Testing Protocol**: Define objectives, recruit 5+ participants, run interactive & motion prototypes, evaluate completion time, emotional response, motion comfort, accessibility compliance.
- **Accessibility Plan**: Automation (Axe), expert review each sprint, panel of 8 quarterly, assistive tech matrix across devices; metrics include zero critical defects and remediation <1 sprint.
- **Performance Benchmarks**: Device tiers (iPhone 14 Pro ? Moto G Power), scenarios (OTP default/reduced motion, capsule switch, settings), metrics (FPS ?55, frame build <16ms, CPU <40%). Report per sprint.

## 9. Roadmap Synchronization
- **Phases**:
  - Phase 2: Core features (OTP screens, main screens, AI module).
  - Phase 3: Advanced features (Wardrobe, shopping, social).
  - Phase 4+: Backend, QA, deployment, polish.
- **Critical Path**: Authentication ? Main screens ? AI module; Shopping ? Backend ? Testing; Performance ? Deployment ? Launch.

## 10. Governance
- Weekly Capsule kickoff (Monday), Laboratory session (Wednesday), Gallery walk (Friday).
- Trend radar digest delivered Monday 08:00; analytics pulse Monday 12:00; capsule performance review Friday.
- Documentation maintained in repo `docs/` with owners per section; updates reflected in Notion master index.

## 11. Appendices
- Appendix A: Event schema quick reference.
- Appendix B: Survey question bank for capsule satisfaction.
- Appendix C: Usability script template.
- Appendix D: Research consent checklist.
## 12. MVP Scope & Backlog (Phase Zero)
| Flow | Description | Deliverables | API Dependencies | Status |
| --- | --- | --- | --- | --- |
| Onboarding → Login | Welcome funnel into authentication | Updated copy/images, analytics hooks, error handling | Auth API (token), Analytics | Planned |
| OTP Verification Ritual | Capsule hero + 6-digit OTP + resend/options | Screen + provider + analytics + success route | OTP verify, OTP resend, Capsule metadata | In progress |
| Home Snapshot | Hero capsule, streak widget, shortcuts | Modular home widgets, capsule summary API hookup | Capsule feed, User profile | Planned |
| Capsule Gallery | Seasonal/weekly/special explorer | Scrollable gallery, preview modal, adoption analytics | Capsule list, Capsule preview assets | Planned |
| Personalization & Accessibility | Capsule scheduling + comfort toggles | Settings screen, state persistence, preview | User preferences, Accessibility profile | Planned |
| Settings & Support | Account, security notices, help | Fallback theme, incident messaging, feedback link | User profile, Incident feed | Planned |

**Milestones**
1. *M0 (Week 1)*: OTP ritual live with production auth + analytics.
2. *M1 (Week 2-3)*: Home + Capsule gallery with real capsule service.
3. *M2 (Week 4)*: Personalization + settings syncing across devices.
4. *M3 (Week 5)*: MVP polish (performance, accessibility, QA) + deploy.

## 13. Sprint Plan (6-week MVP)
| Sprint | Focus | Primary Owners | Exit Criteria |
| --- | --- | --- | --- |
| S1 | Auth + OTP production hookup | Engineering, Security | Live OTP API, analytics events firing |
| S2 | Capsule engine services | Engineering, Design Ops | Capsule list + metadata API, gallery prototype |
| S3 | Personalization settings | Engineering, UX | Toggle state persisted + accessibility mode |
| S4 | Motion & polish | Motion, UI | Animation perf >=55 FPS, haptics & audio mapped |
| S5 | QA & accessibility | QA, UX | WCAG AA sign-off, device matrix tests |
| S6 | Launch readiness | Ops, Marketing | Runbook signed, marketing assets scheduled |
