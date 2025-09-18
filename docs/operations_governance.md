# Operations & Governance Manual
Version: 2025-09-17
Owners: Design Ops Agent, Product Lead, Creative Director

## 1. Operating Rhythm
- **Monday 09:30 ? Capsule Kickoff**: Trend digest, backlog grooming, assignment confirmations.
- **Wednesday 14:00 ? Lab Session**: Motion prototypes, usability findings, blocker clearance.
- **Friday 16:00 ? Gallery Walk**: Hi-fi review, copy refresh, analytics snapshot.
- **Monthly Seasonal Summit**: Update seasonal roadmap, heritage board, marketing alignment.

## 2. Team Roles & Responsibilities
| Agent | Focus | Key Responsibilities |
| --- | --- | --- |
| Creative Director | Vision & storytelling | Approve capsules, maintain brand voice, lead Gallery Walk |
| Principal UX Strategist | Experience architecture | Flow mapping, usability labs, accessibility checkpoints |
| Lead UI Artisan | Visual systems | Component craft, Figma tokens, implementation specs |
| Motion & Proto Engineer | Interaction choreography | Motion prototypes, device benchmarks, haptics |
| Design Ops & Asset Curator | Workflow governance | Capsule calendar, asset pipeline, QA coordination |
| Content & Copy | Microcopy & localization | Capsule copy kits, voice calibration, localization bundles |
| Research Agent | Insights pipeline | Trend radar, interviews, digest updates |
| Data & Analytics | Measurement | Dashboard upkeep, anomaly detection, weekly reports |

## 3. Capsule Production Pipeline
1. **Inspiration Intake** (Research + Creative Director) ? moodboards, opportunities.
2. **Concept Framing** (Creative + UX) ? emotional arc, signature detail, accessibility notes.
3. **Design Production** (UI, Motion, Content) ? visuals, motion, copy (SLA 3 days per capsule).
4. **QA & Readiness** (Design Ops + Data) ? visual/motion/copy/data checklists.
5. **Release & Monitor** (Design Ops + Analytics) ? calendar update, dashboards, post-launch review.

- Backlog states: Idea Pool ? Concept Sprint ? Production ? QA Ready ? Scheduled ? Live ? Archive.
- Sample active items: SPR-01 Morning Dew (production, release Mar 1), SUM-01 Neon Mirage (concept), WK-MON Monday Reset (scheduled Sep 22), EVT-NY New Year Prism (idea).
- SLA Overview: Intake 2d, Framing 1d, Production 3d, QA 1d, Release prep 0.5d.

## 4. Launch Runbook
- Timeline: T-14d concept lock ? T-10d engineering handoff ? T-7d marketing + localization ? T-3d performance & analytics QA ? T-1d go/no-go ? T0 release ? T+1d metrics snapshot ? T+7d retro.
- Checklist (condensed):
  - Design approvals, motion assets, accessibility variants ready.
  - Feature flag + release branch merged, smoke test iOS/Android.
  - Marketing copy localized, channels scheduled, in-app messaging configured.
  - Events validated in staging, dashboards updated.
  - Capsule calendar & risk register reviewed, on-call confirmed.
- Communication: Slack #capsule-live updates (T0, T+1h, T+24h), exec email T+24h, support brief with FAQ.

## 5. Incident Response
- Severity matrix: SEV0 (OTP outage, resolve <60m), SEV1 (major degradation <2h), SEV2 (minor issue <24h), SEV3 (cosmetic backlog).
- Workflow: Assign incident commander ? open Jira ticket ? notify #capsule-incident ? assemble squad ? implement mitigation (flag off capsule, fallback theme, throttle animations, reissue assets) ? update every 30-60 min ? document timeline.
- Post-incident review within 48h; update risk register, QA standards, and runbook.

## 6. Risk & Compliance
- Top risks: schedule overlap (mitigate with buffer + backup designer), shader FPS drops (fallback textures + benchmarks), localization delays (early engagement), analytics inconsistencies (standardized wrapper).
- Risk register reviewed weekly; statuses *open*, *monitor*, *mitigated* tracked with owners.
- Accessibility compliance documented per release (scorecard, panel feedback) for legal readiness.

## 7. Stakeholder Communication
| Stakeholder | Needs | Channel | Cadence | Owner |
| --- | --- | --- | --- | --- |
| Executive Team | Release readiness, impact, risks | Email summary, MBR | Weekly per release + monthly | Product Lead |
| Engineering | Design updates, QA results | Weekly sync, Slack #design-eng | Weekly | Engineering Lead |
| Marketing | Capsule schedule, assets | Marketing sync, shared calendar | Weekly | Creative Director |
| Support & CX | FAQ, known issues | Support briefing, incident alerts | Weekly + as-needed | Product Lead |
| Legal/Compliance | Copy claims, accessibility docs | Review sessions, repository | Per release | Design Ops |

Escalation triggers: SEV0 incident ? exec/support email; schedule slip >48h ? product & marketing Slack alert.

## 8. Training & Enablement
- Tracks: Design Mastery, Engineering Integration, Accessibility Practice, Marketing Alignment, Support Enablement.
- Formats: Live workshops (recorded), LMS modules, hands-on labs, quizzes.
- Q4 Sessions: Oct 05 Design deep dive, Oct 12 Shader lab, Oct 19 Reduced motion playtest, Oct 26 Holiday campaign prep, Nov 02 Personalization troubleshooting.
- Metrics: Pre/post confidence surveys, completion rate, qualitative feedback.

## 9. Marketing Collaboration
- Weekly Thu sync; shared content calendar drives asset requests.
- Touchpoint strategy: in-app banners (3d lead), push (2d), email (5d), social (7d), blog/editorial (10d).
- Asset pipeline: concept approval ? Design Ops asset pack ? marketing adaptation ? review ? store in `marketing/{capsule_id}`.
- Messaging framework: theme hook + benefit + CTA (`Unlock capsule`, `Preview the glow`). Fallback assets ready for delays.

## 10. Governance Tools
- Notion master index referencing consolidated docs.
- Airtable boards: capsule calendar, QA log, research repository, analytics highlights.
- Jira board aligned to backlog states, checklists embedded per capsule.
- Slack automations: reminders for SLA breaches, QA completion, incident alerts.

## 11. Continuous Improvement
- Sprint retros feed into pipeline adjustments and tool enhancements.
- Quarterly skill exchange sessions (analog illustration, sound design, shader tuning).
- Documentation review each quarter to merge redundant content and update owners.

## 12. Appendices
- Appendix A: Capsule release template (Notion link).
- Appendix B: Incident ticket template fields.
- Appendix C: Training RSVP tracking sheet.
- Appendix D: Support FAQ outline for personalization & accessibility.
