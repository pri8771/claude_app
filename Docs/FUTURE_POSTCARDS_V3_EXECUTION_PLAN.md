# Future Postcards v3 — Execution Plan

**Status:** active planning baseline.  This is an execution plan, not evidence that a design
prototype has been exported locally.  The Claude Design URL supplied during planning is a review
reference only; implementation must use approved exported frames/specifications when available.

**Authority order:** `AGENTS.md`, App Factory standards, `quality/quality-manifest.json`,
`SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md`, `SOCIAL_V2_EXECUTION_TRACKER.md`, the named feature
contracts, then this plan.  Build 1 remains a separate local release candidate governed by
`build1-testflight.json`; Social v2 remains gated by `social-v2-foundation.json`.

## 1. Operating rules, gates, and status

### Non-negotiable rules

- Preserve the existing private SwiftData journal.  Never silently upload it, or mix samples into
  real analytics, exports, notifications, relationships, or scores.
- A local personal save may confirm after local persistence; a social lock, membership change,
  resolution, score, or scheduled delivery may confirm only after authoritative server success.
- Show loading, empty, error, cancellation, offline, retry, accessibility, and recovery states.
  Retain drafts and prevent duplicate consequential operations.
- Do not add a backend provider SDK, hosted credentials, or social UI before the Social v2 gates
  permit it.  No task may claim completion without its specified evidence.

### Gate map

| Gate | Required before | Current planning treatment |
|---|---|---|
| Build 1/TestFlight | changes touching current local release behavior | Preserve its `verification_pending` physical/release evidence; do not re-label it done. |
| F0.1 product ratification and F0.2 approved design/research | any v3 experience promoted beyond the isolated local slice | inherited review/approval work; no prototype export is asserted here. |
| F0.3 architecture/hosted integrity proof | **all backend, account, sync, notification, and social work** | queued behind accepted ADR/proof. |
| F0.4 domain/API contracts | server/client social models and integrations | queued behind F0.3. |
| F0.5 privacy, safety, identity, legal policy | identity, sharing, friend/Circle/public behavior | queued behind F0.3/F0.4/F0.5 acceptance. |
| F0.6 migration/offline recovery and F0.7 environments/CI/rollback | any QA or beta social rollout | queued until their named evidence passes. |

### Execution status

Only **P1.CORE.1 — personal postcard vertical slice** is `in_progress`.  It is local-only and
must preserve Build 1 behavior.  Every other task in this document is `queued`, unless the
Social v2 tracker explicitly records inherited foundation evidence as `review_required` or
`code_complete`.  In particular, all social/backend tasks remain queued behind F0.3/F0.4/F0.5.

## 2. Reusable task contract

Each task below inherits this compact contract, plus its task-specific definition.

- **Summary / user story:** deliver the stated outcome for the named user.
- **Why / what:** solve the stated problem, including only stated scope; defer unlisted behavior.
- **How:** use production data boundaries, explicit state transitions, dependency injection, and
  test fixtures outside production bundles.  Write tests before or with behavior.
- **Expected result:** observable behavior described in the task.
- **Acceptance:** all stated requirements hold in success and failure states; no prohibited
  behavior occurs.
- **Evidence:** focused unit/integration/UI tests, relevant device/accessibility capture, and an
  updated contract/tracker/evidence record as applicable.  Run the repository-required unit,
  integration, and UI-smoke suites before promotion.
- **Rollback:** feature-flag/route-disable new work where applicable; preserve drafts and source
  data; use versioned migrations and idempotent retries; never delete real data to undo a rollout.

Subtasks are independently verifiable implementation packets.  A worker may change only the files
named by its refined packet and reports files changed, tests, manual checks outstanding, risks, and
truthful lifecycle status (`code_complete` or `verification_pending`, not `done`).

## 3. Phase 0 — Design freeze and engineering handoff

**Objective:** turn the approved direction into a buildable, testable native specification.
**Dependencies:** Build 1 baseline, F0.1/F0.2 review.  **Exit:** approved artifacts and traceable
states; not merely a clickable design.

### Epic 0.1 — Approved design baseline

| Task | Summary, user story, why/what/how, expected result | Subtasks | Dependencies / acceptance / evidence |
|---|---|---|---|
| 0.1.1 Freeze v3 | As an implementer, I need one baseline so competing versions do not drift. Record the approved v3 reference, decisions, rejected alternatives, and change-control owner; preserve prior versions. Result: a stable source of truth without claiming a local Claude export. | Identify authoritative reference; record decisions; record conflicts; define approval/change log. | F0.1/F0.2 review. Acceptance: every disputed behavior has an owner/status. Evidence: decision log and review sign-off. |
| 0.1.2 Screen inventory | As design/QA, I need every reachable state cataloged. Map tabs, screens, sheets, dialogs, empty/loading/error/retry/sample states, entry/exit/back/deep-link behavior. Result: no implicit screen work. | Root destinations; details; transient UI; state variants; route map. | 0.1.1. Acceptance: each inventory row links to a task/contract and test state. Evidence: inventory and route review. |
| 0.1.3 Workflow inventory | As a user, I need interruptions handled predictably. Specify first launch, capture, return, resolution, insights, samples, friends/Circles/messages and exceptional paths. | Happy paths; cancellation; offline/failure; resumption; authority boundaries. | 0.1.2. Acceptance: each mutation has recovery and ownership. Evidence: state-machine review. |

### Epic 0.2 — Native design system

| Task | Summary, user story, why/what/how, expected result | Subtasks | Dependencies / acceptance / evidence |
|---|---|---|---|
| 0.2.1 Visual tokens | As a user, I need a consistent accessible postcard language. Define semantic color/type/spacing/radius/material/elevation/paper/stamp tokens with dark/high-contrast variants. | Colors; typography; geometry; postcard treatment; state variants. | 0.1. Acceptance: tokens scale at largest type and never encode meaning by color only. Evidence: token catalog and contrast audit. |
| 0.2.2 Components | As an engineer, I need reusable primitives rather than copied screens. Define postcard, confidence, date, button, sample, insight, state, social-row, confirmation and tab components. | APIs; variants; previews; accessibility labels; loading/error forms. | 0.2.1. Acceptance: inventory components cover 0.1.2 states. Evidence: preview/design review. |
| 0.2.3 Motion/feedback | As a user, I need sealing/opening feedback that remains understandable without motion. Specify transitions, haptics, timing, cancellation and reduced-motion alternatives. | Seal; open; navigation; loading/success; static alternatives. | 0.2.2. Acceptance: animation never blocks action and has equivalent static state. Evidence: motion spec/device review. |

### Epic 0.3 — Implementation contracts

| Task | Summary, user story, why/what/how, expected result | Subtasks | Dependencies / acceptance / evidence |
|---|---|---|---|
| 0.3.1 Feature contracts | As a worker, I need explicit inputs, persistence, privacy, accessibility and tests. Create/extend contracts for each vertical slice. | Inputs/outputs; invalid states; authority; acceptance; test links. | 0.1–0.2. Acceptance: no task begins without a relevant contract. Evidence: versioned contract review. |
| 0.3.2 State machines | As a user, I need durable lifecycle behavior. Specify prediction, message, friendship, Circle, sample, onboarding and sync transitions with actors/preconditions/retries. | Transition tables; negative transitions; side effects; idempotency. | 0.3.1; social machines additionally F0.4. Acceptance: all mutations have authorization/retry semantics. Evidence: fixtures/negative tests. |
| 0.3.3 Traceability | As QA, I need every requirement testable. Link screens to contracts, criteria to tests, prototype-only exclusions, decisions and sequencing. | Trace map; unresolved log; dependency graph; test plan. | 0.3.1–0.3.2. Acceptance: no orphan requirement. Evidence: traceability review. |

## 4. Phase 1 — Native personal core

**Objective:** a user can privately create, revisit, resolve, and learn from a postcard offline.
**Status:** only P1.CORE.1 is in progress.  **Exit:** reliable local personal loop with migration
integrity, accessibility, and content-free instrumentation.

### Epic 1.1 — Application shell and navigation

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| **P1.CORE.1 `in_progress` — Local postcard vertical slice** | **Story:** as a private user, I can write a prediction, explicitly set confidence/return date, seal it locally, find it in Now, and start resolution. **Why/what/how:** establish the smallest v3 loop using SwiftUI/SwiftData, existing recovery conventions, no account/network code, and draft/save state machine. **Result:** one offline end-to-end slice without regressing Build 1. **Subtasks:** (a) define local `PostcardDraft` validation; (b) implement composer with explicit confidence/date and retained draft; (c) atomically persist/seal with duplicate protection; (d) show in Now and open detail; (e) start unselected resolution. | Build 1 contract and 0.2/0.3. Acceptance: blank/invalid data rejected, save failure retains draft/no success, no implicit confidence, relaunch preserves data, VoiceOver/Dynamic Type/dark mode work. Evidence: unit persistence/validation, UI smoke on small + 16 Pro Max, manual recovery capture. Rollback: route behind local v3 gate; records remain readable by migration adapter. |
| 1.1.1 Root shell | As a returning user, I need stable Now/Hindsight/Capture/Insights/Circles navigation. Implement state restoration, routes, modal/sheet handling and stale-route cleanup. **Subtasks:** app entry/dependencies; tab states; coordinator; deep-link hooks. | 0.2/0.3, after P1.CORE.1. Acceptance: each tab preserves state and removed record cannot leave a dead route. Evidence: navigation/relaunch UI tests. |
| 1.1.2 Accessibility navigation | Ensure labels, selected states, focus order, 44-point targets and reduced-motion behavior. **Subtasks:** semantics; focus; keyboard; audit. | 1.1.1. Evidence: VoiceOver and XXXL device capture. |

### Epic 1.2 — Personal prediction data and migration

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 1.2.1 Model/lifecycle | As a user, I need original beliefs preserved. Add identifiers, text/reasoning, 0–100 confidence, dates, category, source/sample identity, outcome/reflection and lifecycle rules. **Subtasks:** schema; sealed immutability; due logic; repository protocol; test fixtures. | 0.3. Acceptance: no rewriting sealed text/confidence; local transactions validate integrity. Evidence: lifecycle tests. |
| 1.2.2 Existing-data migration | As an existing user, I keep all journal history. Map legacy fields, version migrations, preserve dates/outcomes/notes, and support interruption/retry. **Subtasks:** audit map; migration stages; failure reporting; fixture stores; reconciliation. | Build 1 contract, 1.2.1. Acceptance: zero loss in fixtures, rollback/downgrade behavior documented. Evidence: migration/relaunch tests and counts. |

### Epic 1.3 — Capture, Now, resolution, history

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 1.3.1 Quick capture | As a user, I record a future postcard in one screen. Implement text, explicit confidence, optional why, date presets/custom date, validation, cancel/draft and seal feedback. **Subtasks:** fields; validation focus; atomic save; friction instrumentation. | 1.2.1. Acceptance: keyboard safe, duplicate-safe, recovery honest. Evidence: capture UI/unit tests. |
| 1.3.2 Now mailbox | As a user, I see due/upcoming/recent postcards and clear empty/error states. **Subtasks:** queries/sections; active detail; timezone-aware due updates; optional local reminders excluding samples. | 1.2.1, 1.3.1. Evidence: query/timezone/reminder tests. |
| 1.3.3 Resolution/reflection | As a user, I compare what I thought to what happened. Implement correct/incorrect/partial/cancelled/unresolvable, reflection, atomic persistence and reminder cleanup. **Subtasks:** outcome UI; immutable before/after; transaction; retry. | 1.3.2. Acceptance: no preselected outcome; failed save retains reflection. Evidence: resolution tests. |
| 1.3.4 Hindsight archive | As a user, I search/filter resolved learning. **Subtasks:** chronological list; resolved detail; outcome/confidence/category/date/horizon/reason filters; clear-all. | 1.3.3. Evidence: filter/query UI tests and empty states. |
| 1.3.5 Content-free instrumentation | As product, we measure friction without reading journals. **Subtasks:** event registry; privacy allowlist; payload tests; retention docs. | 1.3.1–1.3.4, F0.5 policy for any network transport. Acceptance: text/reason/reflection never emitted. Evidence: deterministic payload tests. |

## 5. Phase 2 — Personal analytics and Wrapped

**Objective:** correct, understandable, sample-safe learning.  **Status:** queued.

### Epic 2.1 — Analytics engine

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 2.1.1 Eligibility and metrics | As a user, I receive honest statistics. Include only valid resolved personal records; exclude samples/cancelled/unresolved; calculate accuracy, confidence, calibration gap, Brier, partial outcomes and streaks. **Subtasks:** eligibility predicates; formula vectors; sample gates; tests. | 1.3.3. Acceptance: deterministic formulas and denominators. Evidence: unit golden vectors. |
| 2.1.2 Insight generator | As a user, I get observations rather than opaque charts. Generate confidence, category, timeframe, behavioral and personal-record insights. **Subtasks:** buckets; category/time analysis; reasoning comparison; records; sparse-state copy. | 2.1.1. Acceptance: no causal claim or low-sample ranking. Evidence: fixtures and claim tests. |

### Epic 2.2 — Insights UX and Wrapped

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 2.2.1 Insights tab/drill-down | Dashboard, filters and method explanations make claims inspectable. **Subtasks:** summary/cards; charts/tables; detail filters; accessible chart descriptions; insufficient-data state. | 2.1. Acceptance: count/explanation accompanies every claim. Evidence: UI/accessibility tests. |
| 2.2.2 Monthly/annual Wrapped | Produce fun but private-safe reports. **Subtasks:** period aggregation; story cards; no/sparse state; prior-period compare; share preview/redaction. | 2.1–2.2.1. Acceptance: sharing excludes text by default and cancels safely. Evidence: golden report/share tests. |

## 6. Phase 3 — Guided start and sample mode

**Objective:** demonstrate value without contaminating real data.  **Status:** queued.

### Epic 3.1 — Tour and sample fixture system

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 3.1.1 Introductory tour | As a new user, I understand write → confidence → return and can skip/resume. **Subtasks:** first-launch states; three-part story; guided production capture; post-tour personal/sample choice; replay. | 0.2, 1.3.1. Acceptance: interruption preserves input; choice is explicit. Evidence: onboarding UI/relaunch tests. |
| 3.1.2 Deterministic samples | As an explorer, I can safely inspect postcards, insights and later-social examples. **Subtasks:** stable IDs/flags; active/due/resolved fixtures; versioning; idempotent load; no production bundle leakage. | 1.2, 2.1. Acceptance: sample identity is explicit and deterministic. Evidence: fixture tests. |
| 3.1.3 Isolation/presentation | Samples never affect real statistics or operations and are honestly labeled. **Subtasks:** analytic/export/reminder/network exclusion; one marker per surface; banner; sample explanations. | 3.1.2. Acceptance: no real-to-sample references. Evidence: isolation/privacy tests. |

### Epic 3.2 — Removal and replay

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 3.2.1 Safe sample removal | As a user, I remove samples without touching my history. **Subtasks:** count/breakdown dialog; transactional tagged deletion; stale-route cleanup; retry; bounded undo; settings/banner entry points. | 3.1.2–3.1.3. Acceptance: repeated removal is a no-op; real objects survive. Evidence: mixed-data removal and failure tests. |

## 7. Phase 4 — Accounts, backend, privacy, and sync

**Objective:** secure network foundation.  **Status:** all tasks queued behind F0.3/F0.4/F0.5
(and F0.6/F0.7 before rollout).

### Epic 4.1 — Foundation-gate completion (inherited Social v2 work)

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| F0.1 Product contract | Ratify actors, scope/non-goals, funnel/guardrails and research evidence. **Subtasks:** actors; metrics; scope. | Inherited tracker; acceptance/evidence exactly as Social v2 plan. |
| F0.2 Design validation | Approve premium IA/tokens/prototype and five uncoached sessions. **Subtasks:** IA; components; prototype test. | F0.1. No local export claimed. |
| F0.3 Architecture proof | Select backend only after hosted Apple-auth, RLS/realtime/APNs, isolation, load and restore proof. **Subtasks:** weighted matrix; integrity spike; ADR/operations. | F0.1. Local parity proof is not hosted acceptance. |
| F0.4 Domain/API | Finalize entity ownership, state machines, versioned OpenAPI/contracts and negative fixtures. **Subtasks:** model; transitions; schemas. | F0.3. |
| F0.5 Privacy/safety/legal | Finalize visibility/data classification, abuse/identity safeguards and approved legal/store disclosure. **Subtasks:** matrix; safeguards; policy. | F0.1/F0.3/F0.4. |
| F0.6 Migration/offline | Specify consent, outbox/conflicts, fixtures/migration/rollback. **Subtasks:** inventory; sync states; recovery tests. | F0.3–F0.5. |
| F0.7 Environments/ops | Isolated dev/QA/prod, CI, observability, flags and rollback game day. **Subtasks:** provision; gates; drills. | F0.3–F0.6. |

### Epic 4.2 — Network implementation (queued)

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 4.2.1 Accounts/profiles | Sign in with Apple, secure credentials, profile/privacy and export/deletion lifecycle. **Subtasks:** auth; profile; logout/revoke/delete. | F0.3/F0.4/F0.5. Acceptance: account boundaries/credential errors recover safely. Evidence: auth/security tests. |
| 4.2.2 Server/API authorization | Implement versioned entities/APIs and ownership, role, visibility and block enforcement. **Subtasks:** schema; endpoints; authorization; audit/idempotency. | F0.3/F0.4/F0.5. Evidence: negative authorization/contract tests. |
| 4.2.3 Local-first sync | Cache/outbox, retry/dedupe, conflict rules and offline states without false locks. **Subtasks:** sync engine; conflict resolution; queue UI. | F0.4/F0.6/F0.7. Evidence: offline/replay/cross-account tests. |
| 4.2.4 Notifications/operations | Preference-aware push, content-free observability and environment controls. **Subtasks:** token/preference; deep links; dashboards/alerts; flags. | F0.3–F0.7. Evidence: physical push and scrubbed-payload tests. |

## 8. Phase 5 — Friends, Circles, shared predictions, messages

**Objective:** private social value without betting-market behavior.  **Status:** queued behind
F0.3/F0.4/F0.5 and Phase 4.

### Epic 5.1 — Friends and Circles

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 5.1.1 Friends | Privacy-preserving search/invite, relationship lifecycle, profiles and blocks. **Subtasks:** invite/deep link; request states; management; permitted stats. | 4.2. Acceptance: enumeration/race/block tests pass. |
| 5.1.2 Circles | Create/manage private groups and roles. **Subtasks:** create/join/leave/archive; owner/mod/member; Circle home. | 5.1.1, 4.2. Acceptance: role/membership isolation. Evidence: server + two-account tests. |

### Epic 5.2 — Shared questions and fair scoring

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 5.2.1 Shared lists/questions | Members create prompts with defined outcomes, deadline, visibility and resolver authority. **Subtasks:** common list; contribution rules; question creation; vote submission/private reveal. | 5.1.2, F0.4. Acceptance: server UTC lock and hidden-vote policy enforced. |
| 5.2.2 Resolution/disputes | Outcome proposal, challenge/evidence, moderation decision and correction ledger. **Subtasks:** propose; challenge; audit; recompute. | 5.2.1/F0.5. Evidence: authorization/correction tests. |
| 5.2.3 Scoring/standings | Calibration-aware, sample-gated scores and Circle insights. **Subtasks:** formula; ranking filters; consensus/contrarian insights; explanations. | 5.2.2. Acceptance: immutable score ledger, no raw-win-only ranking. Evidence: golden vectors. |

### Epic 5.3 — Scheduled future messages and safety

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 5.3.1 Scheduled messages | A real friend can receive a message at unlock time. **Subtasks:** compose/preview/schedule; pending edit/cancel; delivery/open/archive. | 5.1.1, 4.2.4, F0.5. Acceptance: no delivery after applicable block/removal/deletion. Evidence: time/idempotency/device tests. |
| 5.3.2 Social sharing/moderation | Privacy-preview shares plus report/block/review/appeal operations. **Subtasks:** receipt/invite sharing; report queues; enforcement/audit. | F0.5, 5.1–5.3.1. Evidence: redaction/abuse fixtures. |

## 9. Phase 6 — Public events and viral growth

**Objective:** controlled discovery only after private loops and safety operate.  **Status:** queued
behind Phase 5, F0.3/F0.4/F0.5 and public safety/operations approval.

### Epic 6.1 — Curated events and public identity

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 6.1.1 Curated event lifecycle | Administer objective questions, deadlines/geography, sources, publish/close and correction. **Subtasks:** authoring; participation; evidence-backed resolution. | Phase 5, F0.4/F0.5. Acceptance: two-person publishing and appeal paths. |
| 6.1.2 Public profiles/boards | Opt-in profiles and global/local/event/category standings with thresholds and anti-cheat. **Subtasks:** visibility preview; boards; integrity detection/appeals. | 6.1.1. Evidence: privacy, ranking, abuse tests. |

### Epic 6.2 — Acquisition and experimentation

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 6.2.1 Receipts/referrals | Share sealed/redacted receipts with continuation attribution. **Subtasks:** receipt generation; referral lifecycle; abuse prevention. | 6.1. Acceptance: no private content/token leakage. |
| 6.2.2 Lightweight entry | Evaluate App Clip/web preview without bypassing authority. **Subtasks:** choose workflow; preview; full-app handoff; measure conversion. | 6.2.1, legal review. |
| 6.2.3 Experiments/health | Feature flags and content-free measures for tour, samples, capture, insight, sharing and invitation changes. **Subtasks:** assignment; metric definitions; kill switch; analysis. | F0.7. Evidence: exposure/privacy tests and go/no-go report. |

## 10. Phase 7 — Production/TestFlight readiness

**Objective:** a safely testable release candidate.  **Status:** queued; Build 1’s separate
verification-pending release work remains preserved.

### Epic 7.1 — Automated and device quality

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 7.1.1 Automated suites | Run unit, integration and UI critical flows: models, migration, isolation, analytics, auth, sync, notifications and social paths. **Subtasks:** unit; integration; UI smoke; regression triage. | All implemented scope. Acceptance: required suites green without skips. Evidence: immutable logs/results. |
| 7.1.2 Accessibility/device coverage | Verify VoiceOver, Dynamic Type, contrast, Reduce Motion, device sizes/locales/timezones/low connectivity. **Subtasks:** audit; simulator matrix; physical-device matrix. | 7.1.1. Evidence: recordings/checklists, iPhone 16 Pro Max included. |
| 7.1.3 Reliability/performance | Profile launch/scroll/charts/memory/battery/network and simulate offline, interruption, server outage and duplicate requests. **Subtasks:** benchmarks; chaos/recovery; remediate blockers. | 7.1.1. Evidence: baselines and incident results. |

### Epic 7.2 — Compliance, release, beta

| Task | Definition and subtasks | Dependencies / acceptance / evidence |
|---|---|---|
| 7.2.1 Privacy/security review | Reconcile inventory, permissions, retention/export/delete, threat model, authorization and dependencies. **Subtasks:** privacy audit; security test; policy/store mapping. | F0.5 and all implemented scope. Evidence: signed owner reviews and test output. |
| 7.2.2 Release operations | Configure signing/environments, store assets/disclosures/support, archive/upload/tester groups and monitoring/rollback. **Subtasks:** builds; metadata; candidate; dashboards. | F0.7 and 7.1/7.2.1. Acceptance: release artifact validates and rollback is rehearsed. |
| 7.2.3 Beta and production decision | Run internal then controlled external beta; triage crashes, feedback, privacy/safety reports; approve only with evidence. **Subtasks:** internal cohort; external rollout; go/no-go review. | 7.2.2. Evidence: cohort results, blocker closure, approval record. |

## 11. Immediate execution packet

**Active work:** P1.CORE.1 only.  First refine it against `build1-testflight.json` and the Phase
0 component/contract artifacts; implement no social routes, accounts, sync, network telemetry, or
backend dependencies.  Before any later task is marked `in_progress`, verify its dependency gate
in `SOCIAL_V2_EXECUTION_TRACKER.md` and attach the required evidence path.

**Promotion checklist:** update this plan’s tracker reference/feature contract as scope changes;
run required unit, integration and UI-smoke tests; add manual device/accessibility evidence where
required; document rollback; report `code_complete` or `verification_pending` until all evidence
exists.
