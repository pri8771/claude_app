# Hindsight Social v2 — Execution Tracker

**Status:** active foundation execution
**Branch:** `dev`
**Canonical task detail:** `SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md`
**Rule:** this file tracks sequencing and evidence; it does not replace or shorten the Summary,
User story, Why, What, How, Expected result, Subtasks, acceptance, and rollback contract attached
to every task in the master plan.

## 1. Status meanings

| Status | Meaning |
|---|---|
| `queued` | The detailed task exists, but an entry dependency is not yet satisfied. |
| `in_progress` | A bounded deliverable is being produced; acceptance is incomplete. |
| `review_required` | Draft artifacts exist and require the named owner, spike, or human evidence. |
| `code_complete` | Implementation and automated checks exist; external/manual evidence remains. |
| `verification_pending` | A candidate is in QA, but at least one required gate is incomplete. |
| `done` | All task acceptance, evidence, environment, accessibility, security, and promotion requirements exist. |
| `blocked` | Work cannot safely advance without an external decision, credential, account, or approval. |

No worker may translate `draft exists` into `done`. Social v2 production code must not begin until
its governing product, design, backend, privacy, domain, and migration contracts are accepted.

## 2. Execution model

Work is dispatched in dependency-safe waves:

1. **F0-A — Product, design, and architecture:** F0.1–F0.3 produce the product contract, Claude
   Design/Figma handoff, backend comparison, conditional ADR, and synthetic spike specification.
2. **F0-B — Trust and data contracts:** F0.4–F0.6 produce the versioned domain/API contract,
   privacy/safety/legal package, and migration/offline recovery plan.
3. **F0-C — Proof and delivery system:** run the backend integrity spike, accept or reject the
   ADR, provision isolated development and QA services, add CI/security/contract gates, and prove
   rollback. This is F0.7 plus the remaining evidence for F0.1–F0.6.
4. **P1-A — Client and identity foundation:** implement the approved shell/composer, account
   bootstrap, repository boundary, and consented migration.
5. **P1-B — Private group loop:** implement groups, invites, shared events, hidden independent
   forecasts, realtime read models, immutable locking, and resolution.
6. **P1-C — Learning and proof:** implement versioned scoring, sample-aware group/personal
   analytics, leaderboards, and privacy-safe Receipts; then run the private-beta gate.
7. **P2 — Viral distribution:** universal links and challenge primitives precede the iMessage
   extension; friends/profiles and deterministic recaps follow the trusted shared loop.
8. **P3 — Public network:** public event/resolution operations and moderation precede global
   ranking, local/community discovery, and broad rollout.
9. **P4 — Advanced community:** team, season, tournament, creator, analytics, and personality
   features begin only after public integrity and operations are stable.

## 3. Foundation task breakdown and live state

| ID | Outcome and required artifact | Gate before completion | Status |
|---|---|---|---|
| F0.1 | Ratify one private-group MVP contract, actor/permission model, privacy-safe event dictionary, funnel, metric formulas, thresholds, and five-session uncoached prototype study. Artifact: `SOCIAL_V2_PRODUCT_CONTRACT.md`. | Product-owner approval plus five recorded sessions; no invented research result. | `in_progress` |
| F0.2 | Produce the premium IA, component/state system, responsive/accessibility annotations, and invite → lock → reveal → Receipt prototype. Artifacts begin with `CLAUDE_DESIGN_PROMPT.md`; Claude Design/Figma output is still required. | Approved prototype, token inventory, all failure states, tap/time evidence, design sign-off. | `in_progress` |
| F0.3 | Compare backend options and prove identity, authorization, atomic locks, realtime/APNs, backup/export, and isolation. Local PostgreSQL now passes RLS, two-session concurrency, immutable ledgers, generic outbox/reconciliation, separate synthetic dev/QA databases, and restore checksums; hosted portions remain. | Apple auth, hosted RLS/realtime/APNs, hosted restore/export/isolation/load pass; ADR explicitly accepted; no production credentials. | `in_progress` |
| F0.4 | Define vendor-neutral entities, state machines, OpenAPI, errors, idempotency, pagination, reconciliation, audit and negative fixtures. Local structural CI now enforces refs/security/idempotency/schema rules and validates 18 fixture expectations. | ADR/policy review, external lint, generated-client compatibility and live-backend fixture execution. | `review_required` |
| F0.5 | Define visibility/retention, identity/location privacy, consent, block/report, content policy, moderation, deletion/export, legal/store disclosures and incidents. A closed payload allowlist now rejects content/identity/token/location/free-form leakage in 13 fixtures. | Product/safety/privacy owners approve; runtime enforcement and counsel review remain external release gates. | `review_required` |
| F0.6 | Define legacy-field disposition, explicit migration choices, repository/outbox/cache states, conflict/retry semantics, fixture migrations, backup/reconciliation, downgrade, kill switch, and rollback. | Domain/privacy contracts accepted and fixture-based interruption/relaunch/rollback tests implemented. | `in_progress` |
| F0.7 | Provision isolated services/secrets and implement CI, compatibility, observability, flags, promotion and rollback. Local gates, hosted workflow definition, and typed default-off iOS rollout policy now pass locally; the integrated client suite is 80/80. | Accepted ADR/provider access; first green hosted run, real-manifest/project isolation and successful rollback game day. | `in_progress` |

## 4. Phase 1 — Premium Social MVP

| ID | Execution outcome | Entry/exit evidence | Status |
|---|---|---|---|
| P1.CAP.1 | Universal one-screen composer with explicit confidence, audience, horizon, progressive details, keyboard-safe accessibility, retained drafts, idempotent submit, and server-confirmed lock. | Approved Figma frames; draft/domain tests; small/large-device UI tests; network recovery evidence. | `queued` |
| P1.CAP.2 | Premium four-destination shell and value-first activation that reaches the group forecast loop before optional permissions. | IA sign-off; deep-link/back-stack tests; onboarding completion and privacy-safe activation events. | `queued` |
| P1.ID.1 | Native Sign in with Apple, server identity exchange, Keychain session handling, profile bootstrap, recovery, sign-out, export, and deletion entry points. | Nonce/replay/audience/revocation tests; account lifecycle and privacy-log evidence. | `queued` |
| P1.SYNC.1 | Repository boundary, local cache, account-bound idempotent outbox, delta sync, retry/backoff, conflict and removed-access handling. | Offline/relaunch/cross-account/duplicate fixtures; no false server confirmation. | `queued` |
| P1.SYNC.2 | Explicit existing-user migration choices, item review, resumable reconciliation, progress/error UI, and recovery without silent upload. | Prior-version fixtures; zero-loss count/checksum; interruption, retry, downgrade and rollback evidence. | `queued` |
| P1.GRP.1 | Private group lifecycle, roles, membership, settings, leaving/removal, deletion, block interaction, and server authorization. | Full actor/access matrix including outsider, removed member, blocked user and deleted account. | `queued` |
| P1.GRP.2 | High-entropy revocable invites, safe previews, expiry/use limits, join confirmation, authentication continuation, and abuse throttling. | Forwarded/expired/replayed/cross-environment tests; no token or group-content leakage. | `queued` |
| P1.PRED.1 | Group event creation with outcomes, lock/reveal times, resolution rules, objective/subjective classification, validation and audit. | State-machine and ambiguity fixtures; authorization and date-boundary tests. | `queued` |
| P1.PRED.2 | Realtime group feed and detail read models covering open, submitted, locked, resolving, resolved, disputed, corrected, voided and removed-access states. | Reconnect/cursor/pagination/stale-event tests; accessible loading/error/offline UI. | `queued` |
| P1.LOCK.1 | Server-UTC atomic immutable forecast ledger, idempotency, audit reference, hidden-vote rules and verifiable Receipt identity. | Deadline/concurrency/replay/mutation attack tests; exact database/audit reconciliation. | `queued` |
| P1.RES.1 | Precommitted resolution workflow with evidence, permissions, reveal, void, dispute, correction, notification and score invalidation behavior. | Normal/delayed/ambiguous/disputed/corrected/void fixtures and audit trail. | `queued` |
| P1.SCORE.1 | Ratified proper scoring formula, scoring versions, eligibility/sample gates, simulations and plain-language explanation. | Independent golden vectors, property tests, adversarial/cherry-picking simulation, owner approval. | `queued` |
| P1.SCORE.2 | Group leaderboard and personal/group calibration analytics with denominators, uncertainty, common-sample comparison and correction handling. | Snapshot reconciliation; ranked/unranked/privacy/accessibility fixtures; no subjective-to-public leakage. | `queued` |
| P1.RCPT.1 | Sealed/revealed, audience-projected Receipt artifacts and native share preview with revoke/correction behavior. | Privacy snapshot matrix, redaction tests, accessibility and cancellation behavior. | `queued` |

**Phase 1 exit:** complete the private group create → invite → forecast → lock → resolve → score →
Receipt loop on two physical devices/two accounts; prove authorization, migration, accessibility,
data-loss prevention, content-free telemetry, and meaningful private-beta return behavior.

## 5. Phase 2 — Viral Distribution

| ID | Execution outcome | Entry/exit evidence | Status |
|---|---|---|---|
| P2.LINK.1 | Typed universal-link router, environment-specific associated domains, safe no-index landing pages, install/auth continuation, expiry/revocation and privacy-safe conversion events. | Installed/uninstalled/cold/warm/signed-out/tampered/forwarded matrix on physical devices. | `queued` |
| P2.CHAL.1 | Blind designated-recipient challenge lifecycle, independent locks, reveal, resolution, rematch, private history and abuse controls. | Early-reveal and forwarded-authority attacks fail; two-device end-to-end completion. | `queued` |
| P2.MSG.1 | Thin iMessage extension using shared contracts for create/respond/reveal and safe main-app handoff under extension constraints. | Physical Messages tests, memory/timeout recovery, accessible compact/expanded UI, no payload secrets. | `queued` |
| P2.SOC.1 | Consent-based profile/friend graph, exact-handle/link discovery, viewer-specific projections, evidence-tier badges, block/report and lifecycle states. | Field-level privacy, homograph, enumeration, relationship-race and block tests. | `queued` |
| P2.RECAP.1 | Deterministic weekly group stories with traceable highlights, sample gates, correction behavior, preference-aware delivery and redacted sharing. | Golden period/time-zone/job-idempotency/privacy/accessibility fixtures and retention experiment. | `queued` |

**Phase 2 exit:** prove routing and blind challenges across install/auth states, operational
block/report/rate limits, deterministic recap claims, privacy-safe profiles, and conversion
measurement that excludes content, contacts, and cross-app tracking.

## 6. Phase 3 — Public Network

| ID | Execution outcome | Entry/exit evidence | Status |
|---|---|---|---|
| P3.EVT.1 | Public event lifecycle, append-only integrity ledger, transactional outbox, replay and migration recovery. | Transition/concurrency/replay/migration tests and auditable event timeline. | `queued` |
| P3.EVT.2 | Structured curated-event editorial workflow, objective rules/sources, discovery API/UI and public submission. | Two-person publish checks, ambiguity review, stable pagination and load evidence. | `queued` |
| P3.RES.1 | Dual-approved evidence-backed public resolution, provisional/final states, disputes, voids, corrections and score reversal. | Operator permission tests, source failures, correction reconciliation and tabletop drill. | `queued` |
| P3.SCORE.1 | Versioned public scoring, eligibility, score ledger/snapshots, global leaderboard, explanations and correction rebuilds. | Formula properties/golden vectors, large-population ranking, tie/pagination and anomaly evidence. | `queued` |
| P3.LOC.1 | Coarse opt-in city/metro discovery and leaderboard privacy thresholds without server receipt of precise coordinates. | Consent/removal/small-cohort suppression and denied-location/manual-selection tests. | `queued` |
| P3.LEAG.1 | Curated common-event category leagues with frozen eligibility/scoring and reproducible standings. | Eligibility-version, common-pool, correction and archive/replay tests. | `queued` |
| P3.SAFE.1 | User reporting/blocking, moderator queue, least-privilege evidence, enforcement, appeals and policy exercises. | Abuse fixtures, access/audit tests, SLA dashboards and response tabletop. | `queued` |
| P3.SAFE.2 | Anti-cheat threat controls, rate/device/account signals, quarantine, review/appeal and exact score restoration. | Red-team, false-positive, evasion, quarantine and reconciliation evidence. | `queued` |
| P3.OPS.1 | Event-supply operations, SLOs, dashboards, budgets, backups, runbooks, kill switches and staged category rollout. | Load/restore/incident/rollback drills and explicit go/no-go review. | `queued` |

**Phase 3 exit:** public inventory, resolution, scoring, safety, anti-cheat and operations meet
their SLOs through a controlled category pilot before broader discovery is enabled.

## 7. Phase 4 — Advanced Community

| ID | Execution outcome | Entry/exit evidence | Status |
|---|---|---|---|
| P4.TEAM.1 | Governed team workspaces, tenant isolation, forecasting programs, roles, exports and privacy-safe team analytics. | Cross-tenant negative tests, policy approvals, audit/export/delete evidence. | `queued` |
| P4.SEASON.1 | Fixed-rule recurring league seasons with eligibility, schedule, versioned scoring, standings, archive and corrections. | Frozen-rule, boundary, correction, replay and suspension tests. | `queued` |
| P4.TOUR.1 | Pooled qualifier/final tournaments with fair brackets, hidden forecasts, advancement, disqualification and appeals. | Deterministic seeding/advancement, deadline races, load and operator-exception audit. | `queued` |
| P4.HOST.1 | Governed creator event proposals, conflict disclosure, editorial approval, host history/following and accountable dashboards. | Trust-tier, self-approval, conflict, moderation and deleted-host continuity tests. | `queued` |
| P4.ANALYTICS.1 | Advanced sample-aware calibration stories, cohort-safe comparisons, horizons/categories, evidence drill-down and share projection. | Deterministic claim gates, low-sample/privacy/bias fixtures, accessible tables and explanations. | `queued` |
| P4.PERSONA.1 | Reproducible, explainable and emotionally safe forecasting archetypes/recaps with opt-in sharing and deletion. | Boundary/stability/bias/privacy/accessibility tests and product-safety review. | `queued` |

## 8. Lower-model dispatch contract

The lead agent plans and reviews architecture. Bulk implementation is delegated as a bounded task
packet containing:

1. The exact task/subtask IDs and governing acceptance criteria.
2. Only the required repository authority files, feature contract, task section, and named source
   files; workers do not rescan unrelated history.
3. An explicit allowed-file list so parallel workers cannot overwrite one another.
4. Required production behavior, prohibited behavior, edge cases, data authority, state
   transitions, and rollback.
5. Tests to write first, the exact verification command, evidence location, and checks that remain
   manual or external.
6. A requirement to preserve user work, prevent duplicates/stale results, and never show server
   success before confirmation.
7. A concise completion report containing files changed, checks/results, unresolved risks, and a
   truthful lifecycle status.

The lead agent integrates, reviews security/privacy boundaries, runs the combined verification,
updates contracts/status/evidence, and alone decides whether a commit may move from `dev` to `qa`.

## 9. Immediate next actions

1. Review and approve the F0.1 product contract.
2. Give `CLAUDE_DESIGN_PROMPT.md` to Claude Design; attach the Figma/prototype output and run five
   uncoached sessions without recording participant PII.
3. Extend the passed disposable local PostgreSQL integrity slice into the hosted ADR-008 proof;
   record redacted Apple-auth, RLS, deadline/concurrency, restore/export, realtime/APNs, and
   development/QA isolation evidence.
4. Review the F0.4–F0.6 draft contracts together; resolve every owner decision before generating
   client/server implementation tickets.
5. After ADR acceptance, provision isolated development and QA backend projects, then execute F0.7
   CI/environment/rollback work.
6. Start P1.CAP.1/P1.CAP.2 only from approved design frames and start P1.ID.1/P1.SYNC.1 only from
   accepted API/privacy/migration contracts.
