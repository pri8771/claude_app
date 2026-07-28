# Plan Tracking — live status against Baseline v1.0

**This file is mutable. `POST_MVP_MASTER_PLAN.md` is not.**

Baseline estimates are copied here once and never changed. Record `Actual` and `Cause` as tasks
complete. If `Current` differs from `Base`, there must be a matching CR in
`CHANGE_REQUEST_LOG.md`.

**Status:** `—` not started · `WIP` in progress · `✓` done · `✂` cut · `⏸` blocked
**Cause:** required when Actual > Base. One of `change-request` · `underestimate` · `dependency` ·
`external-blocker` · `rework` · `discovery`

---

# ACTIVE — Baseline M1.0 (MVP → TestFlight)

*This is the current work. The E-series below does not start until this ships.*

## M1 — Quick capture MVP (Build 1)

| ID | Task | Fn | Base | Current | Actual | Status | Cause | Blocked by |
|---|---|---|---|---|---|---|---|---|
| M1.1 | Quick Capture sheet | ENG | 3 | 3 | | — | | *ready* |
| M1.2 | Entry point on Today | ENG | 1 | 1 | | — | | M1.1 |
| M1.3 | Short-horizon date chips | ENG | 1 | 1 | | — | | M1.1 |
| M1.4 | First-session short-horizon nudge | DESIGN | 1 | 1 | | — | | M1.3 |
| M1.5 | Clarity score reframe | DESIGN | 1 | 1 | | — | | *ready* |
| M1.6 | Resolve ritual card stack | ENG | 3 | 3 | | — | | *ready* |
| M1.7 | Overconfidence stat | ENG | 2 | 2 | | — | | *ready* |
| M1.8 | Gentle reveal copy pass | DESIGN | 1 | 1 | | — | | M1.6, M1.7 |
| M1.9 | MVP test coverage | QA | 3 | 3 | | — | | M1.1–M1.7 |
| M1.10 | Manual VoiceOver pass | QA | 2 | 2 | | — | | M1.1–M1.7 |

## T — TestFlight release track

| ID | Task | Fn | Base | Current | Actual | Status | Cause | Blocked by |
|---|---|---|---|---|---|---|---|---|
| T1 | Bundle ID + App Store Connect record | OPS | 0.5 | 0.5 | | ⏸ | | **user: account access** |
| T2 | Distribution cert + provisioning | OPS | 0.5 | 0.5 | | — | | T1 |
| T3 | Release config audit | ENG | 1 | 1 | | — | | *ready* |
| T4 | Privacy nutrition labels | LEGAL | 0.5 | 0.5 | | — | | T1 |
| T5 | Privacy policy — write + host | LEGAL | 1 | 1 | | — | | *ready* |
| T6 | First archive + upload + internal testers | OPS | 1 | 1 | | — | | T2, T3, T4 |
| T7 | TestFlight beta description + feedback email | MKT | 0.5 | 0.5 | | — | | T1 |
| T8 | External testing: Beta App Review | OPS | 0.5 | 0.5 | | — | | T5, T6 |

## V — Voice capture (Build 2, after Build 1 ships)

| ID | Task | Fn | Base | Current | Actual | Status | Cause | Blocked by |
|---|---|---|---|---|---|---|---|---|
| V1 | Speech + Foundation Models API spike | ENG | 2 | 2 | | — | | Build 1 ships |
| V2 | Record + on-device transcription | ENG | 3 | 3 | | — | | V1 |
| V3 | Parse utterance → draft | ENG | 4 | 4 | | — | | V1 |
| V4 | Confirmation / correction UI | ENG | 3 | 3 | | — | | V3 |
| V5 | Confidence follow-up | ENG | 2 | 2 | | — | | V3 |
| V6 | Non-Apple-Intelligence fallback | ENG | 2 | 2 | | — | | V3 |
| V7 | Voice test coverage | QA | 2 | 2 | | — | | V2–V6 |

---

# QUEUED — Baseline v1.0 (post-MVP)

*Does not start until Baseline M1.0 ships. Listed for reference.*

## E1 — Hands-free capture

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E1.1 | App Group entitlement + shared container | ENG | 1 | 1 | | — | | |
| E1.2 | Migrate store to App Group (backup-first) | ENG | 3 | 3 | | — | | |
| E1.3 | Migration regression tests | QA | 2 | 2 | | — | | |
| E1.4 | On-device NL parsing spike | ENG | 2 | 2 | | — | | |
| E1.5 | Parse utterance → Decision + Prediction | ENG | 4 | 4 | | — | | |
| E1.6 | Date phrase parsing + validation | ENG | 2 | 2 | | — | | |
| E1.7 | Parse confirmation / correction UI | ENG | 3 | 3 | | — | | |
| E1.8 | Fallback for non-Apple-Intelligence devices | ENG | 2 | 2 | | — | | |
| E1.9 | Siri App Intent + AppShortcutsProvider | ENG | 3 | 3 | | — | | |
| E1.10 | Confidence follow-up turn | ENG | 2 | 2 | | — | | |
| E1.11 | Widget: quick capture (mic) | ENG | 2 | 2 | | — | | |
| E1.12 | Widget: due for review | ENG | 2 | 2 | | — | | |
| E1.13 | Control Center + Action Button | ENG | 2 | 2 | | — | | |
| E1.14 | Widget/intent test coverage | QA | 3 | 3 | | — | | |

## E2 — Insight engine v2

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E2.1 | Domain-level calibration | ENG | 3 | 3 | | — | | |
| E2.2 | Overconfidence stat | ENG | 2 | 2 | | — | | |
| E2.3 | Short vs long horizon split | ENG | 2 | 2 | | — | | |
| E2.4 | Insight copy pass — gentle framing | DESIGN | 2 | 2 | | — | | |
| E2.5 | Year in Review generator | ENG | 5 | 5 | | — | | |
| E2.6 | Year in Review shareable card | DESIGN | 3 | 3 | | — | | |
| E2.7 | Insight test coverage + fixtures | QA | 3 | 3 | | — | | |

## E3 — Retention mechanics

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E3.1 | Resolution streaks | ENG | 2 | 2 | | — | | |
| E3.2 | Incomplete-entry tray | ENG | 3 | 3 | | — | | |
| E3.3 | Notification inline-reply capture | ENG | 3 | 3 | | — | | |
| E3.4 | Ambient weekly prompt | ENG | 2 | 2 | | — | | |
| E3.5 | Short-horizon nudge in capture | DESIGN | 1 | 1 | | — | | |
| E3.6 | Retention test coverage | QA | 2 | 2 | | — | | |

## E4 — Social foundation `GATED on E4.1`

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E4.1 | Path A/B decision memo | PM | 2 | 2 | | — | | |
| E4.2 | Identity model design | ENG | 3 | 3 | | — | | |
| E4.3 | Duel rendezvous service | ENG | 8 | 8 | | — | | |
| E4.4 | Duel create / accept / reveal UI | ENG | 5 | 5 | | — | | |
| E4.5 | Port Receipt cards from archive | ENG | 2 | 2 | | — | | |
| E4.6 | Second-opinion flow | ENG | 3 | 3 | | — | | |
| E4.7 | Anonymous aggregate benchmarks | ENG | 5 | 5 | | — | | |
| E4.8 | Backend test + load coverage | QA | 4 | 4 | | — | | |
| E4.9 | Abuse / moderation policy | LEGAL | 3 | 3 | | — | | |

## E5 — QA and release engineering

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E5.1 | CI: build + unit tests on PR | QA | 2 | 2 | | — | | |
| E5.2 | CI: UI test suite on merge | QA | 2 | 2 | | — | | |
| E5.3 | Device/OS test matrix | QA | 1 | 1 | | — | | |
| E5.4 | Manual VoiceOver audit | QA | 2 | 2 | | ✂ | | superseded by M1.10 (CR-001) |
| E5.5 | Dynamic Type + small-device sweep | QA | 2 | 2 | | — | | |
| E5.6 | TestFlight beta programme | QA | 3 | 3 | | — | | |
| E5.7 | Privacy-compatible crash reporting | QA | 3 | 3 | | — | | |
| E5.8 | Regression suite expansion | QA | 4 | 4 | | — | | |
| E5.9 | Performance benchmarks | QA | 2 | 2 | | — | | |
| E5.10 | Release checklist automation | QA | 2 | 2 | | — | | |

## E6 — Tooling and infrastructure

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E6.1 | Jira project HIND + workflow | OPS | 1 | 1 | | ⏸ | | deferred by user 2026-07-28 |
| E6.2 | Jira custom fields | OPS | 1 | 1 | | ⏸ | | deferred by user 2026-07-28 |
| E6.3 | Jira board views by Function | OPS | 1 | 1 | | ⏸ | | deferred by user 2026-07-28 |
| E6.4 | Notion planning hub | OPS | 2 | 2 | 0.5 | ✓ | | |
| E6.5 | Repo/Jira/Notion sync convention | PM | 1 | 1 | 0.25 | ✓ | | repo is system of record |
| E6.6 | Design tool setup (Figma) | DESIGN | 2 | 2 | | — | | |
| E6.7 | Analytics decision | OPS | 2 | 2 | | — | | |
| E6.8 | App Store Connect + distribution signing | OPS | 2 | 2 | | — | | |
| E6.9 | Support channel + SLA | OPS | 1 | 1 | | — | | |
| E6.10 | Secrets management for backend | OPS | 2 | 2 | | — | | |

## E7 — Marketing

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E7.1 | Finalise positioning | MKT | 2 | 2 | | — | | |
| E7.2 | ASO: title, subtitle, keywords | MKT | 2 | 2 | | — | | |
| E7.3 | App Store screenshots | DESIGN | 3 | 3 | | — | | |
| E7.4 | App Store preview video | DESIGN | 3 | 3 | | — | | |
| E7.5 | Landing page | MKT | 4 | 4 | | — | | |
| E7.6 | Press kit | MKT | 1 | 1 | | — | | |
| E7.7 | Content engine | MKT | 5 | 5 | | — | | |
| E7.8 | Launch plan | MKT | 2 | 2 | | — | | |
| E7.9 | Email list + capture | MKT | 1 | 1 | | — | | |

## E8 — User acquisition

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E8.1 | Privacy-compatible attribution | UA | 2 | 2 | | — | | |
| E8.2 | Referral / invite mechanic | UA | 4 | 4 | | — | | |
| E8.3 | Organic social channel test | UA | 4 | 4 | | — | | |
| E8.4 | Influencer / creator pilot | UA | 3 | 3 | | — | | |
| E8.5 | Paid acquisition test | UA | 3 | 3 | | — | | |
| E8.6 | Campus ambassador pilot | UA | 5 | 5 | | — | | |
| E8.7 | ASO experiment cycle | UA | 3 | 3 | | — | | |
| E8.8 | Retention cohort analysis | UA | 3 | 3 | | — | | |

## E9 — Sales and monetisation

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E9.1 | Pricing research | SALES | 3 | 3 | | — | | |
| E9.2 | Monetisation implementation (StoreKit) | ENG | 4 | 4 | | — | | |
| E9.3 | Paywall / upgrade UX | DESIGN | 3 | 3 | | — | | |
| E9.4 | B2B2C exploration | SALES | 5 | 5 | | — | | |
| E9.5 | Team / org licensing model | SALES | 3 | 3 | | — | | |
| E9.6 | Partnership outreach | SALES | 4 | 4 | | — | | |
| E9.7 | Revenue reporting + unit economics | SALES | 2 | 2 | | — | | |

## E10 — Legal and compliance

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E10.1 | Privacy policy | LEGAL | 2 | 2 | | — | | |
| E10.2 | Terms of service | LEGAL | 2 | 2 | | — | | |
| E10.3 | App Store privacy nutrition labels | LEGAL | 1 | 1 | | — | | |
| E10.4 | GDPR / CCPA readiness (if Path B) | LEGAL | 4 | 4 | | — | | |
| E10.5 | Age rating review | LEGAL | 1 | 1 | | — | | |
| E10.6 | Privacy claim audit | LEGAL | 2 | 2 | | — | | |

## E11 — Planning discipline

| ID | Task | Fn | Base | Current | Actual | Status | Cause | CR |
|---|---|---|---|---|---|---|---|---|
| E11.1 | Freeze baseline snapshot | PM | 0.5 | 0.5 | 0.5 | ✓ | | tag `baseline-v1.0` |
| E11.2 | CR log + template | PM | 1 | 1 | 0.5 | ✓ | | |
| E11.3 | Delay attribution recording process | PM | 1 | 1 | 0.25 | ✓ | | this file |
| E11.4 | Phase-boundary review cadence | PM | 1 | 1 | | — | | |
| E11.5 | Planning accuracy dashboard | PM | 2 | 2 | | — | | |
| E11.6 | Retro template + first retro after E1 | PM | 1 | 1 | | — | | |

---

## Running totals

| Track | Tasks | Base | Actual | Ratio |
|---|---|---|---|---|
| **ACTIVE — M1.0 to TestFlight** | 18 | **23.5** | 0 | — |
| M1.0 voice (Build 2) | 7 | 18.0 | 0 | — |
| QUEUED — v1.0 post-MVP | 92 | 231.5 | 2.0 | — |
| Completed so far (5, all PM/OPS setup) | 5 | 5.5 | 2.0 | 0.36 |

*The 0.36 ratio is not a real signal — the five completed tasks are all PM/OPS setup done inside
one session, which is the least representative work in the plan. Expect this number to move sharply
once engineering starts.*

## Delay attribution to date

| Cause | Days | % of slip |
|---|---|---|
| *(no slip recorded yet)* | 0 | — |

## Phase-boundary review log

*(first review due at the end of E1)*

At each review, record: estimate ratio for the phase, delay attribution breakdown, CR count,
grades on the baseline's five self-predictions (P1–P5), and one concrete change to how the next
phase is estimated.
