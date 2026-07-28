# Hindsight Post-MVP Master Plan — Baseline v1.0

**Baseline frozen:** 2026-07-28
**Status:** BASELINE — this document's estimates are immutable. All change flows through the CR log.
**Scope:** everything after the MVP ships. Horizons H2–H4 from `LONG_TERM_PLAN.md`.

> **Read this first.** The purpose of this plan is not to be right. It is to be *measured*.
> We are testing planning ability, which requires an unedited original to measure against.
> **Never edit a Baseline Estimate.** When reality diverges, log a Change Request and record the
> delay. A plan that gets quietly rewritten teaches nothing.

---

## 1. Taxonomy

Every task carries four tags.

**Function** (the "board tag" — one per task)

| Tag | Meaning |
|---|---|
| `ENG` | Application engineering |
| `QA` | Test, release engineering, verification |
| `DESIGN` | Product and visual design |
| `MKT` | Marketing, positioning, content |
| `UA` | User acquisition, growth, attribution |
| `SALES` | Monetisation, partnerships, B2B2C |
| `OPS` | Tooling, infrastructure, internal systems |
| `LEGAL` | Privacy, terms, compliance, store policy |
| `PM` | Planning discipline itself (the meta-layer) |

**Horizon:** `H2` (habit + ICP, 3–9mo) · `H3` (distribution, 9–18mo) · `H4` (compounding, 18mo+)

**Risk:** `LOW` · `MED` · `HIGH` — HIGH means the estimate is a guess and we expect to learn from it.

**Dependency:** blocking task IDs, or `none`.

---

## 2. The measurement contract

### Per-task fields

| Field | Rule |
|---|---|
| **Baseline Estimate** | Set once, at baseline. **Immutable forever.** |
| **Current Estimate** | May be revised; every revision requires a CR. |
| **Actual** | Recorded at completion. |
| **Delay Cause** | Required if Actual > Baseline. Enum below. |
| **Linked CR** | Required if Delay Cause is `change-request`. |

### Delay cause taxonomy

| Cause | Meaning | What it teaches |
|---|---|---|
| `change-request` | Scope changed by decision | Were we decisive enough up front? |
| `underestimate` | Scope was right, effort was wrong | Are our estimates calibrated? |
| `dependency` | Blocked by another task | Did we sequence correctly? |
| `external-blocker` | Apple review, third party, account | Did we anticipate external risk? |
| `rework` | Built it, it was wrong, rebuilt | Did we validate before building? |
| `discovery` | Found unknown work mid-task | Was the breakdown deep enough? |

**This taxonomy is the whole experiment.** "We were late" is not a lesson. "60% of our slip was
`discovery`, meaning our task breakdown is too shallow" is a lesson that changes the next plan.

### Change Request record

Every CR gets an ID (`CR-001`…) and records:

1. Date raised, and by whom
2. What changes, and the rationale
3. Tasks affected (IDs)
4. **Estimated delay at time of raising** — stated *before* the work, never backfilled
5. Actual delay, measured at completion
6. Decision: `accepted` / `rejected` / `deferred`

The gap between estimated and actual CR delay is itself a planning-accuracy signal.

### Planning accuracy metrics — reviewed at each phase boundary

| Metric | Definition | Target |
|---|---|---|
| **Estimate ratio** | `Actual ÷ Baseline`, per task and aggregate | Converging toward 1.0 across phases |
| **Delay attribution** | % of total slip by cause | `discovery` and `rework` shrinking over time |
| **Plan stability** | % of baseline tasks completed unmodified | Rising |
| **CR volume** | CRs raised per phase | Falling, or stable with better estimates |
| **CR estimate accuracy** | CR actual delay ÷ CR estimated delay | Converging toward 1.0 |

Estimates are in **ideal days** (uninterrupted work), not calendar days.

---

## 3. Work breakdown

Baseline estimates in ideal days. IDs are stable and referenced by Jira/Notion.

### E1 — Hands-free capture `ENG` `H2`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E1.1 | App Group entitlement + shared container setup | ENG | 1 | LOW | none |
| E1.2 | Migrate store to App Group, backup-first, validate-then-swap | ENG | 3 | **HIGH** | E1.1 |
| E1.3 | Migration regression tests (idempotent, lossless) | QA | 2 | MED | E1.2 |
| E1.4 | On-device NL parsing spike (Foundation Models API verification) | ENG | 2 | **HIGH** | none |
| E1.5 | Parse utterance → Decision + Prediction draft | ENG | 4 | **HIGH** | E1.4 |
| E1.6 | Date phrase parsing + validation (NSDataDetector cross-check) | ENG | 2 | MED | E1.4 |
| E1.7 | Parse confirmation / correction UI | ENG | 3 | MED | E1.5 |
| E1.8 | Fallback path for non-Apple-Intelligence devices | ENG | 2 | MED | E1.5 |
| E1.9 | Siri App Intent (LogDecisionIntent) + AppShortcutsProvider | ENG | 3 | MED | E1.2, E1.5 |
| E1.10 | Confidence follow-up turn (number or qualitative band) | ENG | 2 | MED | E1.9 |
| E1.11 | Widget: quick capture (mic → launch into recording) | ENG | 2 | LOW | E1.2 |
| E1.12 | Widget: due for review | ENG | 2 | LOW | E1.2 |
| E1.13 | Control Center control + Action Button target | ENG | 2 | MED | E1.11 |
| E1.14 | Widget/intent test coverage | QA | 3 | MED | E1.9–E1.13 |

**Subtotal: 33 days**

### E2 — Insight engine v2 `ENG` `H2`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E2.1 | Domain-level calibration (by category) | ENG | 3 | MED | none |
| E2.2 | Overconfidence stat ("you say 90%, you're right 70%") | ENG | 2 | LOW | none |
| E2.3 | Short vs long horizon calibration split | ENG | 2 | LOW | none |
| E2.4 | Insight copy pass — gentle framing at reveal | DESIGN | 2 | MED | E2.1–E2.3 |
| E2.5 | Year in Review generator | ENG | 5 | MED | E2.1 |
| E2.6 | Year in Review shareable card design | DESIGN | 3 | MED | E2.5 |
| E2.7 | Insight engine test coverage + golden fixtures | QA | 3 | LOW | E2.1–E2.3 |

**Subtotal: 20 days**

### E3 — Retention mechanics `ENG` `H2`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E3.1 | Resolution streaks (never capture streaks) | ENG | 2 | LOW | none |
| E3.2 | Incomplete-entry tray + opportunistic completion prompts | ENG | 3 | MED | none |
| E3.3 | Notification inline-reply capture | ENG | 3 | MED | none |
| E3.4 | Ambient weekly prompt ("anything you're deciding?") | ENG | 2 | MED | none |
| E3.5 | Short-horizon nudge in capture flow | DESIGN | 1 | LOW | none |
| E3.6 | Retention mechanics test coverage | QA | 2 | LOW | E3.1–E3.4 |

**Subtotal: 13 days**

### E4 — Social foundation `ENG` `H3`

> **Gated on the Path A / Path B decision (see `LONG_TERM_PLAN.md` §4). Do not start until decided.**

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E4.1 | Path A/B decision memo + privacy posture rewrite | PM | 2 | **HIGH** | none |
| E4.2 | Identity model design (anonymous vs account) | ENG | 3 | **HIGH** | E4.1 |
| E4.3 | Duel rendezvous service (minimal, duel-scoped only) | ENG | 8 | **HIGH** | E4.2 |
| E4.4 | Duel create / accept / reveal UI | ENG | 5 | MED | E4.3 |
| E4.5 | Port Timestamped Receipt cards from archive branch | ENG | 2 | LOW | none |
| E4.6 | Second-opinion flow | ENG | 3 | MED | E4.3 |
| E4.7 | Anonymous aggregate benchmarks | ENG | 5 | **HIGH** | E4.3 |
| E4.8 | Backend test + load coverage | QA | 4 | MED | E4.3 |
| E4.9 | Abuse / moderation policy for shared content | LEGAL | 3 | **HIGH** | E4.1 |

**Subtotal: 35 days**

### E5 — QA and release engineering `QA`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E5.1 | CI: GitHub Actions build + unit tests on PR | QA | 2 | LOW | none |
| E5.2 | CI: UI test suite on merge | QA | 2 | MED | E5.1 |
| E5.3 | Device/OS test matrix definition | QA | 1 | LOW | none |
| E5.4 | Manual VoiceOver audit (carried over — outstanding) | QA | 2 | MED | none |
| E5.5 | Dynamic Type + small-device layout sweep | QA | 2 | LOW | none |
| E5.6 | TestFlight beta programme setup + tester recruiting | QA | 3 | MED | none |
| E5.7 | Privacy-compatible crash reporting evaluation + install | QA | 3 | **HIGH** | none |
| E5.8 | Regression suite expansion to post-MVP surfaces | QA | 4 | MED | E1, E2, E3 |
| E5.9 | Performance benchmarks (large history, cold launch) | QA | 2 | MED | none |
| E5.10 | Release checklist automation | QA | 2 | LOW | E5.1 |

**Subtotal: 23 days**

### E6 — Tooling and infrastructure `OPS`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E6.1 | Jira project `HIND` + issue types + workflow | OPS | 1 | LOW | none |
| E6.2 | Jira custom fields: Baseline, Current, Actual, Delay Cause, CR link | OPS | 1 | MED | E6.1 |
| E6.3 | Jira board views by Function tag | OPS | 1 | LOW | E6.2 |
| E6.4 | Notion planning hub: task DB + CR log + metrics dashboard | OPS | 2 | LOW | none |
| E6.5 | Repo ↔ Jira ↔ Notion sync convention (IDs, direction of truth) | PM | 1 | MED | E6.1, E6.4 |
| E6.6 | Design tool setup (Figma) + component library | DESIGN | 2 | LOW | none |
| E6.7 | Analytics decision — privacy-compatible or none | OPS | 2 | **HIGH** | none |
| E6.8 | App Store Connect setup + distribution signing | OPS | 2 | MED | none |
| E6.9 | Support channel (email/helpdesk) + response SLA | OPS | 1 | LOW | none |
| E6.10 | Secrets/credentials management for any backend | OPS | 2 | MED | E4.3 |

**Subtotal: 15 days**

### E7 — Marketing `MKT`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E7.1 | Finalise positioning (reconcile with post-revert product) | MKT | 2 | MED | none |
| E7.2 | ASO: title, subtitle, keyword sets | MKT | 2 | MED | E7.1 |
| E7.3 | App Store screenshots (5-shot storyboard) | DESIGN | 3 | MED | E7.1 |
| E7.4 | App Store preview video | DESIGN | 3 | MED | E7.3 |
| E7.5 | Landing page (copy + build + deploy) | MKT | 4 | MED | E7.1 |
| E7.6 | Press kit | MKT | 1 | LOW | E7.3 |
| E7.7 | Content engine: hindsight-bias / calibration series | MKT | 5 | MED | E7.1 |
| E7.8 | Launch plan: Product Hunt, HN, Reddit, timing | MKT | 2 | MED | E7.5 |
| E7.9 | Email list + capture on landing page | MKT | 1 | LOW | E7.5 |

**Subtotal: 23 days**

### E8 — User acquisition `UA`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E8.1 | Privacy-compatible attribution approach | UA | 2 | **HIGH** | E6.7 |
| E8.2 | Referral / invite mechanic design + build | UA | 4 | MED | E4.3 |
| E8.3 | Organic social channel test (3 platforms) | UA | 4 | MED | E7.7 |
| E8.4 | Influencer / creator outreach pilot | UA | 3 | **HIGH** | E7.6 |
| E8.5 | Paid acquisition test (small budget, 2 channels) | UA | 3 | **HIGH** | E8.1 |
| E8.6 | Campus ambassador pilot (student ICP) | UA | 5 | **HIGH** | none |
| E8.7 | ASO experiment cycle (icon, screenshots, keywords) | UA | 3 | MED | E7.2 |
| E8.8 | Retention cohort analysis + reporting | UA | 3 | MED | E8.1 |

**Subtotal: 27 days**

### E9 — Sales, monetisation, partnerships `SALES`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E9.1 | Pricing research (one-time vs subscription, tied to Path A/B) | SALES | 3 | **HIGH** | E4.1 |
| E9.2 | Monetisation implementation (StoreKit) | ENG | 4 | MED | E9.1 |
| E9.3 | Paywall / upgrade UX | DESIGN | 3 | MED | E9.1 |
| E9.4 | B2B2C exploration: universities, courses, coaching | SALES | 5 | **HIGH** | none |
| E9.5 | Team / org licensing model | SALES | 3 | **HIGH** | E9.4 |
| E9.6 | Partnership outreach (podcasts, newsletters) | SALES | 4 | MED | E7.6 |
| E9.7 | Revenue reporting + unit economics model | SALES | 2 | MED | E9.2 |

**Subtotal: 24 days**

### E10 — Legal and compliance `LEGAL`

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E10.1 | Privacy policy (must match the on-device claim exactly) | LEGAL | 2 | **HIGH** | none |
| E10.2 | Terms of service | LEGAL | 2 | MED | none |
| E10.3 | App Store privacy nutrition labels | LEGAL | 1 | MED | E10.1 |
| E10.4 | GDPR / CCPA readiness review (if Path B) | LEGAL | 4 | **HIGH** | E4.1 |
| E10.5 | Age rating review (relationship content, student ICP) | LEGAL | 1 | MED | none |
| E10.6 | Privacy claim audit — verify code matches marketing | LEGAL | 2 | **HIGH** | E10.1 |

**Subtotal: 12 days**

### E11 — Planning discipline `PM` (the meta-layer)

| ID | Task | Tag | Est | Risk | Deps |
|---|---|---|---|---|---|
| E11.1 | Freeze baseline snapshot (this document, tagged in git) | PM | 0.5 | LOW | none |
| E11.2 | CR log + template, in repo and Notion | PM | 1 | LOW | E6.4 |
| E11.3 | Delay attribution recording process | PM | 1 | MED | E6.2 |
| E11.4 | Phase-boundary review cadence + agenda | PM | 1 | LOW | none |
| E11.5 | Planning accuracy dashboard | PM | 2 | MED | E6.4, E11.3 |
| E11.6 | Retro template + first retro after E1 | PM | 1 | MED | E11.4 |

**Subtotal: 6.5 days**

---

## 4. Baseline totals

| Epic | Function focus | Days | Horizon |
|---|---|---|---|
| E1 Hands-free capture | ENG/QA | 33 | H2 |
| E2 Insight engine v2 | ENG/DESIGN/QA | 20 | H2 |
| E3 Retention mechanics | ENG/QA | 13 | H2 |
| E4 Social foundation | ENG/LEGAL/QA | 35 | H3 |
| E5 QA & release engineering | QA | 23 | H2–H3 |
| E6 Tooling & infrastructure | OPS | 15 | H2 |
| E7 Marketing | MKT/DESIGN | 23 | H2–H3 |
| E8 User acquisition | UA | 27 | H2–H3 |
| E9 Sales & monetisation | SALES/ENG | 24 | H3 |
| E10 Legal & compliance | LEGAL | 12 | H2–H3 |
| E11 Planning discipline | PM | 6.5 | ongoing |
| **Total** | | **231.5** | |

**By function:** ENG ~96 · QA ~45 · MKT ~23 · UA ~27 · SALES ~17 · OPS ~13 · DESIGN ~16 ·
LEGAL ~15 · PM ~9 *(approximate; some tasks span functions)*

**Predictions to grade later — this plan's own falsifiable calls:**

| # | Prediction | Confidence |
|---|---|---|
| P1 | Actual total exceeds 231.5 days | 85% |
| P2 | `discovery` is the largest single delay cause in E1 | 65% |
| P3 | ≥10 CRs raised before E4 starts | 70% |
| P4 | E1.5 (NL parsing) overruns its 4-day estimate | 75% |
| P5 | At least one epic is cut entirely before it starts | 60% |

Grading these at each phase boundary is the cheapest possible test of planning ability.

---

## 5. Sequencing

```
Now ──► E6 (tooling)  ──► E11.1 (freeze baseline)
          │
          ├─► E1 hands-free capture ──┐
          ├─► E3 retention mechanics ─┼─► E2 insight v2 ─► E5 QA hardening
          ├─► E10.1 privacy policy    ─┘
          └─► E7 marketing ─► E8 user acquisition
                                  │
                    E4.1 Path A/B decision ──► E4 social ──► E9 monetisation
```

**Critical path:** E6 → E1 → E2 → E5 → launch.
**The one true gate:** E4.1. Nothing in E4, E8.2, or E9 should start before Path A/B is decided.

---

## 6. Sync convention

- **Repo is the source of truth** for the plan and the baseline. Git history is the audit trail.
- **Jira is the execution board** — one issue per task ID, Function as label, baseline in a custom
  field.
- **Notion is the dashboard** — CR log, planning-accuracy metrics, and narrative retros.
- IDs (`E1.1`) are stable across all three. Never renumber; retire instead.
