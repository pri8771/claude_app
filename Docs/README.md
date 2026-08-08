# Docs index

**The repo is the source of truth.** Notion mirrors it; Jira will be populated later. Where they
disagree, the repo wins.

Last reviewed: 2026-07-30

---

## Start here

| Doc | What it answers |
|---|---|
| **[STATUS.md](STATUS.md)** | Where are we right now? Blockers, next action. |
| **[PLAN_TRACKING.md](PLAN_TRACKING.md)** | What are the current tasks and their status? *(mutable — live)* |
| **[MVP_PLAN.md](MVP_PLAN.md)** | How do we get to TestFlight? *(Baseline M1.0 — immutable)* |
| **[CHANGE_REQUEST_LOG.md](CHANGE_REQUEST_LOG.md)** | What changed, why, and what did it cost? |
| **[SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md](SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md)** | How do we build the approved networked social product? |
| **[SOCIAL_V2_EXECUTION_TRACKER.md](SOCIAL_V2_EXECUTION_TRACKER.md)** | What Social v2 work is active, gated, or queued? |
| **[CLAUDE_DESIGN_PROMPT.md](CLAUDE_DESIGN_PROMPT.md)** | What exactly should Claude Design produce? |
| **[MARKETING_LANDING_PAGE_TASKS.md](MARKETING_LANDING_PAGE_TASKS.md)** | How do we design and publish the Build 1 landing page, icon, screenshots, and waitlist? |

## Planning and strategy — authoritative

| Doc | Scope | Mutable? |
|---|---|---|
| [MVP_PLAN.md](MVP_PLAN.md) | MVP → TestFlight. 25 tasks, 41.5 days. Tag `baseline-m1.0` | **No** |
| [POST_MVP_MASTER_PLAN.md](POST_MVP_MASTER_PLAN.md) | Post-MVP H2–H4. 92 tasks, 231.5 days. Tag `baseline-v1.0` | **No** |
| [PLAN_TRACKING.md](PLAN_TRACKING.md) | Live status, actuals, delay causes for both baselines | Yes |
| [CHANGE_REQUEST_LOG.md](CHANGE_REQUEST_LOG.md) | Every deviation from a baseline | Yes |
| [LONG_TERM_PLAN.md](LONG_TERM_PLAN.md) | Product spine, horizons, the local-vs-social fork, ICP | Yes |
| [PRODUCT_BRAINSTORM.md](PRODUCT_BRAINSTORM.md) | Friction, gamification, social; MVP rationale | Yes |
| [SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md](SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md) | Approved social direction: 41 implementation-ready foundation/product tasks across four phases | Yes, until frozen as a baseline |
| [SOCIAL_V2_EXECUTION_TRACKER.md](SOCIAL_V2_EXECUTION_TRACKER.md) | Live dependency/evidence state for all 41 Social v2 tasks | Yes |
| [SOCIAL_V2_PRODUCT_CONTRACT.md](SOCIAL_V2_PRODUCT_CONTRACT.md) | F0.1 private-group MVP actors, loop, metrics, thresholds, research and open decisions | Yes, until approved |
| [SOCIAL_V2_BACKEND_EVALUATION.md](SOCIAL_V2_BACKEND_EVALUATION.md) · [ADR-008-SOCIAL-BACKEND.md](ADR-008-SOCIAL-BACKEND.md) | F0.3 current provider evidence and conditional architecture decision | Yes, until spike acceptance |
| [SOCIAL_V2_DOMAIN_API_CONTRACT.md](SOCIAL_V2_DOMAIN_API_CONTRACT.md) | F0.4 entities, state machines, authorization, errors and realtime reconciliation | Yes, until accepted |
| [SOCIAL_V2_PRIVACY_SAFETY_POLICY.md](SOCIAL_V2_PRIVACY_SAFETY_POLICY.md) · [SOCIAL_V2_LEGAL_STORE_CHECKLIST.md](SOCIAL_V2_LEGAL_STORE_CHECKLIST.md) | F0.5 draft trust policy and release approvals | Yes, until qualified review |
| [SOCIAL_V2_MIGRATION_SYNC_PLAN.md](SOCIAL_V2_MIGRATION_SYNC_PLAN.md) | F0.6 explicit-consent migration, offline/outbox, recovery and fixture-test contract | Yes, until accepted |
| [SOCIAL_V2_DELIVERY_RUNBOOK.md](SOCIAL_V2_DELIVERY_RUNBOOK.md) | F0.7 environment isolation, CI, secrets, promotion, telemetry and rollback controls | Yes, until provider provisioning |

**The measurement rule:** baseline estimates are never edited. Divergence goes in the CR log with a
delay cause. A plan that gets quietly rewritten teaches nothing.

## Engineering reference — current

| Doc | Scope |
|---|---|
| [ARCHITECTURE.md](ARCHITECTURE.md) | SwiftUI/SwiftData structure |
| [../Contracts/README.md](../Contracts/README.md) | Social v1 API contract entry point and validation limits |
| [FEATURES.md](FEATURES.md) | Feature inventory |
| [TEST_PLAN.md](TEST_PLAN.md) · [BUGS.md](BUGS.md) · [RISKS.md](RISKS.md) | Quality |
| [DECISIONS.md](DECISIONS.md) · [ASSUMPTIONS.md](ASSUMPTIONS.md) | Rationale |
| [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) · [LOCAL_DEVICE_TESTING.md](LOCAL_DEVICE_TESTING.md) | Release |
| [PROJECT_DOCUMENTATION.md](PROJECT_DOCUMENTATION.md) · [HANDOFF.md](HANDOFF.md) | Overview |
| [AppIconAndLaunchScreen.md](AppIconAndLaunchScreen.md) | Assets |
| [MARKETING_LANDING_PAGE_TASKS.md](MARKETING_LANDING_PAGE_TASKS.md) | Build 1 public landing page and waitlist; explicitly excludes Social v2 claims |

## Tooling — parked

Jira setup is **deferred** (decision 2026-07-29). These are ready when you return to it; the
custom fields and both projects already exist.

| Doc | Scope |
|---|---|
| [JIRA_SETUP.md](JIRA_SETUP.md) | Field schema spec + discovered field IDs |
| [JIRA_SETUP_PROMPT.md](JIRA_SETUP_PROMPT.md) | Claude-in-Chrome prompt — projects + fields *(done)* |
| [JIRA_FIX_PROMPT.md](JIRA_FIX_PROMPT.md) | Claude-in-Chrome prompt — unblock issue creation *(not run)* |

---

## ⚠️ Historical — superseded, do not follow

These describe the **reverted** Call / Timestamped Receipt / Brier pivot. Kept for the reasoning,
not as instructions. The code is on `archive/call-pivot-complete`.

| Doc | Why superseded |
|---|---|
| [IMPLEMENTATION_TASKS.md](IMPLEMENTATION_TASKS.md) | The 22-task pivot plan. Reverted — CR-000a |
| [CODEX_CRITIQUE_INTERCHANGE.md](CODEX_CRITIQUE_INTERCHANGE.md) | Debate that produced the pivot |
| [CLAUDE_CRITIQUE_FULL.md](CLAUDE_CRITIQUE_FULL.md) · [CLAUDE_PRODUCT_BRIEF.md](CLAUDE_PRODUCT_BRIEF.md) | Pre-pivot critique |
| [PRODUCT_PLAN.md](PRODUCT_PLAN.md) | Pivot-era product direction. Superseded by `LONG_TERM_PLAN.md` |
| [SIRI_WIDGETS_VOICE_PLAN.md](SIRI_WIDGETS_VOICE_PLAN.md) | Superseded by `MVP_PLAN.md` + `POST_MVP_MASTER_PLAN.md` |
| `pairs/*.md` | Pivot-era specialist specs. `PAIR_MARKETING.md` still holds usable App Store copy |

**Still worth reading from the archive:** `PAIR_MARKETING.md` (App Store copy, mostly reusable) and
the receipt-sharing implementation on the archive branch (`E4.5` plans to port it).

---

## Git reference

| Ref | What |
|---|---|
| `dev` | Current work |
| `qa` | Last promoted verified baseline; intentionally does not receive incomplete F0 work |
| `archive/call-pivot-complete` | The reverted pivot, fully working, 228 tests |
| `baseline-m1.0` | MVP plan frozen 2026-07-28 |
| `baseline-v1.0` | Post-MVP plan frozen 2026-07-28 |
