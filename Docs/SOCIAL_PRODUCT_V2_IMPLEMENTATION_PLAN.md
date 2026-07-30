# Hindsight Social Product v2 — Implementation-Ready Master Plan

**Status:** accepted planning baseline; mandatory foundation execution in progress
**Decision date:** 2026-07-30
**Source of truth:** this document, until individual items are created in Jira
**Audience:** product, design, iOS, backend, QA, safety, growth, and implementation agents
**Product promise:** make a call in seconds, lock it with a timestamp, compare forecasts with
friends or the world, and learn who is genuinely well calibrated.

## 1. Executive summary

Hindsight v2 changes the product from a local-only decision journal into a networked prediction
platform with a valuable private mode. The private journal is not deleted: existing entries remain
local and private until a user explicitly chooses to sync or share them. New social objects use a
backend because group membership, lock times, shared resolution, scoring, and leaderboards require
a server-authoritative record.

The plan has four product phases plus a mandatory foundation:

1. **Premium Social MVP:** radically simpler capture, accounts and sync, private groups, shared
   predictions, trustworthy resolution, fair leaderboards, and shareable Receipts.
2. **Viral Distribution:** iMessage, universal-link acquisition, recaps, direct challenges,
   friends, profiles, and reliability badges.
3. **Public Network:** curated verified events, local/global boards, category leagues, moderation,
   anti-cheat, and resolution operations.
4. **Advanced Community:** team forecasting, seasons, tournaments, creator events, advanced
   calibration analytics, and evidence-based forecasting profiles.

The critical path is:

```text
Product rules + prototype
    -> backend/trust contracts
    -> account and sync foundation
    -> private group prediction loop
    -> scoring and Receipts
    -> iMessage/universal-link growth
    -> curated public events
    -> broader community systems
```

No implementation agent should begin a phase until its entry gate is met. “Code complete” is not
“done”: every task requires the named automated checks, manual evidence, documentation update, and
rollback notes.

### Live foundation execution — 2026-07-30

F0 execution has started, but Phase 1 feature implementation remains gated:

- F0.1 has a draft product contract, actor/permission matrix, private analytics-event dictionary,
  measurable hypothesis, decision thresholds, and five-session research script. Product-owner
  approval and actual uncoached sessions remain.
- F0.2 has a copy/paste Claude Design brief with the required premium IA, screen/state inventory,
  component system, accessibility contract, and prototype tests. The Figma prototype, design
  review, and research evidence remain.
- F0.3 has a current backend comparison and a conditional ADR recommending managed Postgres
  behind a vendor-neutral versioned API. The recommendation is not accepted until the disposable
  hosted proof passes. The local PostgreSQL parity slice now proves RLS reads, membership
  authorization, server-time deadline enforcement, idempotency, true concurrent single-lock
  creation, immutable ledgers, durable outbox/reconciliation behavior, separate synthetic dev/QA
  databases, and logical backup/restore checksums. Apple authentication, Supabase-hosted
  RLS/realtime, actual APNs, hosted isolation, and hosted load/restore remain.
- F0.4 now has a dependency-free structural OpenAPI validator and 18 synthetic expectation
  fixtures in addition to the draft domain/OpenAPI contract. External lint, generated-client
  compatibility, accepted policy values, and live-backend fixture execution remain.
- F0.5 now has a closed machine-readable telemetry/push allowlist with 13 deterministic privacy
  fixtures. Privacy/safety/legal approval and runtime/provider enforcement remain.
- F0.6 has the migration/offline contract but still requires accepted upstream contracts and
  fixture-store implementation/relaunch/rollback evidence.
- F0.7 now has environment validation, a local/client CI path, a read-only hosted workflow
  definition, a default-off typed iOS rollout policy, and promotion/rollback controls. Hosted
  foundation run `30591583112` passed every repository gate and the complete shared Xcode scheme.
  Cloud projects, credentials, observability, isolation proof, and the recovery game day remain
  blocked on accepted architecture and owner-provided access.

Live sequencing and evidence are tracked in `SOCIAL_V2_EXECUTION_TRACKER.md`. Draft artifacts do
not satisfy the phase entry gate by themselves.

## 2. Product and integrity rules

These rules are normative across every task:

- A forecast is an immutable response containing an outcome choice, confidence, author, and
  server-issued lock timestamp. Corrections create a new revision before lock or an appended note
  after lock; they never rewrite history.
- Other participants' votes and aggregate percentages remain hidden until the user submits, unless
  the event explicitly uses an open-poll format. The visibility policy is shown before voting.
- Public rankings reward probabilistic calibration with a documented proper scoring rule, not raw
  wins, posting volume, or confidence theater.
- Every statistic shows its denominator and uses sample gates. A user with too little evidence is
  “Unranked” or “Emerging,” never inaccurately labelled good or bad.
- Private journal text is not uploaded by migration. Each existing item remains local unless the
  user explicitly enables private sync or converts that item into a social prediction.
- Public events must have an objective resolution rule, authoritative evidence, and an appeal
  path before accepting forecasts.
- Location is opt-in and coarse. City membership must never disclose precise coordinates or a
  participant's real-time location.
- Deletes, blocks, membership changes, forecast submissions, resolutions, score changes, and
  moderator actions are idempotent and auditable.
- Loading, empty, offline, conflict, permission, rate-limit, cancellation, and server-error states
  are designed and tested. Optimistic UI may show “sending,” but never “locked” or “resolved”
  before server confirmation.
- Accessibility, Dynamic Type, reduced motion, dark mode, keyboard navigation where applicable,
  and at least 44-point targets are release requirements.
- User-generated content, usernames, avatars, group names, and public events require reporting,
  blocking, moderation, retention, and deletion behavior before public launch.

## 3. Definition of an implementation-ready task

Every Jira issue created from this plan must retain:

- **Summary:** one outcome-focused sentence.
- **User story:** one actor, need, and benefit.
- **Why:** the user or business problem and the failure mode prevented.
- **What:** exact in-scope behavior and explicit non-scope.
- **How:** components, contracts, state transitions, persistence behavior, and integration points.
- **Expected result:** observable result after completion.
- **Subtasks:** independently verifiable steps; each says what, why, how, and expected result.
- **Dependencies:** blocking task IDs and external decisions.
- **Acceptance criteria:** testable statements, not “works correctly.”
- **Verification evidence:** exact test class/command, screenshots or recordings, backend/API
  evidence, and documentation to update.
- **Failure and rollback:** how incomplete rollout is disabled without corrupting user data.

An agent should read this file, the task's named feature contract, and only the specific source
files named during refinement. It must not invent product behavior when a task names an unresolved
decision.

## 4. Mandatory foundation — before Phase 1 feature code

### F0.1 — Ratify the networked product contract and measurable launch hypothesis

**Summary:** Turn the social vision into one bounded MVP contract and define evidence that proves
or falsifies it.

**User story:** As the product owner, I want one measurable definition of the social MVP so that
design and engineering do not build several incompatible products.

**Why:** The product currently mixes private journaling, decision support, forecasting, and social
competition. Without a ratified contract, agents will make different assumptions about privacy,
visibility, scoring, and the primary user.

**What:** Define the target user, first-session promise, minimum social loop, phase non-goals,
north-star metric, guardrail metrics, and kill/iterate thresholds. Recommended primary activation:
“a new user submits one forecast to a group and returns for its reveal within 14 days.”

**How:** Write a short product requirements contract; map every proposed screen and event to the
core loop; define analytics events without forecast text; conduct five uncoached prototype tests;
record all changes as decisions rather than silently altering this baseline.

**Expected result:** Every worker can explain the same product, and Phase 1 scope can be accepted
or rejected with observed evidence.

**Subtasks:**

- **F0.1a — Define actors and jobs.**
  **Summary/user story:** As a planner, I need named actors—solo forecaster, group member, group
  admin, invitee, resolver, moderator—so each workflow has an accountable user.
  **What/why/how/expected:** Document each actor's goal, permissions, sensitive data, and first
  success. This prevents generic “user” requirements and produces a permission-test matrix.
- **F0.1b — Define funnel and guardrails.**
  **Summary/user story:** As the product owner, I need metrics that distinguish curiosity from
  retained value.
  **What/why/how/expected:** Specify invitation open, account completion, first forecast, first
  reveal, week-4 retention, forecast resolution, report rate, block rate, and notification opt-out
  with exact numerators/denominators. The result is an analytics dictionary implementers can test.
- **F0.1c — Ratify MVP scope and non-goals.**
  **Summary/user story:** As an implementer, I need hard boundaries so “social” does not imply a
  public feed, chat system, or creator economy in Phase 1.
  **What/why/how/expected:** Approve the Phase 1 bullets in this plan and explicitly defer public
  posting, direct messages, follower feeds, monetization, arbitrary public events, and precise
  location. The result is a stable release target.

**Dependencies:** none.
**Acceptance criteria:** PRD approved; metrics have owners and formulas; five prototype sessions
record time-to-forecast and comprehension; disputed decisions are recorded in `DECISIONS.md`.
**Evidence:** signed product checklist, research notes with no participant PII, and updated feature
contract.
**Rollback/non-scope:** no production code or external messaging is changed by this task.

### F0.2 — Design and validate the premium v2 experience before implementation

**Summary:** Produce a coherent visual system and high-fidelity prototype that makes the viral
loop obvious within the first 30 seconds.

**User story:** As a first-time user, I want to understand what Hindsight does and make a forecast
without learning a complex journal workflow.

**Why:** Re-skinning current screens would preserve the same information architecture and tap
burden. The redesign must validate navigation, hierarchy, emotional tone, and acquisition before
engineering hardens it.

**What:** Design onboarding, Home composer, group feed, vote sheet, locked state, reveal, group
leaderboard, personal insight, invite landing, and Receipt share card. Define light/dark tokens,
typography, motion, sound/haptic rules, loading/error/empty states, and accessibility annotations.

**How:** Build reusable Figma variables/components, prototype the complete happy path and three
failure paths, test on smallest supported iPhone and iPhone 16 Pro Max, and measure tap count and
time. The normative capture target is no more than four deliberate actions after text entry; joining
an existing binary prediction is two choices plus submit.

**Expected result:** Engineering receives approved layouts and behavior contracts rather than
interpreting mood boards.

**Subtasks:**

- **F0.2a — Define v2 information architecture.**
  **Summary/user story:** As a returning user, I want the most valuable actions immediately
  reachable.
  **What/why/how/expected:** Evaluate a four-destination shell—Home, Groups, Discover, Profile—with
  a persistent create affordance. Map personal/private records separately from social predictions.
  Deliver a route map with deep-link destinations and back-stack behavior.
- **F0.2b — Create the premium component system.**
  **Summary/user story:** As a user, I want Hindsight to feel distinctive and trustworthy across
  every state.
  **What/why/how/expected:** Define semantic colors, type scale, spacing, radii, elevation,
  confidence visualization, locked-state treatment, result motion, chart styles, buttons, chips,
  cards, avatars, and skeletons. Annotate accessibility equivalents and reduced-motion behavior.
- **F0.2c — Prototype and test the viral loop.**
  **Summary/user story:** As an invitee, I want to understand the prompt, make my call, and see why
  installing Hindsight is worthwhile.
  **What/why/how/expected:** Prototype invite → forecast → locked receipt → reveal → leaderboard →
  share. Run five uncoached sessions and revise until at least four participants complete without
  explanation and can accurately describe what is locked and who can see it.

**Dependencies:** F0.1.
**Acceptance criteria:** approved high-fidelity prototype; token/component inventory; all required
states; tap/time benchmarks; VoiceOver reading-order annotations; design review sign-off.
**Evidence:** prototype link, annotated export, research summary, and design decision log.
**Rollback/non-scope:** no implementation begins merely because an individual screen looks final.

### F0.3 — Select the backend platform and write the architecture decision record

**Summary:** Choose a backend that can safely support accounts, groups, immutable forecasts,
realtime updates, push notifications, and ranked aggregation.

**User story:** As an engineer, I need a ratified platform and trust boundary so that client,
backend, and operations work share the same contracts.

**Why:** The repository currently prohibits a backend. Social predictions cannot safely use
client-only timestamps, scores, membership, or resolution because modified clients could rewrite
history or fabricate leaderboard results.

**What:** Evaluate at least Supabase/Postgres, Firebase, CloudKit, and a custom API against Sign in
with Apple, relational authorization, realtime events, background jobs, APNs, auditability, local
development, backups, cost, vendor exit, and moderation tooling. Recommended default for the spike:
Postgres plus server functions and row-level authorization, exposed through a versioned API.

**How:** Implement throwaway vertical spikes—not production code—for Apple identity verification,
group membership enforcement, atomic forecast lock, and leaderboard query. Record threat model,
cost assumptions, data residency, backup/restore, and dependency policy in an ADR.

**Expected result:** One selected architecture with known risks, an exit strategy, and no hidden
client-authoritative integrity decisions.

**Subtasks:**

- **F0.3a — Build the weighted platform matrix.**
  **Summary/user story:** As the technical owner, I want a repeatable choice based on product
  constraints.
  **What/why/how/expected:** Score candidates on security, delivery speed, Swift support,
  relational queries, realtime behavior, operations, cost at 10k/100k/1m MAU, and portability.
  Publish weights and evidence so the decision can be revisited without redoing research.
- **F0.3b — Prove the integrity-critical vertical slice.**
  **Summary/user story:** As a group member, I need my submitted confidence and timestamp to remain
  immutable.
  **What/why/how/expected:** Spike authentication, create group, join by token, submit once before
  deadline, reject late/duplicate mutation, and query a server-derived score. Capture latency,
  failure behavior, and exploit attempts.
- **F0.3c — Ratify ADR and operational ownership.**
  **Summary/user story:** As the release owner, I need to know who controls environments, secrets,
  backups, incidents, and cost limits.
  **What/why/how/expected:** Record selected stack, rejected alternatives, service ownership,
  backup RPO/RTO, alert thresholds, vendor lock-in, and migration path. Update repository constraints
  only after acceptance.

**Dependencies:** F0.1.
**Acceptance criteria:** ADR approved; spike proves server-side authorization and atomic lock;
monthly cost model documented; local/dev/qa/prod environment strategy agreed.
**Evidence:** ADR, redacted spike logs, threat-model notes, and cost sheet.
**Rollback/non-scope:** spikes contain no production credentials or user data and may be deleted
after the ADR.

### F0.4 — Define the social domain, API, and event contracts

**Summary:** Establish stable models and state machines before client and server teams work in
parallel.

**User story:** As an implementation agent, I want explicit entities and transitions so I can add a
feature without inventing incompatible fields or lifecycle rules.

**Why:** “Prediction,” “vote,” “resolution,” “group,” and “leaderboard” sound simple but have
different ownership, visibility, and mutation rules. Ambiguity here produces data corruption and
security bugs.

**What:** Define User, Profile, Friendship, Group, Membership, Invite, PredictionEvent,
OutcomeOption, Forecast, ForecastRevision, ResolutionRule, Resolution, Evidence, Appeal,
ScoreEntry, Receipt, NotificationPreference, Report, Block, ModerationAction, and AuditEvent.

**How:** Use UUID/ULID identifiers, UTC server timestamps, explicit state enums, versioned payloads,
idempotency keys, pagination cursors, tombstones, optimistic concurrency versions, and a
machine-readable OpenAPI or equivalent schema. State machines must list authorized actor,
preconditions, side effects, emitted events, and retry behavior.

**Expected result:** iOS, backend, analytics, and QA can generate fixtures from one contract and
reject illegal transitions consistently.

**Subtasks:**

- **F0.4a — Model entities and ownership.**
  **Summary/user story:** As a data engineer, I need each record to have an owner and visibility
  scope.
  **What/why/how/expected:** Produce schema, indexes, foreign-key/delete behavior, sensitivity
  classification, and retention policy. The result supports authorization and export/delete
  without orphaned social data.
- **F0.4b — Specify state machines.**
  **Summary/user story:** As a participant, I want events to move predictably from draft to open,
  locked, resolving, resolved, disputed, corrected, or voided.
  **What/why/how/expected:** Define legal transitions, actor permissions, deadline handling,
  duplicate behavior, and notification side effects for events, forecasts, invites, membership,
  and resolutions.
- **F0.4c — Publish API and event schemas.**
  **Summary/user story:** As a client engineer, I need typed requests, responses, errors, and
  realtime events.
  **What/why/how/expected:** Specify authentication, pagination, idempotency, rate limits, error
  codes, clock semantics, schema versioning, and compatibility. Generate fixtures and contract
  tests from the schema.

**Dependencies:** F0.3.
**Acceptance criteria:** schema review completed; every mutation has authorization and idempotency;
API lint and generated-client smoke test pass; prohibited transitions have negative fixtures.
**Evidence:** ADR/schema links, state diagrams, migration draft, and contract-test output.
**Rollback/non-scope:** no client bypasses the API by writing integrity-sensitive tables directly.

### F0.5 — Define privacy, safety, identity, and legal policy for a networked product

**Summary:** Replace the local-only privacy posture with explicit, comprehensible controls and
operational safety obligations.

**User story:** As a user, I want to know which forecasts are private, shared with a group, or
public, and I want meaningful control over my identity and data.

**Why:** Accounts, invitations, profiles, location, user-generated content, and leaderboards create
new harms: unwanted discovery, harassment, sensitive inference, impersonation, permanent
embarrassment, and regulatory obligations.

**What:** Define visibility levels, default identity, age requirement, consent, blocking,
reporting, content rules, account deletion, export, retention, appeal, law-enforcement request
handling, privacy policy, terms, community guidelines, and App Store disclosures.

**How:** Create a data inventory and threat model; use privacy-by-default settings; prohibit public
indexing of private/group content; separate account identity from display name; use coarse
location; define moderator access and audit; obtain owner/counsel review before public release.

**Expected result:** Product copy, API authorization, moderation, and legal documents tell the same
truth.

**Subtasks:**

- **F0.5a — Classify data and visibility.**
  **Summary/user story:** As a user, I need every item to show who can see it.
  **What/why/how/expected:** Classify private journal, synced private, group, unlisted-link, and
  public data; specify defaults and conversion warnings. Deliver a matrix used by API policies and
  UI labels.
- **F0.5b — Create abuse and identity safeguards.**
  **Summary/user story:** As a participant, I need to block abuse and avoid exposing my legal
  identity or location.
  **What/why/how/expected:** Define handles, uniqueness, impersonation response, block semantics,
  report categories, minors policy, prohibited prediction topics, location granularity, and
  escalation SLAs.
- **F0.5c — Update legal and store disclosures.**
  **Summary/user story:** As an installer, I need accurate disclosure before sharing information.
  **What/why/how/expected:** Draft updated privacy policy, terms, community guidelines, account
  deletion page, support process, privacy nutrition labels, and in-app consent copy. Record owner
  approval and effective version.

**Dependencies:** F0.1, F0.3, F0.4.
**Acceptance criteria:** data-flow diagram and threat model approved; visibility copy tested;
deletion/export and moderation SLAs defined; legal/store checklist assigned.
**Evidence:** policy drafts, privacy matrix, threat-model review, and App Store disclosure mapping.
**Rollback/non-scope:** do not enable public content or upload existing journal data before these
controls ship.

### F0.6 — Plan local-data migration, offline behavior, and sync recovery

**Summary:** Preserve existing journal data while introducing an optional account-backed social
store and reliable offline cache.

**User story:** As an existing user, I want the new version to retain my decisions and let me
choose what leaves my device.

**Why:** A destructive or silent migration would violate trust. SwiftData records, network
entities, and server-authoritative locks have different lifecycles and must not be conflated.

**What:** Define local-only legacy retention, optional private sync, conversion of a local
prediction into a social event, network cache, outbox, conflict resolution, account sign-out,
account deletion, reinstall restore, schema evolution, and downgrade behavior.

**How:** Introduce repository protocols around existing SwiftData; add stable remote IDs and sync
metadata only through a versioned migration; use an idempotent outbox for permitted mutations;
keep server-confirmed locked records read-only; back up before migration; ship behind a remote
kill switch.

**Expected result:** Existing users upgrade without data loss and can use local features during
network outages without creating false server state.

**Subtasks:**

- **F0.6a — Inventory and classify legacy data.**
  **Summary/user story:** As an existing user, I want every current decision accounted for during
  upgrade.
  **What/why/how/expected:** Map Decision, Prediction, options, reviews, notifications, defaults,
  demo records, and exports to v2 behavior. Define what stays local, may sync, or cannot become
  social without explicit editing.
- **F0.6b — Specify sync and conflict rules.**
  **Summary/user story:** As an offline user, I want drafts preserved and confirmed locks never
  fabricated.
  **What/why/how/expected:** Define local draft, queued, sending, confirmed, rejected, conflicted,
  and tombstoned states; idempotency and retry backoff; server-wins fields; user-resolution flows;
  and sign-out cache handling.
- **F0.6c — Design migration and rollback tests.**
  **Summary/user story:** As the release owner, I want to stop rollout without stranding or
  corrupting records.
  **What/why/how/expected:** Create fixture stores from prior releases, backup/restore path,
  interrupted-migration tests, downgrade expectations, checksum/count reconciliation, and kill
  switch behavior.

**Dependencies:** F0.3, F0.4, F0.5.
**Acceptance criteria:** written migration map; no silent upload path; offline state matrix;
fixture-based migration/relaunch/rollback tests specified; data-loss SLO is zero.
**Evidence:** migration ADR, fixture catalog, test plan, and recovery runbook.
**Rollback/non-scope:** local records are never deleted merely because an account is removed.

### F0.7 — Establish environments, CI, observability, feature flags, and branch promotion

**Summary:** Create a repeatable delivery path from `dev` through `qa` to production without
mixing user data or unverified builds.

**User story:** As a release owner, I want every promoted build tied to passing evidence and the
correct backend environment.

**Why:** A networked app adds schema migrations, secrets, API compatibility, push configuration,
and production incidents. Manual ad-hoc promotion risks pointing a QA app at production or
deploying incompatible client/server versions.

**What:** Define development, QA/staging, and production environments; bundle IDs and associated
domains; secret storage; migrations; CI checks; feature flags; structured logs; metrics; traces;
crash reporting; alerting; release identifiers; and rollback.

**How:** Require pull requests into `dev`, signed/tagged promotion from `dev` to `qa`, green client
and server contract tests, migration dry-run, TestFlight QA build, and an explicit production
approval. Never commit secrets. Logs and analytics must exclude forecast text and invite tokens.

**Expected result:** The same commit and schema version can be traced across app, backend, tests,
and evidence.

**Subtasks:**

- **F0.7a — Provision isolated environments and secrets.**
  **Summary/user story:** As a tester, I need QA behavior that cannot alter production users.
  **What/why/how/expected:** Create separate databases, auth clients, APNs configuration, storage,
  domains, credentials, budgets, and seeded synthetic fixtures. Document access and rotation.
- **F0.7b — Implement CI and compatibility gates.**
  **Summary/user story:** As an engineer, I need incompatible or untested changes blocked before
  promotion.
  **What/why/how/expected:** Run Swift unit/integration/UI smoke, backend unit/integration/security,
  schema lint, generated-client compatibility, secret scanning, accessibility smoke, and migration
  dry-run. Publish immutable results.
- **F0.7c — Implement observability and rollback.**
  **Summary/user story:** As an operator, I need to detect failed locks, delayed reveals, abuse
  spikes, and sync errors without reading user content.
  **What/why/how/expected:** Define content-free event IDs, latency/error/SLO dashboards, alerts,
  correlation IDs, feature flags, client minimum versions, deploy rollback, and database recovery
  runbooks.

**Dependencies:** F0.3–F0.6.
**Acceptance criteria:** environment isolation proven; CI blocks a known failing contract;
content-scrub tests pass; one rollback game day succeeds; branch promotion checklist approved.
**Evidence:** pipeline links, redacted environment inventory, dashboards, and game-day report.
**Rollback/non-scope:** `qa` never shares production credentials, database, invite namespace, or
push topic.

## 5. Phase 1 — Premium Social MVP

**Phase objective:** A user can create an account, make a prediction in seconds, invite a private
group, collect hidden forecasts, resolve the event fairly, view individual and group calibration,
and share a privacy-safe Receipt.

**Entry gate:** F0.1–F0.7 accepted; tested prototype; backend ADR; legal/trust model; dev/qa
environments; versioned contracts.
**Exit gate:** End-to-end group loop passes on two physical devices and two accounts; no
release-blocking accessibility/security/data-loss defects; telemetry proves every state transition
without logging content.

### Phase 1 bullet A — New one-screen capture

#### P1.CAP.1 — Build the universal prediction composer

**Summary:** Replace the multi-step primary flow with one adaptive composer for personal and group
predictions.

**User story:** As a user with a thought about the future, I want to lock it in within seconds so
logging never feels like administrative work.

**Why:** Capture friction is the largest adoption barrier. The social loop cannot spread if the
creator must complete a wizard before sending an invite.

**What:** Provide a single screen with statement, binary/custom outcomes, explicit confidence,
close/reveal horizon, audience selector, and one primary “Lock it in” action. Context, category,
evidence rule, and notes are progressive disclosure. No confidence is inferred.

**How:** Build a testable `PredictionDraft`, reusable field components, domain validation,
keyboard-safe scrolling, accessible confidence control, natural date presets, save state machine,
and separate local/server repositories. Personal local save may complete offline; social lock
requires server confirmation.

**Expected result:** A returning user can create a valid binary prediction in at most four
deliberate actions after entering text, and a failed network request preserves the draft.

**Subtasks:**

- **P1.CAP.1a — Define draft and validation contract.**
  **Summary/user story:** As a user, I want invalid or ambiguous predictions explained before
  they are locked.
  **What/why/how/expected:** Model optional draft fields separately from persisted records; require
  statement, at least two distinct outcomes, explicit confidence, audience, close time, and
  resolution time; validate ordering and length; return field-specific errors without destroying
  input.
- **P1.CAP.1b — Implement the adaptive SwiftUI composer.**
  **Summary/user story:** As a user on any supported device or text size, I want all required
  controls reachable without navigating screens.
  **What/why/how/expected:** Build reusable editor, outcome selector, confidence chips plus
  adjustable fallback, horizon chips, audience control, optional-detail disclosure, and persistent
  action area; handle keyboard, rotation, Dynamic Type, VoiceOver, reduced motion, and dark mode.
- **P1.CAP.1c — Implement submit state and recovery.**
  **Summary/user story:** As a user on unreliable connectivity, I want to know whether my call is
  a draft, sending, or truly locked.
  **What/why/how/expected:** Use idle/validating/submitting/confirmed/failed states, idempotency key,
  duplicate-tap protection, cancel semantics, retained draft, retry, and server timestamp display.
  Emit success only after persistence confirmation.

**Dependencies:** F0.2, F0.4, F0.6.
**Acceptance criteria:** median uncoached capture under ten seconds after text entry; no implicit
confidence; duplicate submit creates one record; failure retains all fields; accessibility and
responsive tests pass.
**Evidence:** `PredictionDraftTests`, composer UI tests at largest text, screen recordings on small
and large iPhones, and persistence/error integration tests.
**Rollback/non-scope:** detailed decision wizard remains available during migration; no natural
language parsing in this task.

#### P1.CAP.2 — Redesign navigation, onboarding, and first-session activation

**Summary:** Make the group prediction loop and premium value understandable on first launch.

**User story:** As a first-time user, I want to see why Hindsight is useful before being asked to
configure a journal or invite contacts.

**Why:** A fast composer still fails if users land in an empty analytics dashboard or cannot tell
the difference between personal, group, and public predictions.

**What:** Implement the approved v2 shell, contextual onboarding, sample interactive prediction,
Home composer, due/reveal queue, recent groups, and one early insight. Defer permission prompts
until their value is contextual.

**How:** Use state-driven onboarding steps, skip/resume, deep-link-aware entry, synthetic preview
content clearly labelled and excluded from personal stats, and post-success prompts for
notifications/account completion/invite.

**Expected result:** New users can describe the product, make or join a prediction, and reach a
meaningful locked state without exploring settings.

**Subtasks:**

- **P1.CAP.2a — Implement v2 application shell.**
  **Summary/user story:** As a returning user, I want Home, Groups, Discover, and Profile to have
  predictable ownership.
  **What/why/how/expected:** Build routing, selected-tab persistence, modal composer, profile access,
  deep-link routes, authentication gates, and restoration. The result avoids duplicated
  navigation stacks and dead-end links.
- **P1.CAP.2b — Implement value-first onboarding.**
  **Summary/user story:** As a new user, I want to experience a locked forecast before giving
  optional permissions.
  **What/why/how/expected:** Show one interactive sample, explain hidden-before-submit and
  timestamp integrity, allow personal-first or invite-first entry, and soft-ask notifications only
  after a relevant future reveal exists.
- **P1.CAP.2c — Instrument activation.**
  **Summary/user story:** As the product owner, I need to know where users fail without recording
  their prediction content.
  **What/why/how/expected:** Emit screen/step/result identifiers, duration buckets, error codes,
  and audience type; prohibit statement/outcome text, handles, group names, or invite tokens.

**Dependencies:** P1.CAP.1, F0.7.
**Acceptance criteria:** deep links enter the correct route before/after auth; onboarding resumes
safely; permissions are contextual; synthetic content is labelled/excluded; activation funnel is
queryable without PII.
**Evidence:** navigation/UI tests, analytics payload privacy tests, five-user comprehension report,
and screenshots in light/dark/largest text.

### Phase 1 bullet B — Accounts and cloud sync

#### P1.ID.1 — Implement account creation, Sign in with Apple, and profile bootstrap

**Summary:** Add secure account identity with a low-friction upgrade path from anonymous/local use.

**User story:** As a user, I want one secure identity across devices so I can join groups, recover
membership, and keep my social history.

**Why:** Groups, friends, blocks, invitations, score history, and moderation require a stable
server identity. Forcing an account before users understand the value would damage activation.

**What:** Support Sign in with Apple, authenticated session restoration, optional display handle,
profile visibility, sign-out, token refresh, revoked-credential handling, account deletion, and a
local-only mode until a network action requires identity.

**How:** Validate Apple identity tokens on the server; map Apple subject to an internal immutable
user ID; keep access credentials in Keychain; rotate short-lived sessions; make profile creation
idempotent; never use email as a public identifier; add an authentication gate that resumes the
original invite or create intent.

**Expected result:** A user can authenticate once, recover the same social account on another
device, and return to the action that triggered sign-in.

**Subtasks:**

- **P1.ID.1a — Implement server-side identity exchange.**
  **Summary/user story:** As an account holder, I want the server to accept only legitimate Apple
  credentials.
  **What/why/how/expected:** Validate issuer, audience, signature, nonce, expiry, and replay;
  create/link the internal user atomically; return short-lived access and rotated refresh tokens;
  add rate limits and audit events. Invalid or reused credentials are rejected consistently.
- **P1.ID.1b — Implement iOS account/session service.**
  **Summary/user story:** As a returning user, I want silent session restoration and a clear path
  when credentials expire.
  **What/why/how/expected:** Wrap AuthenticationServices, nonce generation, Keychain storage,
  refresh, cancellation, offline state, revoked Apple credential checks, and dependency injection.
  UI never reports sign-in before server confirmation.
- **P1.ID.1c — Implement profile bootstrap and account controls.**
  **Summary/user story:** As a member, I want a recognizable handle while controlling how much of
  my identity is shown.
  **What/why/how/expected:** Add handle validation/reservation, generated fallback display name,
  avatar initials, visibility settings, export request, sign-out, and deletion initiation.
  Deletion explains effects on authored events and anonymized aggregate history.

**Dependencies:** F0.3–F0.5, F0.7.
**Acceptance criteria:** token replay/invalid audience tests pass; cancelled login makes no
account; invite intent resumes; Keychain tokens are absent from logs/backups; revocation, sign-out,
and deletion paths work.
**Evidence:** backend auth integration tests, iOS session tests, two-device restoration test,
privacy log scan, and account-deletion runbook.
**Rollback/non-scope:** email/password and contact-book upload are out of scope for Phase 1.

#### P1.SYNC.1 — Implement private sync and network repository boundary

**Summary:** Add reliable cross-device synchronization without silently uploading existing private
journal content.

**User story:** As an account holder, I want new synced items and social memberships available on
my devices while preserving explicit control over legacy private entries.

**Why:** Directly coupling views to both SwiftData and network calls will create inconsistent
behavior and make offline recovery untestable.

**What:** Create repository interfaces for local journal records, synced private predictions, and
social events; implement cached reads, delta sync, outbox mutations, tombstones, conflict states,
pagination, retry, sign-out handling, and per-item sync controls.

**How:** Use stable remote identifiers and server versions; serialize mutations with idempotency
keys; persist last successful cursors; merge only fields whose ownership is defined; represent
server-confirmed locks as immutable local snapshots; expose explicit `local`, `queued`, `synced`,
`failed`, and `conflicted` states to UI.

**Expected result:** Network loss does not erase work or misrepresent a forecast as locked, and
the same account converges across devices after reconnecting.

**Subtasks:**

- **P1.SYNC.1a — Introduce repository protocols and adapters.**
  **Summary/user story:** As an engineer, I want views independent of storage implementation.
  **What/why/how/expected:** Define async read/watch/mutate contracts, typed domain errors, local
  SwiftData adapter, remote API adapter, and deterministic fakes. Existing private flows continue
  through the local adapter.
- **P1.SYNC.1b — Build outbox and delta-sync engine.**
  **Summary/user story:** As an intermittently connected user, I want permitted actions retried
  safely.
  **What/why/how/expected:** Store mutation ID, actor/account, payload version, attempt count,
  eligibility deadline, and last error; apply exponential backoff with reachability as a hint;
  deduplicate server-side; stop retrying forecasts after their lock deadline and explain rejection.
- **P1.SYNC.1c — Add conflict, sign-out, and recovery flows.**
  **Summary/user story:** As a user, I want conflicts and account changes handled without hidden
  deletion.
  **What/why/how/expected:** Define mergeable profile fields, non-mergeable event fields, cache
  purge choices, orphaned-draft export, retry screen, and database recovery. Re-authentication
  resumes the outbox only for the same account.

**Dependencies:** P1.ID.1, F0.4, F0.6.
**Acceptance criteria:** offline draft survives relaunch; duplicate retry creates one server
mutation; two devices converge; expired lock is rejected truthfully; sign-out does not attach
queued work to another account.
**Evidence:** deterministic sync matrix tests, multi-device QA recording, migration/relaunch tests,
and content-free logs.
**Rollback/non-scope:** real-time collaboration is handled by group-feed work; this task establishes
correct eventual synchronization.

#### P1.SYNC.2 — Migrate existing users with explicit privacy choices

**Summary:** Ship the v2 data migration without loss, surprise upload, or fake social history.

**User story:** As an existing Hindsight user, I want all of my current decisions preserved and a
clear choice about whether any item syncs.

**Why:** Existing users have irreplaceable records. Automatic social conversion would destroy the
trust that makes Hindsight valuable.

**What:** Run the versioned local schema migration; present a post-upgrade explainer; default
legacy entries to local-only; allow opt-in private sync or explicit conversion into a new social
prediction; reconcile reminders and exports.

**How:** Take a recoverable backup, migrate in a transaction, record schema version and counts,
verify relationships/checksums, surface recovery UI on failure, and gate migration/upload features
independently.

**Expected result:** Upgraded users see the same journal history, correct reminders, and no network
copy until they choose one.

**Subtasks:**

- **P1.SYNC.2a — Build versioned migration and reconciliation.**
  **Summary/user story:** As an existing user, I want every decision, prediction, review, and
  reminder retained.
  **What/why/how/expected:** Add only necessary sync metadata, preserve IDs and timestamps, verify
  relationship counts, recreate derived indexes/reminders, and write a completion marker only
  after validation.
- **P1.SYNC.2b — Implement consent and conversion UI.**
  **Summary/user story:** As a privacy-conscious user, I want to choose local, privately synced,
  or explicitly social behavior per item.
  **What/why/how/expected:** Explain each scope in plain language, keep local as default, support
  bulk private-sync opt-in separately from social conversion, preview shared fields, and require
  confirmation.
- **P1.SYNC.2c — Test interruption and rollback.**
  **Summary/user story:** As a user whose upgrade is interrupted, I want the app to recover rather
  than reset.
  **What/why/how/expected:** Test low disk, process kill, malformed store, retry, backup export,
  rollback/kill switch, and reinstall restore using anonymized fixture stores from every supported
  release.

**Dependencies:** P1.SYNC.1, F0.6.
**Acceptance criteria:** zero fixture record loss; no migration network request before consent;
failed migration offers retry/export and never reports success; legacy exports remain readable.
**Evidence:** migration test matrix, before/after counts, network-capture assertion, and manual
upgrade video.
**Rollback/non-scope:** conversion does not claim the original local timestamp was a
server-verified social lock.

### Phase 1 bullet C — Private groups with invite links

#### P1.GRP.1 — Implement private group lifecycle and role-based access

**Summary:** Create secure private spaces with clear ownership, membership, and configurable
prediction rules.

**User story:** As a friend-group organizer, I want to create a private group and control who can
participate without managing a complicated community.

**Why:** Groups are the smallest environment where social prediction creates repeat value. Weak
authorization would expose private content or allow removed members to keep acting.

**What:** Support create, rename, description, avatar/icon, rules summary, owner/admin/member roles,
member list, leave, remove, transfer ownership, archive, and delete. Default maximum size and
rate limits are configurable.

**How:** Enforce every mutation server-side from membership rows; use transactions for ownership
transfer and last-owner checks; publish membership events; cache only visible group data; remove
access immediately on block/removal; retain audit records separately from visible content.

**Expected result:** A user can operate a private group confidently, and unauthorized clients
cannot enumerate or mutate it.

**Subtasks:**

- **P1.GRP.1a — Implement schema, policies, and APIs.**
  **Summary/user story:** As a member, I want only authorized people to retrieve group content.
  **What/why/how/expected:** Add groups/memberships/roles/statuses, authorization policies, list
  pagination, atomic ownership changes, audit events, and negative tests for nonmembers and removed
  members.
- **P1.GRP.1b — Build create/manage/archive UI.**
  **Summary/user story:** As an organizer, I want understandable controls for group identity and
  membership.
  **What/why/how/expected:** Implement form validation, role explanations, destructive-action
  confirmation, ownership transfer, archived read-only state, loading/offline/error views, and
  accessibility.
- **P1.GRP.1c — Define group rule presets.**
  **Summary/user story:** As a group, we want shared expectations about who can add and resolve
  predictions.
  **What/why/how/expected:** Provide named presets for open contribution, admin-created events,
  creator resolution, admin resolution, and group vote; show rules on join and event creation;
  persist versioned rule snapshots so later edits do not rewrite old events.

**Dependencies:** P1.ID.1, F0.4, F0.5.
**Acceptance criteria:** authorization suite covers each role/action; last owner cannot leave
without transfer/archive; removal revokes realtime/API access; rule version on an existing event is
immutable.
**Evidence:** policy tests, two-account role matrix, accessibility screenshots, and audit-log
sample.
**Rollback/non-scope:** public groups, chat, and nested organizations are not Phase 1.

#### P1.GRP.2 — Implement secure invite links and membership acceptance

**Summary:** Let members invite people through a revocable, expiring link without exposing the
group to token guessing or accidental membership.

**User story:** As a group member, I want to send one link that lets an intended friend preview and
join the right group.

**Why:** Invitations are both the acquisition engine and a security boundary. Reusable permanent
tokens leak; forced installation or lost deep-link context destroys conversion.

**What:** Create invite, preview, accept, decline, revoke, expire, usage-limit, and regenerate
flows; support authenticated and unauthenticated recipients; preserve invite context through
installation/sign-in.

**How:** Use high-entropy hashed tokens, short metadata-only preview endpoints, server-side expiry
and use limits, idempotent acceptance, universal-link route data, and rate-limited validation.
Never place privileged data or inviter email in the URL.

**Expected result:** A recipient reaches the correct group with minimal friction, while leaked or
revoked tokens cannot grant access.

**Subtasks:**

- **P1.GRP.2a — Implement invite token service.**
  **Summary/user story:** As an inviter, I want links that can be revoked and audited.
  **What/why/how/expected:** Generate cryptographically random tokens, store only hashes, attach
  group/creator/role/expiry/max-use, return safe preview data, enforce atomic usage, and audit
  create/view/accept/revoke without logging raw tokens.
- **P1.GRP.2b — Build invite preview and acceptance UX.**
  **Summary/user story:** As an invitee, I want to know who invited me and the group's rules before
  joining.
  **What/why/how/expected:** Show safe group name/icon, inviter display handle, member count, rules,
  expiry, join/sign-in action, and expired/revoked/full/already-member states. Resume after auth.
- **P1.GRP.2c — Add abuse controls and tests.**
  **Summary/user story:** As a user, I want unwanted invites stoppable without exposing whether my
  account exists.
  **What/why/how/expected:** Rate-limit creator/IP/device attempts, prevent token enumeration,
  honor blocks, support inviter report, and test replay/concurrent acceptance/token leakage.

**Dependencies:** P1.GRP.1, P1.ID.1; coordinates with Phase 2 universal links.
**Acceptance criteria:** revoked/expired/exhausted token cannot join; concurrent final use admits
one member; preview exposes only approved fields; auth/install round-trip preserves token; raw token
is absent from logs.
**Evidence:** security tests, two-device invite recording, log scan, and API contract fixtures.

### Phase 1 bullet D — Shared group predictions

#### P1.PRED.1 — Implement group event creation and forecast participation

**Summary:** Allow a group to build a common prediction list and let each member submit an
independent confidence-weighted forecast.

**User story:** As a group member, I want to add a clear future question and privately lock my own
answer so we can compare judgment later.

**Why:** This is the central social behavior. Treating responses as editable poll votes would
eliminate the timestamped-receipt value and bias later participants.

**What:** Support binary and 2–5 option events, close time, expected resolution time, objective
resolution criteria, creator, audience, participation count, forecast choice, confidence, and
optional private rationale. Enforce group rules about who may create.

**How:** Create event and outcome rows transactionally; validate time/order/text; snapshot group
rules; submit forecast with server timestamp and idempotency; encrypt/store private rationale under
the chosen visibility policy; hide responses and aggregates until permitted.

**Expected result:** A group maintains one shared list while every member has a distinct,
immutable, scoreable forecast.

**Subtasks:**

- **P1.PRED.1a — Build event creation contract and service.**
  **Summary/user story:** As a creator, I want the question and resolution rule clear enough to
  avoid arguments later.
  **What/why/how/expected:** Validate falsifiable prompt, mutually exclusive outcomes, close and
  resolution dates, resolver role, evidence rule, and visibility policy; add duplicate/rate checks;
  create atomically; return canonical server record.
- **P1.PRED.1b — Build event composer UI.**
  **Summary/user story:** As a group member, I want common defaults and progressive detail while
  still creating a fair event.
  **What/why/how/expected:** Reuse universal composer, preselect audience only from current group
  context, require outcome/resolution clarity, display rule summary, preserve failures, and preview
  what members will see.
- **P1.PRED.1c — Build forecast submission UI/service.**
  **Summary/user story:** As a participant, I want to choose an outcome and confidence without
  seeing others first.
  **What/why/how/expected:** Present event/rules/deadline, explicit outcome and confidence, optional
  private note, immutable-lock warning, submit state, server receipt, and late/retry handling.

**Dependencies:** P1.CAP.1, P1.GRP.1, P1.SYNC.1.
**Acceptance criteria:** unauthorized creation fails; outcomes are valid/distinct; forecasts stay
hidden; duplicate/late submission rejected; one member's response cannot overwrite another;
failure retains input.
**Evidence:** API/state-machine tests, Swift service/UI tests, concurrency test, and two-account
recording.

#### P1.PRED.2 — Build the realtime group prediction feed and participation states

**Summary:** Present the group’s common list with timely, privacy-preserving status updates.

**User story:** As a member, I want to see what is open, what I have answered, and what is ready to
reveal without searching through a chat thread.

**Why:** A group list is only useful if it remains comprehensible as events accumulate. Showing
vote distributions early would anchor participants and weaken independent forecasting.

**What:** Add Open, Your Call Locked, Closing Soon, Awaiting Resolution, Revealed, Disputed, and
Voided sections/filters; realtime participant-count updates; paginated history; search; notification
entry routes; and offline cached state.

**How:** Subscribe to content-free event/member updates, reconcile through delta sync, derive UI
state from canonical timestamps/statuses, redact aggregate results until visibility unlock, and
show stale/offline indicators.

**Expected result:** Members immediately know their next action and never infer hidden forecasts
from premature aggregates.

**Subtasks:**

- **P1.PRED.2a — Implement feed query/read model.**
  **Summary/user story:** As a member of a busy group, I want a fast, stable ordered list.
  **What/why/how/expected:** Create indexed cursor queries, user-participation join, status/time
  sort, archived pagination, and visibility-safe DTOs. Load tests establish target latency.
- **P1.PRED.2b — Implement adaptive feed UI.**
  **Summary/user story:** As a member, I want each card to state deadline, my participation, and
  next action clearly.
  **What/why/how/expected:** Build accessible cards, filters, skeleton/empty/error/offline states,
  pull-to-refresh, deep-link focus, and creator/admin affordances; avoid color-only status.
- **P1.PRED.2c — Implement realtime reconciliation.**
  **Summary/user story:** As a participant, I want counts and status to update without duplicate or
  reordered cards.
  **What/why/how/expected:** Deduplicate by event/version, buffer out-of-order messages, refetch on
  gaps, reconnect with cursor, and foreground refresh. Push/realtime content excludes private
  question text by default.

**Dependencies:** P1.PRED.1, P1.SYNC.1.
**Acceptance criteria:** hidden aggregates cannot be retrieved through feed/API; reconnect
converges; pagination has no duplicates/gaps; removed member loses feed; all feed states pass
accessibility/responsive tests.
**Evidence:** authorization snapshot tests, realtime disorder tests, 1k-event load result, and
multi-device video.

### Phase 1 bullet E — Locked entries and resolution

#### P1.LOCK.1 — Implement the immutable forecast ledger and Receipt identity

**Summary:** Make server-confirmed forecasts tamper-evident and clearly distinguish drafts from
locked records.

**User story:** As a participant, I want proof of exactly what I predicted and when, even if I was
wrong.

**Why:** The product’s emotional and competitive value depends on trustworthy historical truth.
Mutable rows or client timestamps would make every leaderboard and Receipt disputable.

**What:** Store canonical forecast payload, confidence, user/event IDs, server timestamp, schema
version, client idempotency key, and integrity digest; permit pre-close replacement only through an
explicit revision policy; append notes without changing forecast content.

**How:** Use one transactional server command; compare server time to lock time; enforce unique
member/event active forecast; append audit events; calculate digest over canonical fields; return
a stable Receipt ID; expose a read-only detail DTO.

**Expected result:** A participant, resolver, or moderator can reconstruct the exact locked record
and see any allowed pre-lock revision history.

**Subtasks:**

- **P1.LOCK.1a — Implement atomic lock/revision command.**
  **Summary/user story:** As a forecaster, I want rapid retries to create one canonical lock.
  **What/why/how/expected:** Validate membership/event state/deadline, enforce idempotency and
  uniqueness, write forecast plus audit event, and return existing result for safe retries.
  Concurrent/late replacements follow the ratified policy.
- **P1.LOCK.1b — Implement locked-detail model and UI.**
  **Summary/user story:** As a user, I want to see statement, answer, confidence, timestamp, and
  visibility in one premium receipt.
  **What/why/how/expected:** Render canonical values, timezone-aware display, lock badge,
  participant visibility, revision history, evidence rule, and server/offline status; never imply
  cryptographic notarization beyond the actual implementation.
- **P1.LOCK.1c — Audit integrity and recovery.**
  **Summary/user story:** As an operator, I need attempted tampering detected without exposing
  content broadly.
  **What/why/how/expected:** Add immutable audit permissions, digest verification job, anomaly
  metric, backup/restore reconciliation, and incident procedure for a mismatch.

**Dependencies:** P1.PRED.1, F0.4, F0.7.
**Acceptance criteria:** concurrent duplicate submissions yield one lock; DB/client attempts cannot
rewrite confirmed content; digest verification passes after restore; UI distinguishes queued from
locked.
**Evidence:** transaction/concurrency/security tests, restored-backup check, and Receipt screenshot.

#### P1.RES.1 — Implement rule-based resolution, reveal, void, and dispute handling

**Summary:** Resolve private-group predictions with transparent evidence and controlled correction.

**User story:** As a participant, I want the agreed outcome applied consistently and a way to
challenge an honest mistake.

**Why:** Group competition becomes corrosive when the creator can silently choose a favorable
answer or rewrite a resolution. A rigid system with no correction path is also unsafe.

**What:** Support creator/admin resolution or group-vote resolution according to the event’s
snapshotted rule; evidence note/link; reveal time; abstain; void; dispute; correction with
superseding version; participant notification; and score recomputation.

**How:** Authorize resolution server-side; require one listed outcome or documented void reason;
write append-only resolution versions; open a bounded dispute window; freeze affected score rows
during dispute; recompute idempotently; show previous and corrected states.

**Expected result:** Every member sees the same outcome, evidence, score effect, and correction
history.

**Subtasks:**

- **P1.RES.1a — Implement resolution state machine/API.**
  **Summary/user story:** As an authorized resolver, I want to submit the outcome once with
  evidence.
  **What/why/how/expected:** Enforce timing/role/rule, validate outcome/void reason, create
  resolution version and reveal event atomically, and reject duplicates or incompatible state.
- **P1.RES.1b — Implement group-vote and dispute paths.**
  **Summary/user story:** As a member, I want the group’s chosen process honored and a bounded
  appeal when evidence is wrong.
  **What/why/how/expected:** Define quorum/tie/deadline/abstention, anonymous or named vote policy,
  one active dispute per user/event, evidence submission, admin decision, correction version, and
  abuse limits.
- **P1.RES.1c — Build reveal experience and notifications.**
  **Summary/user story:** As a participant, I want a satisfying reveal that explains outcome and
  score without shaming misses.
  **What/why/how/expected:** Show actual outcome, each permitted forecast, confidence, score delta,
  group distribution, evidence, dispute status, and next action; use generic lock-screen
  notification content and accessible/reduced-motion reveal.

**Dependencies:** P1.LOCK.1, P1.GRP.1, scoring contract P1.SCORE.1.
**Acceptance criteria:** only authorized resolution succeeds; exact rule version is used; duplicate
resolution is idempotent; disputes freeze/recompute score; voids do not count as losses; all
participants converge.
**Evidence:** state-transition and permission tests, scoring-recompute fixture, two-device reveal
recording, and notification/deep-link physical test.

### Phase 1 bullet F — Group leaderboard and personal calibration

#### P1.SCORE.1 — Ratify and implement fair scoring and sample gates

**Summary:** Create a documented Foresight Score that rewards honest probabilistic forecasting
without favoring volume, certainty, or easy questions.

**User story:** As a participant, I want rankings to reflect forecasting skill so the competition
feels credible.

**Why:** “Percent correct” can be gamed by choosing obvious events and gives no credit for calibrated
uncertainty. An opaque score will be distrusted even if mathematically sound.

**What:** Define binary and multiclass proper scoring, display scale, minimum sample, recency
windows, eligibility, void/dispute treatment, ties, provisional status, confidence bands, and
explanatory copy. Recommended internal primitives are Brier components plus calibration and
resolution-discipline facts; a user-facing 0–100 transform must be monotonic and versioned.

**How:** Product/data review golden fixtures and adversarial strategies; server calculates from
resolved canonical records; store scoring version and components; never recalculate historical
seasons under a new formula without an explicit versioned migration.

**Expected result:** A curious user can understand why their rank changed, and gaming strategies
are measurably less rewarding than honest probabilities.

**Subtasks:**

- **P1.SCORE.1a — Write scoring specification and golden fixtures.**
  **Summary/user story:** As a user, I want the same inputs to produce the same score everywhere.
  **What/why/how/expected:** Define formula, rounding, binary/multiclass examples, n gates,
  provisional reliability tiers, excluded outcomes, and version migration; publish exact input and
  expected-output fixtures.
- **P1.SCORE.1b — Simulate gaming and fairness.**
  **Summary/user story:** As a competitor, I want honest uncertainty to beat indiscriminate 100%
  claims.
  **What/why/how/expected:** Simulate always-50, always-100, safe-event selection, low-volume luck,
  abstention, collusion, and late-entry strategies; adjust eligibility/boards rather than corrupting
  the proper score.
- **P1.SCORE.1c — Implement versioned scoring engine.**
  **Summary/user story:** As a participant, I want score changes derived only from canonical
  resolutions.
  **What/why/how/expected:** Build deterministic pure calculation plus server aggregation,
  recomputation jobs, scoring-version storage, atomic update, and audit components. Client displays
  but does not author rank.

**Dependencies:** F0.4, P1.LOCK.1; blocks public leaderboards.
**Acceptance criteria:** golden fixtures exact; invalid/void/disputed records excluded; simulated
gaming reviewed; client/server results match; score shows sample size/version/explanation.
**Evidence:** specification, property/golden tests, simulation report, and API contract.

#### P1.SCORE.2 — Build group leaderboard and personal/group analytics

**Summary:** Show individual performance against group-level calibration with honest context.

**User story:** As a group member, I want to see who forecasts well, how the group performs
together, and what my own blind spots are.

**Why:** This is the repeatable social payoff, but a bare rank encourages status anxiety and gives
no insight into improvement.

**What:** Add group board with Foresight Score, rank movement, resolved count, reliability tier,
calibration gap, and selected time window; group consensus accuracy/calibration; personal
confidence-band facts; drill-through to eligible events; insufficient-data states.

**How:** Use server materialized aggregates keyed by scoring version/window; authorize private group
membership; return components/denominators; cache and paginate; visually separate provisional and
established members; use neutral, sample-aware language.

**Expected result:** Members have a compelling reason to return after each reveal and can explain
the evidence behind a rank.

**Subtasks:**

- **P1.SCORE.2a — Implement aggregation queries/jobs.**
  **Summary/user story:** As a member, I want leaderboard data to update once after a resolution.
  **What/why/how/expected:** Compute per-user and group aggregates idempotently; support week/month/
  season/all-time windows; handle membership leave/block, correction, void, and version; measure
  freshness and query latency.
- **P1.SCORE.2b — Build premium leaderboard UI.**
  **Summary/user story:** As a competitor, I want rank, evidence, and movement presented clearly
  without humiliating low performers.
  **What/why/how/expected:** Create podium/list variants, “you” anchoring, reliability badges,
  sample counts, tie handling, filter, accessible score explanation, offline/stale state, and
  share-safe snapshot.
- **P1.SCORE.2c — Build personal-versus-group insight.**
  **Summary/user story:** As a learner, I want facts such as “your 80% calls land 58%; this group’s
  land 71%.”
  **What/why/how/expected:** Calculate comparable cohorts with minimum n, show confidence interval/
  uncertainty copy and exact denominators, offer event drill-through, and suppress directional
  claims below thresholds.

**Dependencies:** P1.SCORE.1, P1.RES.1.
**Acceptance criteria:** correction/void updates once; nonmember cannot query; rank ties stable;
every claim has n and drill-through; provisional users cannot appear “#1 globally” from one call;
largest text remains usable.
**Evidence:** aggregate fixture tests, authorization tests, snapshot/UI tests, and explainability
review.

### Phase 1 bullet G — Shareable Receipt cards

#### P1.RCPT.1 — Build privacy-safe sealed and revealed Receipt artifacts

**Summary:** Turn locked predictions and results into beautiful, trustworthy social objects that
users want to share.

**User story:** As a user, I want to share proof of my call or a surprising calibration fact
without accidentally exposing private group content.

**Why:** Receipts are the clearest organic distribution mechanism and make Hindsight’s value
visible outside the app.

**What:** Design sealed, revealed-correct, revealed-miss, group-summary, and personal-insight cards;
support explicit field selection, group permission, pseudonym/display-name choice, redaction,
watermark/brand, dynamic link, and accessible share text.

**How:** Render deterministic SwiftUI views to high-resolution images; derive displayed values from
canonical server DTOs; default group prompt/member names off unless allowed; preview exact artifact
before share; use neutral copy; attach link only if its destination is authorized for recipients.

**Expected result:** Shared content communicates “locked before the result” and invites
participation while preserving visibility boundaries.

**Subtasks:**

- **P1.RCPT.1a — Define card content/permission matrix.**
  **Summary/user story:** As a private-group member, I want sharing controls to match group rules.
  **What/why/how/expected:** List fields for each artifact and audience, default redactions,
  member-name consent, deleted/blocked behavior, watermark claims, localization, and accessibility
  alternative text. API returns share capability, not client-inferred permission.
- **P1.RCPT.1b — Implement card renderer and preview.**
  **Summary/user story:** As a sharer, I want the exported card to match the preview across devices.
  **What/why/how/expected:** Build fixed share canvas using design tokens, long-text limits,
  localization, light/dark branded themes, image rendering tests, preview controls, and graceful
  fallback when avatar/network assets fail.
- **P1.RCPT.1c — Implement share flow and attribution.**
  **Summary/user story:** As a recipient, I want a clear call to view or join without receiving
  hidden content.
  **What/why/how/expected:** Present system share sheet, generated accessible message, authorized
  universal link, attribution token that contains no PII, cancel/success handling, and
  content-free share/open/conversion events.

**Dependencies:** P1.LOCK.1, P1.RES.1, P1.SCORE.2, Phase 2 link contract may enhance destination.
**Acceptance criteria:** private fields absent by default; server denies unauthorized link content;
image snapshots pass; long/localized text does not clip; cancelled share is not counted as
published; destination handles installed/not-installed/removed-access states.
**Evidence:** permission matrix tests, snapshot suite, exported VoiceOver share text, and link
security tests.
**Rollback/non-scope:** Phase 1 may share static cards without a public web preview; public indexing
is prohibited.

## 6. Phase 2 — Viral Distribution

**Phase objective:** Make sending, accepting, returning to, and recapping predictions natural in
the channels where friends already debate outcomes.

**Entry gate:** Phase 1 private-group loop is stable in QA; invitation and Receipt conversion
baseline measured; support/moderation route staffed.
**Exit gate:** iMessage and universal-link flows survive install/auth; weekly recap and direct
challenge create measurable reactivation; friend privacy/blocks work end to end.

### Phase 2 bullet A — iMessage app

#### P2.MSG.1 — Build the iMessage challenge experience

**Summary:** Let people create, send, accept, and revisit Hindsight predictions from the
conversation where the debate already happens.

**User story:** As an iMessage user, I want to challenge the conversation and make my call with
minimal context switching so forecasting feels native to messaging.

**Why:** iMessage is a high-intent acquisition channel. A recipient already understands the social
context; a generic App Store page would discard that advantage.

**What:** Add a Messages extension with compact/expanded states, create or select prediction,
render rich message, preview open challenge, and hand off securely to the main app for
authentication or lock submission when required.

**How:** Keep the extension thin; reuse a shared domain/network package; encode only signed opaque
IDs in `MSMessage` URLs; share non-secret configuration through an approved App Group; preserve
context through universal links; update message layout for open/locked/resolved without revealing
hidden answers.

**Expected result:** A sender creates a challenge in seconds and installed or new recipients reach
the correct blind response flow.

**Subtasks:**

- **P2.MSG.1a — Define extension boundaries and entitlements.**
  **Summary/user story:** As a maintainer, I want the constrained extension isolated from the main
  store and secrets.
  **What/why/how/expected:** Specify extension target, shared package, App Group files, Keychain
  decision, environment config, memory/launch budget, and handoff cases. The extension treats
  state as disposable and cannot corrupt SwiftData.
- **P2.MSG.1b — Implement message composition.**
  **Summary/user story:** As a sender, I want to send an existing or new challenge with a
  recognizable card.
  **What/why/how/expected:** Reuse outcome/deadline contract, request an opaque challenge link,
  build accessible `MSMessageTemplateLayout`, preserve drafts on failure, and never embed answer,
  confidence, private note, group token, or auth material.
- **P2.MSG.1c — Implement recipient and reveal routing.**
  **Summary/user story:** As a recipient, I want the message to open the unanswered call, then
  return to the reveal later.
  **What/why/how/expected:** Resolve safe preview, route installed/logged-in directly, hand off
  install/auth, handle forwarded/expired/revoked/already-answered states, and refresh message
  summary after lock/reveal without leaking hidden content.
- **P2.MSG.1d — Harden and prepare App Review evidence.**
  **Summary/user story:** As the release owner, I want the extension stable and accurately
  disclosed.
  **What/why/how/expected:** Test extension lifecycle/memory, older supported iOS, offline/auth
  expiry, payload tampering, VoiceOver compact/expanded modes, signing/App Group isolation, store
  copy, and reviewer instructions.

**Dependencies:** P2.LINK.1, P2.CHAL.1, P1.RCPT.1, P1.ID.1.
**Acceptance criteria:** payload contains opaque IDs only; forwarded link does not transfer
authorization; hidden answers remain hidden; submit is idempotent/server-confirmed; no-app and
auth-expired paths recover; extension build/sign/device tests pass.
**Evidence:** Messages unit/UI tests, two-physical-device conversation recording, memory profile,
tampering test, signing/entitlement inspection, and App Review checklist.
**Rollback/non-scope:** extension is independently feature-flagged; disabling it does not break
universal links or main-app challenges.

### Phase 2 bullet B — Universal links and invite landing flow

#### P2.LINK.1 — Implement secure cross-install routing and web landing pages

**Summary:** Make group invites, challenges, Receipts, and results open the correct destination
across installed, uninstalled, signed-out, expired, and revoked states.

**User story:** As a recipient, I want one tap to explain the invitation and preserve it through
installation or sign-in.

**Why:** A viral loop is only as strong as its least reliable link transition. Unsafe previews can
also leak private group information to crawlers or forwarded recipients.

**What:** Define route taxonomy, environment-specific domains/AASA, typed iOS router, safe
server-rendered landing pages, App Store continuation, authenticated action, expiry/revocation,
OpenGraph metadata, and privacy-safe attribution.

**How:** Use opaque routes such as `/invite/{token}`, `/challenge/{id}`, and `/r/{id}`; validate
host/version/token server-side; store one pending destination across auth; use a recoverable join
code or explicit link reopen after install; prohibit clipboard fingerprinting and invasive deferred
deep-link tricks.

**Expected result:** Links consistently reach the intended safe projection and never become an
authorization bypass.

**Subtasks:**

- **P2.LINK.1a — Publish versioned route contract.**
  **Summary/user story:** As a client engineer, I want every source to construct the same valid
  route.
  **What/why/how/expected:** Define route type, ID/token, auth need, preview fields, expiry,
  consumption, post-auth destination, environment, and stable error mapping; generate table-driven
  parser tests.
- **P2.LINK.1b — Configure trusted domains and typed router.**
  **Summary/user story:** As an installed user, I want cold/warm links to open exactly once in the
  correct build.
  **What/why/how/expected:** Host exact AASA files, add Associated Domains per environment, parse
  into typed routes, retain/consume one pending intent, and handle onboarding/auth/navigation
  restoration.
- **P2.LINK.1c — Build safe web fallback and continuation.**
  **Summary/user story:** As a non-user, I want to understand the invite and continue after
  install.
  **What/why/how/expected:** Render allowlisted preview, inviter handle when permitted, rules,
  expiry/error state, App Store CTA, accessible web UI, `noindex` private pages, and a
  non-fingerprinting continuation.
- **P2.LINK.1d — Secure and instrument the funnel.**
  **Summary/user story:** As the product owner, I want routing failures visible without tracking
  recipients across contexts.
  **What/why/how/expected:** Rate-limit/token-protect preview/action, reject cross-environment
  routes, log link type/result/error only, and measure open→auth→join/forecast with short-lived
  non-PII attribution.

**Dependencies:** P1.GRP.2, P1.RCPT.1, F0.7.
**Acceptance criteria:** cold/warm/auth/install matrix passes; private pages disclose only
allowlisted fields and are `noindex`; invalid/tampered/cross-environment routes fail closed;
destination consumed once; no pasteboard/fingerprinting.
**Evidence:** AASA CI validation, URL parser matrix, web security/accessibility scan, physical
Safari/Messages/Mail/QR tests, and attribution privacy test.

### Phase 2 bullet C — Weekly group recap

#### P2.RECAP.1 — Generate and deliver deterministic weekly group stories

**Summary:** Turn completed predictions into a fun, traceable weekly recap with surprises,
standings movement, and upcoming calls.

**User story:** As a group member, I want one concise weekly story so our resolved calls spark
conversation and bring us back.

**Why:** A recurring recap aggregates many small events into a memorable payoff without requiring
an empty daily streak.

**What:** Define recap eligibility, highlight selection, copy templates, period/timezone,
in-app story, push delivery, privacy-safe share, source drill-through, correction behavior, and
per-group controls.

**How:** Generate from finalized, undisputed records using deterministic rules; store source IDs
and calculation version; select highlights such as highest-confidence surprise, best calibrated
call, closest split, and rank change only when sample/privacy gates permit; use approved templates,
not generative factual claims.

**Expected result:** Eligible groups receive one accurate recap per period and can verify every
claim.

**Subtasks:**

- **P2.RECAP.1a — Define eligibility and highlight engine.**
  **Summary/user story:** As a member, I want a recap that never fabricates significance.
  **What/why/how/expected:** Specify group timezone/week boundary, minimum events/members, excluded
  states, late corrections, deterministic ranking/ties, sample gates, and quiet-week fallback;
  output stored fact objects with source references.
- **P2.RECAP.1b — Build templates and premium story UI.**
  **Summary/user story:** As a viewer, I want delightful pacing and factual context.
  **What/why/how/expected:** Create summary, surprise, standings, personal takeaway, upcoming
  prompts, rematch/share cards; show denominators and early-signal language; add drill-through,
  reduced motion, VoiceOver order, and static fallback.
- **P2.RECAP.1c — Schedule, notify, share, and repair.**
  **Summary/user story:** As a member, I want exactly one recap at a useful time and control over
  delivery.
  **What/why/how/expected:** Run idempotent group/week job, create in-app inbox item before optional
  generic push, honor quiet hours/mutes, build group-permitted redacted share projection, and mark
  or regenerate after corrected resolution.

**Dependencies:** P1.RES.1, P1.SCORE.2, P1.RCPT.1.
**Acceptance criteria:** only finalized/eligible facts included; every claim drills through;
duplicate job delivers once; correction is visible; per-group mute works; external projection
requires policy/preview.
**Evidence:** golden weekly fixtures, DST/timezone/idempotency tests, correction tests, snapshot/
accessibility review, and retention/fatigue event dashboard.

### Phase 2 bullet D — Challenge a friend

#### P2.CHAL.1 — Build a blind head-to-head prediction loop

**Summary:** Let one user challenge one intended person, compare independent forecasts, reveal,
resolve, rematch, and build a shared record.

**User story:** As a user debating a friend, I want to lock both calls before seeing the other
person’s answer so the result is fair and fun.

**Why:** A direct challenge has clear urgency and recipient intent, making it the strongest
person-to-person growth loop.

**What:** Support draft, sent, viewed, accepted/declined/expired/revoked, both locked, forecast
reveal, outcome resolved, rematch, head-to-head history, receive settings, block, and report.

**How:** Reuse group event/forecast/resolution/scoring primitives with a strict two-member
authorization policy; challenger locks first; recipient receives only safe identity/question/rules;
reveal forecasts after both lock or deadline according to the declared policy; score after the
actual outcome.

**Expected result:** A completed challenge naturally offers rematch, add-to-group, or Receipt share
without automatic spam.

**Subtasks:**

- **P2.CHAL.1a — Define and implement challenge state machine.**
  **Summary/user story:** As either party, I want status and available actions predictable.
  **What/why/how/expected:** Specify actors, transitions, deadlines, cancellation, decline,
  revocation, expiration, one intended recipient, idempotency, notifications, and audit; enforce
  through server commands.
- **P2.CHAL.1b — Build sender/recipient blind UX.**
  **Summary/user story:** As a recipient, I want the question and sender identity without seeing
  the sender’s call.
  **What/why/how/expected:** Reuse composer/share routes, show safe preview, explicit outcome and
  confidence, server-confirmed lock, failure recovery, accessible deadline, decline/block/report,
  and no-early-reveal negative tests.
- **P2.CHAL.1c — Build reveal, resolution, rematch, and history.**
  **Summary/user story:** As friends, we want a satisfying comparison and meaningful rivalry over
  common events.
  **What/why/how/expected:** Reveal timestamps/answers/confidence side by side, resolve through
  shared rules, show score changes, offer explicit rematch/group/share, and calculate head-to-head
  facts only from common finalized items with sample counts.

**Dependencies:** P1.PRED.1, P1.LOCK.1, P1.RES.1, P1.SCORE.1, P2.LINK.1.
**Acceptance criteria:** only designated recipient accepts; forwarding grants no authority; sender
answer unretrievable pre-reveal; block/decline/expiry suppress actions; head-to-head excludes
disputed/void and shows n; rematch never auto-sends.
**Evidence:** state/authorization/early-reveal tests, forwarded-link test, two-device E2E, deadline
race, notification audit, and no-app recipient usability test.

### Phase 2 bullet E — Friend profiles and reliability badges

#### P2.SOC.1 — Implement consent-based friends, profiles, discovery, and evidence tiers

**Summary:** Add recognizable social identity and credibility without exposing private history or
creating a follower-popularity contest.

**User story:** As a user, I want to add known people and understand how much forecasting evidence
supports their displayed stats.

**Why:** Groups and challenges need identity. Reliability must communicate sample strength, not
imply intelligence or social status from a lucky handful of calls.

**What:** Implement handle/display profile, privacy settings, exact-handle/link/shared-group
discovery, friend request lifecycle, remove/block/report, viewer-specific stats, and versioned
Learning/Emerging/Established/Proven evidence badges.

**How:** Separate auth identity from profile; normalize and reserve handles; avoid address-book
upload in Phase 2; build server-side viewer projections; derive badges from eligible resolved sample
and participation; exclude personal/local and unrelated private-group data.

**Expected result:** Users can safely form a friend graph and interpret another person’s public or
shared track record honestly.

**Subtasks:**

- **P2.SOC.1a — Build profile schema, editor, and privacy.**
  **Summary/user story:** As a member, I want a chosen handle/avatar/bio with clear visibility.
  **What/why/how/expected:** Define normalized unique handle, display name, avatar processing,
  bio/moderation, field visibility, rename limits, safe defaults, deleted/suspended state, and
  viewer projection; strip image metadata and test homographs.
- **P2.SOC.1b — Build friendship and safe discovery.**
  **Summary/user story:** As a user, I want to find known people without uploading contacts.
  **What/why/how/expected:** Add exact-handle search, QR/link, optional shared-group suggestion,
  request/accept/decline/cancel/remove/block/report, rate limits, notifications, and concurrent
  transition handling.
- **P2.SOC.1c — Build profile statistics and reliability badges.**
  **Summary/user story:** As a viewer, I want evidence volume and authorized common performance
  explained.
  **What/why/how/expected:** Show eligible resolved n, time range, calibration facts and common
  group performance only where allowed; apply versioned thresholds; explain every badge; show
  progress rather than zero rank below gate.
- **P2.SOC.1d — Build premium profile UI and lifecycle behavior.**
  **Summary/user story:** As a viewer, I want identity, shared context, credibility, and actions
  legible at a glance.
  **What/why/how/expected:** Lay out avatar/name/reliability/shared groups/permitted stats and
  friend/challenge/block/report actions; handle former friend, deleted historical participant,
  hidden stats, offline, errors, accessibility, and Dynamic Type.

**Dependencies:** P1.ID.1, P1.GRP.1, P1.SCORE.2, P2.CHAL.1.
**Acceptance criteria:** server projection enforces viewer access; contact upload absent; block
immediately stops discovery/challenges/notifications as defined; badge shows rule and n; private
local/unshared group calls excluded; deleted/suspended history follows policy.
**Evidence:** field-level privacy matrix tests, handle/homograph/rate tests, friendship race and
block E2E tests, badge golden fixtures, profile privacy snapshots, and accessibility audit.

## 7. Phase 3 — Public Network

**Phase objective:** Offer curated, objectively resolvable public predictions and trustworthy
competition at category, city, and global scales.

**Entry gate:** Phase 2 safety/support flows stable; public content policy and age posture approved;
event operations staffed; penetration/load/backup readiness.
**Exit gate:** At least one curated category completes multiple event cycles with correct locking,
resolution, correction, scoring, moderation, and no critical integrity incident.

### Phase 3 bullet A — Curated verified public events

#### P3.EVT.1 — Build the public-event lifecycle and integrity ledger

**Summary:** Create a server-authoritative, append-only history for every public event, forecast,
resolution, correction, score, and publication action.

**User story:** As a public participant, I want proof that rules, deadlines, forecasts, and outcomes
were not silently altered.

**Why:** Public competition collapses if administrators can rewrite prompts, users can enter late,
or corrections erase the original record.

**What:** Add draft, scheduled, open, locked, awaiting-result, provisional, final, cancelled,
voided, and corrected states; versioned rules; audit/domain events; transactional outbox; optimistic
concurrency; replay and reconciliation.

**How:** Write current state and append-only domain event atomically; use aggregate sequence/version,
actor, request ID, server UTC time, schema version, and sanitized payload; process side effects
idempotently; corrections append compensating events and score reversals.

**Expected result:** Any public event can be reconstructed and audited, and current read models can
be rebuilt safely.

**Subtasks:**

- **P3.EVT.1a — Model states, transitions, and invariants.**
  **Summary/user story:** As an operator, I want only legal lifecycle actions available.
  **What/why/how/expected:** Define actor/preconditions/side effects/errors for publish, open, lock,
  accept forecast, propose/finalize/correct/void; implement constraints and concurrency guards;
  invalid transitions make no partial write.
- **P3.EVT.1b — Implement ledger and outbox.**
  **Summary/user story:** As an auditor, I want a durable record of consequential changes.
  **What/why/how/expected:** Store immutable domain events in the same transaction as current state,
  deliver through retry/dead-letter outbox, expose sanitized internal timeline, audit audit-log
  access, and monitor lag/replay mismatches.
- **P3.EVT.1c — Implement replay, migration, and recovery.**
  **Summary/user story:** As the release owner, I want backup restore to reproduce event and score
  state.
  **What/why/how/expected:** Build versioned up/expand/contract migrations, replay utility,
  compatibility with supported clients, checksum reconciliation, backup restore drill, and
  correction-safe rebuild.

**Dependencies:** Phase 1 integrity primitives, F0.7.
**Acceptance criteria:** concurrency cannot create two finals; every accepted public forecast has
ledger event; correction retains prior result; replay matches aggregate; payload has no tokens,
precise location, private notes, or raw IP.
**Evidence:** transition/concurrency/atomicity/replay tests, migration rollback/restore report, and
outbox dashboards.

#### P3.EVT.2 — Build curated event authoring, discovery, and public forecasting

**Summary:** Supply a premium catalog of objective binary/multiple-choice events and a fast,
server-locked forecasting experience.

**User story:** As a user, I want interesting questions with unambiguous rules so I can make a
credible public call without searching through spam.

**Why:** Event quality is the supply side of the network. Freeform public creation creates
ambiguity, unsafe content, copyrighted copying, and resolution disputes before operations can
handle them.

**What:** Implement category/outcome/source/rule schema; two-person admin author/review/publish;
search/filter/editorial rails; event detail; saved events; one-screen outcome/confidence lock;
receipt; cancellation/void states; stable pagination and server time.

**How:** Require exact question, mutually exclusive outcomes, opens/locks/resolves, source priority,
tie/ambiguity/void handling before publish; freeze published rules; allow versioned correction
notice; return visibility-safe DTOs; validate and accept forecast in one transaction.

**Expected result:** Users find fresh events, understand the contract, submit in roughly three
actions, and receive a canonical Receipt.

**Subtasks:**

- **P3.EVT.2a — Build structured editorial service.**
  **Summary/user story:** As an editor, I want templates and review gates that prevent ambiguous
  publication.
  **What/why/how/expected:** Add category/outcome/resolution/source fields, draft preview parity,
  propose/review/approve/schedule/cancel actions, two-person approval, conflict rules, revision
  notice, link sanitization, and deterministic QA fixtures.
- **P3.EVT.2b — Build discovery API and Explore UI.**
  **Summary/user story:** As a forecaster, I want Closing Soon, New, Saved, Friends, category, and
  local rails that stay fast and honest.
  **What/why/how/expected:** Implement indexed cursor queries and filters, editorial server
  configuration, stable pagination, search, skeleton/empty/offline/cancelled states, accessible
  cards/details, and no engagement-ranking black box in the initial release.
- **P3.EVT.2c — Build public forecast submission.**
  **Summary/user story:** As a user, I want outcome, confidence, and Lock My Call to be the entire
  critical path.
  **What/why/how/expected:** Validate server event/version/time in one transaction, use
  idempotency, one active forecast per user/event, audited pre-lock revision policy, safe uncertain
  network reconciliation, delayed/hidden community aggregates to reduce herding, and no false
  offline lock.

**Dependencies:** P3.EVT.1, P1.LOCK.1, content policy.
**Acceptance criteria:** cannot publish without rule/source; published rules cannot silently edit;
server rejects after deadline; retry returns same forecast; device never claims lock before ack;
feed pagination stable; cancelled/void cannot accept entries.
**Evidence:** schema/admin permission tests, 25-event ambiguity review, boundary/race tests, feed
load/UI snapshots, and ledger-matched Receipt.

#### P3.RES.1 — Operate verified resolution, evidence, disputes, and corrections

**Summary:** Resolve public events from authoritative evidence using separation of duties and a
transparent correction process.

**User story:** As a participant, I want to see exactly why an event resolved and know mistakes can
be corrected without hidden history edits.

**Why:** One confidently wrong or opaque public resolution damages trust across every leaderboard.

**What:** Add evidence ingestion, source priority, proposal, independent approval, provisional
window, finalization, structured dispute, delay, void, correction, score reversal/recompute,
notification, and “How this was resolved.”

**How:** Snapshot permitted source facts/hash/retrieval time; treat URLs as untrusted; require
proposer and approver to differ; prefer delayed/void over speculative outcome; append corrected
resolution; freeze affected public ranks until final.

**Expected result:** Resolution is timely, explainable, appealable, and exactly reproducible.

**Subtasks:**

- **P3.RES.1a — Implement evidence and dual-approval workflow.**
  **Summary/user story:** As an operator, I want source-backed settlement that I cannot
  self-approve.
  **What/why/how/expected:** Model proposal/evidence/decision, source allowlist/adapters,
  SSRF/malware protections, step-up auth, proposer≠approver rule, timeouts, and provisional result.
- **P3.RES.1b — Implement disputes, voids, and corrections.**
  **Summary/user story:** As a participant, I want a structured appeal that preserves privacy and
  score integrity.
  **What/why/how/expected:** Accept reason/source, rate-limit brigading, keep reporter private,
  freeze score, decide uphold/void/correct, append reversal/new score once, notify affected users,
  and retain public correction history.
- **P3.RES.1c — Build operator and public evidence views.**
  **Summary/user story:** As an operator/user, I want pending work and final reasoning visible at
  the right privilege.
  **What/why/how/expected:** Build queue by unresolved age/priority/source failure, assignment/SLA/
  escalation, and a public accessible summary with rule version, final outcome, authoritative
  links, dates, and corrections.

**Dependencies:** P3.EVT.1–2, scoring P3.SCORE.1.
**Acceptance criteria:** manual result cannot self-approve; ambiguous event can void without
penalty; correction recalculates once; evidence retained and sanitized; public view distinguishes
provisional/final/corrected/void.
**Evidence:** normal/delayed/conflicting/void/dispute/correction fixtures, source failure injection,
permission tests, score reconciliation, and timed operations tabletop.

### Phase 3 bullet B — City and global leaderboards

#### P3.SCORE.1 — Version public scoring and publish global leaderboards

**Summary:** Rank eligible users through proper scoring, shared event opportunities, sample
reliability, and transparent snapshots.

**User story:** As a public forecaster, I want global rank to reward calibrated skill and explain
why I qualify and move.

**Why:** One lucky call, selective participation, or constant 100% predictions must not create a
credible-looking expert.

**What:** Define scoring version, public eligibility, common pool/coverage, Brier score for binary
and multiclass forecasts, shrinkage for cross-event global rank, deterministic ties, Emerging/
Established/Proven status, period/season snapshots, score explanation, correction rebuild, opt-out,
and around-me query.

**How:** Compute from finalized verified public events only; store full-precision ledger
components; freeze formula within season; build materialized immutable snapshots; require sample,
coverage, account standing, and integrity clearance; return n/version/snapshot time.

**Expected result:** Rankings are difficult to game, performant, and independently reproducible.

**Subtasks:**

- **P3.SCORE.1a — Ratify formula, eligibility, and simulations.**
  **Summary/user story:** As a competitor, I want the rules known before competing.
  **What/why/how/expected:** Document binary/multiclass math, probability normalization, sample/
  category/coverage gates, provisional tiers, tie order, windows, void/correction, and simulate
  one-lucky-call, safe-event selection, always-50/100, abstention, and extreme confidence.
- **P3.SCORE.1b — Implement score ledger and snapshots.**
  **Summary/user story:** As a ranked user, I want each movement traceable to finalized events.
  **What/why/how/expected:** Trigger idempotent score rows on final/correction, key by forecast/
  resolution/scoring version, aggregate snapshots, around-me and cursor APIs, correction rebuild,
  freshness SLO, and reconciliation.
- **P3.SCORE.1c — Build global leaderboard and explanation UI.**
  **Summary/user story:** As a viewer, I want rank, movement, score, resolved n, reliability, period,
  and eligibility understandable.
  **What/why/how/expected:** Implement ranked/unranked/private/blocked/corrected states, filter,
  accessible table/detail, score breakdown, stable ties, share-safe achievement, and no “#1” for
  low-sample users.

**Dependencies:** P3.RES.1, P1.SCORE.1, anti-cheat P3.SAFE.2 before broad launch.
**Acceptance criteria:** golden/property tests exact; public score excludes group/subjective events;
reprocessing duplicates nothing; snapshot pagination stable; corrections rebuild; every rank shows
sample/version/reliability.
**Evidence:** independent fixture check, large-population load, tie/pagination/rebuild tests,
explainability usability study, and accessible chart/table audit.

#### P3.LOC.1 — Add opt-in coarse local discovery and city leaderboards

**Summary:** Create local relevance without collecting or exposing precise or real-time location.

**User story:** As a user, I want events and comparisons relevant to my city while remaining
indistinguishable within a sufficiently large community.

**Why:** Local predictions are socially resonant, but GPS-backed rankings could enable stalking,
small-cohort identification, and multi-city gaming.

**What:** Add curated locality hierarchy/timezone, manual city selection, optional on-device
suggestion, consent/revoke, city event assignment, minimum-crowd threshold, regional fallback,
local ranking eligibility, rate-limited locality changes, and no-content states.

**How:** Store only canonical `localityId`; discard coordinates on device; suppress/merge small
cohorts; assign events editorially; show viewer-local and event-local time; limit simultaneous
board eligibility; hide user locality unless explicitly published.

**Expected result:** Users discover meaningful city content without backend GPS collection or
identifiable neighborhood boards.

**Subtasks:**

- **P3.LOC.1a — Define locality privacy and consent.**
  **Summary/user story:** As a user, I want to select/remove a city with full understanding.
  **What/why/how/expected:** Define locality source, coarse hierarchy, minimum active/eligible
  threshold, exposure fields, change cooldown, on-device suggestion/discard, manual fallback,
  deletion, and no background permission.
- **P3.LOC.1b — Implement event/local leaderboard services.**
  **Summary/user story:** As a local participant, I want correct local events and fair one-city
  ranking.
  **What/why/how/expected:** Add reviewed event-locality assignment, discovery filters, thresholded
  snapshots, parent-region fallback, timezone/DST handling, change-abuse controls, and eligibility
  recalculation.
- **P3.LOC.1c — Build locality UX and verify privacy.**
  **Summary/user story:** As a user, I want searchable selection and a clear empty/fallback state
  without a map.
  **What/why/how/expected:** Build consent/search/select/remove/change, explain privacy threshold,
  local rail/board, small-city fallback, accessible names/times, and network inspection proving no
  coordinates leave device.

**Dependencies:** P3.EVT.2, P3.SCORE.1, privacy approval.
**Acceptance criteria:** no backend precise coordinates; explicit revocable consent; small cohorts
suppressed; switching cannot occupy several active city boards; locality private by default;
manual path works with denied location.
**Evidence:** packet inspection, threshold/switch abuse tests, DST fixtures, consent/deletion E2E,
and privacy data-flow review.

### Phase 3 bullet C — Category leagues

#### P3.LEAG.1 — Launch curated category leagues with common event pools

**Summary:** Let users specialize in sports, technology, entertainment, weather, or other approved
categories under a common, frozen scoring contract.

**User story:** As a forecaster, I want to compete in subjects I understand against people who saw
the same eligible questions.

**Why:** Category competition is more meaningful than one undifferentiated global score and reduces
unfair comparisons across different event difficulty/opportunity.

**What:** Define league/category membership, opt-in, eligible event pool, season/window, minimum
coverage, scoring version, standings, around-me, category profile fact, corrections, archive, and
notification preferences.

**How:** Use editorial categories and assigned event sets; freeze membership/scoring opportunity
rules per period; calculate from verified public events only; show participation coverage; prohibit
pay-to-rank or arbitrary category creation in Phase 3.

**Expected result:** Users develop recognizable areas of expertise and return for category-specific
events and standings.

**Subtasks:**

- **P3.LEAG.1a — Define league/event eligibility contract.**
  **Summary/user story:** As a competitor, I want to know which events count and how much
  participation is required.
  **What/why/how/expected:** Specify category taxonomy, period, scoring version, common pool,
  minimum resolved/coverage, late join, cancelled/corrected event, tie, opt-out, and finalization.
- **P3.LEAG.1b — Implement league services and snapshots.**
  **Summary/user story:** As a member, I want standings consistent with the eligible pool.
  **What/why/how/expected:** Add join/leave, schedule/event queue, provisional/final snapshot,
  around-me, correction rebuild, versioned archive, cache/load, and integrity hold integration.
- **P3.LEAG.1c — Build league discovery and standings UI.**
  **Summary/user story:** As a user, I want to discover, join, forecast, and understand category
  progress.
  **What/why/how/expected:** Build league cards, rules/eligibility, join, event queue, standings,
  personal progress, reliability, accessible explanation, notifications, and empty inventory.

**Dependencies:** P3.EVT.2, P3.SCORE.1.
**Acceptance criteria:** all ranked participants share eligible opportunity rules; active period
formula/pool cannot silently change; coverage visible; correction rebuilds before final; archive
retains version; subjective group events excluded.
**Evidence:** full synthetic period, coverage/tie/cancel/correction tests, load test, UI/accessibility
suite, and reconciliation report.

### Phase 3 bullet D — Moderation, reporting, anti-cheating, and event operations

#### P3.SAFE.1 — Implement reporting, blocking, moderation, and appeals

**Summary:** Provide complete user-generated-content safety operations before the public network
expands.

**User story:** As a user, I want to report harmful content, block abusive people, and receive a
fair review process.

**Why:** Public profiles/events and future creators introduce harassment, threats, spam,
impersonation, illegal content, and privacy exposure; platform review also expects functional
moderation controls.

**What:** Add structured reports, content snapshot/retention, block/unblock, case queue, assignment,
severity/SLA, warning/restriction/removal/suspension, emergency escalation, appeal, dual approval
for irreversible actions, reporter-safe status, and community guidelines.

**How:** Enforce immediate block effects; keep moderation evidence encrypted/least privilege;
audit operator access/actions; separate reporter from subject; detect report brigading; provide
accessible in-context entry on every eligible surface.

**Expected result:** Harm can be contained quickly, repeat abuse detected, and decisions reviewed
without exposing sensitive case information.

**Subtasks:**

- **P3.SAFE.1a — Build user report/block APIs and UI.**
  **Summary/user story:** As a targeted user, I want one clear path to block and report.
  **What/why/how/expected:** Define reason taxonomy, optional safe evidence, rate limits, immediate
  interaction suppression, report receipt/status, unblock, notification cleanup, and routes from
  profiles/events/receipts.
- **P3.SAFE.1b — Build moderation queue and enforcement.**
  **Summary/user story:** As a moderator, I want prioritized evidence and proportionate actions.
  **What/why/how/expected:** Add role-scoped queue, assignment/escalation, evidence snapshot,
  action preview, dual approval for permanent/high-impact actions, audit, notification, and
  restore/reversal.
- **P3.SAFE.1c — Build appeals, policy, and exercises.**
  **Summary/user story:** As an affected user, I want an understandable reason and independent
  appeal.
  **What/why/how/expected:** Publish community guidelines/SLAs, implement appeal window/reviewer,
  critical-safety runbooks, false-report protections, retention/deletion, and tabletop cases for
  threat, impersonation, spam, and brigading.

**Dependencies:** P1.ID.1, F0.5; required before public launch.
**Acceptance criteria:** report available on every public UGC surface; block immediate; reports
cannot discover private/deleted content; actions authorized/audited/reversible; critical cases
follow runbook; appeal reviewer differs when staffing permits.
**Evidence:** permission/E2E/load tests, four tabletop reports, retention verification, App Store
UGC checklist, and accessibility audit.

#### P3.SAFE.2 — Implement anti-cheat and leaderboard integrity controls

**Summary:** Detect and contain late entries, replay, modified clients, bots, account farms,
collusion, selective participation, locality hopping, and administrator misuse.

**User story:** As an honest participant, I want rankings protected from automation and fabricated
performance without being falsely branded a cheater.

**Why:** Status creates incentives to exploit the system. Integrity controls must protect the
board while preserving due process and privacy.

**What:** Threat model, server deadline/version enforcement, rate limits, App Attest/DeviceCheck as
one signal, anomaly features, private risk assessment, score quarantine, manual review, appeal,
clearance/recompute, operator separation, false-positive analysis, and red-team.

**How:** Combine multiple minimal-retention signals; never use one fingerprint for permanent
action; withhold suspicious score rows without deleting forecast history; expose safe reason;
audit reviews; test discriminatory proxies and accessibility of any challenge.

**Expected result:** Obvious manipulation fails, suspicious performance cannot rank pending review,
and cleared users restore exactly.

**Subtasks:**

- **P3.SAFE.2a — Threat-model and instrument attack surfaces.**
  **Summary/user story:** As an integrity engineer, I want explicit abuse cases and minimally
  necessary signals.
  **What/why/how/expected:** Model deadline/replay/modded client/account farm/bot/collusion/source
  leak/locality/admin threats; define retention, feature extraction, risk reason codes, metrics,
  and privacy/bias review.
- **P3.SAFE.2b — Enforce and quarantine.**
  **Summary/user story:** As an honest user, I want invalid submissions blocked before scoring.
  **What/why/how/expected:** Enforce server state/time, endpoint/adaptive rate limits, attestation
  fallback, anomaly rules, risk hold, leaderboard exclusion, operator segregation, and no public
  accusation.
- **P3.SAFE.2c — Review, appeal, red-team, and reconcile.**
  **Summary/user story:** As a falsely held user, I want a review and exact restoration.
  **What/why/how/expected:** Build private evidence/reviewer/appeal/clear flow, idempotent score
  rebuild, false-positive cohort review, forged/replay/bot/collusion simulations, penetration test,
  and dashboard.

**Dependencies:** P3.EVT.2, P3.SCORE.1, P3.SAFE.1.
**Acceptance criteria:** client clock/modification cannot late-submit; replay duplicates nothing;
quarantine preserves ledger; no single probabilistic signal permanently suspends; clearance
restores exact score; risk data absent from public API.
**Evidence:** signed threat model, attack and account-farm simulations, false-positive analysis,
penetration report, and integrity-review SLA dashboard.

#### P3.OPS.1 — Operationalize public event supply and controlled rollout

**Summary:** Create the people, dashboards, runbooks, flags, backups, and launch stages required to
operate time-sensitive public predictions.

**User story:** As a user, I want events, locks, results, and rankings reliable during traffic
spikes or disputed outcomes.

**Why:** Public events create scheduled workloads and visible failures that cannot be handled only
through app releases.

**What:** Define SLOs/owners; event inventory; unresolved/source/scoring/moderation queues; content-
free logs/alerts; feature-specific kill switches; canary events; load/cost limits; backup/replay;
incident runbooks; staff→invite→category staged rollout; privacy/support/App Store launch review.

**How:** Dashboard forecast acceptance latency/error, lock jobs, outbox, unresolved age, score
backlog, snapshot freshness, reports, integrity holds, and costs; permit independent disable of
publication/submission/profiles/sharing/leaderboards while preserving read/export/delete.

**Expected result:** Operators detect and contain failure without corrupting locked history or
turning off personal/private functionality.

**Subtasks:**

- **P3.OPS.1a — Establish inventory, SLOs, dashboards, and alerts.**
  **Summary/user story:** As an operator, I want every critical subsystem measurable and owned.
  **What/why/how/expected:** Set availability/latency/freshness/resolution/moderation targets,
  owners/escalation, synthetic canaries, dashboards, alerts, content redaction, budget thresholds,
  and correlation lookup.
- **P3.OPS.1b — Build controls, runbooks, backup, and game days.**
  **Summary/user story:** As an incident responder, I want to pause only the unsafe feature and
  recover data.
  **What/why/how/expected:** Add granular flags/kill switches, wrong-resolution/score/source/abuse/
  credential/traffic runbooks, automated encrypted backup, restore/replay reconciliation, and
  timed game day.
- **P3.OPS.1c — Run staged category launch.**
  **Summary/user story:** As the product owner, I want integrity proven at small scale before
  broad exposure.
  **What/why/how/expected:** Define entry/exit and rollback thresholds for staff, invited cohort,
  one category, expanded categories; seed canary events; review privacy/UGC/support; record each
  decision and incident.

**Dependencies:** all Phase 3 tasks.
**Acceptance criteria:** each subsystem has owner/dashboard/alert/runbook; flags isolate public
features; restore reconciles ledger/score; load deadline target passes; stages have numeric gates;
no direct production DB publication.
**Evidence:** game-day and restore reports, flag rollback recording, load/cost results, signed
launch checklist, and multi-cycle pilot evidence.

## 8. Phase 4 — Advanced Community

**Phase objective:** Turn trustworthy forecasting primitives into durable professional and
community formats without weakening privacy, scoring, or moderation.

**Entry gate:** Phase 3 has stable event operations and public integrity; monetization/legal
decisions exist before prizes or paid hosting.
**Exit gate:** team, season, tournament, creator, and analytics systems each complete a controlled
pilot with reproducible scores, privacy/safety evidence, and rollback.

### Phase 4 bullet A — Team forecasting spaces

#### P4.TEAM.1 — Build governed team workspaces and private team analytics

**Summary:** Add tenant-scoped spaces where organizations can forecast shared questions
independently and learn collectively without creating employee surveillance.

**User story:** As a team member, I want to submit a private forecast to a shared program and see
collective calibration after reveal.

**Why:** Team delivery/strategy forecasting is a strong professional use case, but role leakage or
individual “worst performer” reporting would be harmful and commercially unsafe.

**What:** Implement team, role, membership/offboarding, program/question list, hidden-until-lock
forecasts, resolution governance, aggregate analytics, audit/export, archive/delete, notification,
and premium team switcher/feed/result UI.

**How:** Scope every API row/query by tenant and membership; define owner/admin/facilitator/
forecaster/resolver/viewer permission matrix; snapshot rules per question; suppress individual
comparison below privacy sample; separate personal/private records from team ownership.

**Expected result:** Teams run repeatable forecasting rituals with trustworthy group learning and
explicit governance.

**Subtasks:**

- **P4.TEAM.1a — Build tenant model and authorization.**
  **Summary/user story:** As a team member, I want another organization unable to access any team
  record.
  **What/why/how/expected:** Define team/program/membership/role, enforce tenant membership on every
  request and realtime event, implement create/invite/remove/transfer/leave/archive/delete,
  immediate role changes, offboarding, and cross-tenant negative tests.
- **P4.TEAM.1b — Build forecasting program and governance.**
  **Summary/user story:** As a facilitator, I want recurring questions with a fair reveal and
  resolution process.
  **What/why/how/expected:** Create program/category/schedule, hidden forecast, named/multi-approver/
  objective resolution, notification controls, audit, export, and immutable rule snapshots; ensure
  managers cannot peek before reveal.
- **P4.TEAM.1c — Build team UX and privacy-safe analytics.**
  **Summary/user story:** As a team member, I want feeds and aggregate insights without personal
  humiliation.
  **What/why/how/expected:** Build switcher, program queue, submit, reveal, aggregate calibration/
  participation/category trends, small-cohort suppression, accessible chart tables, and clear
  retention/ownership copy.

**Dependencies:** Phase 1 group primitives, P3.EVT.1/P3.SCORE.1, enterprise privacy decision.
**Acceptance criteria:** cross-tenant IDOR fails; hidden forecasts remain hidden from managers;
role/offboarding immediate/audited; small cohorts cannot expose individual; transfer/export/delete
work; personal records remain outside tenant.
**Evidence:** full permission matrix, penetration test, small-cohort fixtures, lifecycle/offboarding
E2E, and two-team pilot report.

### Phase 4 bullet B — Seasonal leagues

#### P4.SEASON.1 — Implement fixed-rule recurring leagues

**Summary:** Create recurring competitions with enrollment, common event sets, rounds, standings,
recaps, and immutable final archives.

**User story:** As a community member, I want to join a season and compete under rules known before
it starts.

**Why:** Seasons give long-term structure and make comparison fairer by standardizing opportunity.
Changing rules midseason would invalidate status.

**What:** Support public curated/private group/team league modes; enrollment, open/active/finalizing/
final/archive states; event assignments; scoring version; coverage; late join/missed round/
withdrawal/suspension; standings; correction; non-monetary awards; final snapshot.

**How:** Freeze scoring, event eligibility, tie/advancement, and rewards before start; use common
pool or documented normalization; snapshot each round; delay final certification until disputes
close; version archive.

**Expected result:** Users understand schedule, what counts, progress, and why final rank is
trustworthy.

**Subtasks:**

- **P4.SEASON.1a — Define league lifecycle and frozen rules.**
  **Summary/user story:** As a participant, I want eligibility and tie rules stable.
  **What/why/how/expected:** Model league/season/member/round/event assignment/standing; define
  enrollment, late join, coverage, missed/cancelled/corrected, tie, withdrawal, enforcement,
  finalization, and immutable version.
- **P4.SEASON.1b — Implement scoring/schedule/snapshot services.**
  **Summary/user story:** As a member, I want every standing derived from assigned finalized
  events.
  **What/why/how/expected:** Generate round queues, idempotent score ledger, provisional snapshots,
  correction rebuild, around-me, recaps, final certification/archive, load controls, and
  reconciliation.
- **P4.SEASON.1c — Build join/progress/standings/archive UX.**
  **Summary/user story:** As a user, I want to join knowingly and follow season movement.
  **What/why/how/expected:** Build rules/join, schedule, event queue, participation progress,
  standings/reliability/movement, recap, awards, withdrawal, archive, accessibility, and
  notification preferences.

**Dependencies:** P3.LEAG.1, P3.SAFE.1–2.
**Acceptance criteria:** active rules cannot silently change; each score maps to assigned event;
missed/coverage effects visible; corrections rebuild before final; final archive includes scoring
version; suspended user cannot evade via switching.
**Evidence:** synthetic season with ties/withdrawals/cancellations/corrections, deadline load,
deterministic standings, content/legal reward review, and reconciliation report.

### Phase 4 bullet C — Prediction tournaments

#### P4.TOUR.1 — Build pooled qualifier and final tournaments

**Summary:** Add time-bounded multi-round competition with equal opportunity, deterministic
advancement, correction-aware certification, and spectator-safe reveals.

**User story:** As a competitive user, I want to advance by calibrated performance across several
rounds and understand every cutoff.

**Why:** Tournaments can create viral cultural moments, but brackets built before integrity rules
would amplify unfair opportunity, unresolved outcomes, and collusion.

**What:** Implement registration/check-in, pools, assigned events, provisional standings,
advancement, final, certification/archive, tie/correction/disqualification/appeal, operator
postpone/substitute/void controls, and tournament Receipt. Initial format: pooled qualifier then
one final.

**How:** Freeze event set/scoring/advancement/ties before registration closes; enforce equivalent
opportunities within pool; block advancement until required events final/void; run idempotent jobs;
pause certification for correction; reveal only allowed spectator data.

**Expected result:** A complete tournament is reproducible and exciting without compromising
forecast secrecy or scoring.

**Subtasks:**

- **P4.TOUR.1a — Define tournament lifecycle and fairness.**
  **Summary/user story:** As an entrant, I want registration, round, advancement, and appeal rules
  known.
  **What/why/how/expected:** Model tournament/entry/round/pool/participant/advancement/standing;
  specify check-in, equivalence, tie, unresolved/cancelled/correction, disqualification, appeal,
  certification, and no-money initial rewards.
- **P4.TOUR.1b — Implement round and advancement engine.**
  **Summary/user story:** As a competitor, I want advancement calculated exactly once from complete
  data.
  **What/why/how/expected:** Assign events/pools, calculate provisional score, wait for all
  required results, apply deterministic cut/tie, create next round idempotently, pause/recompute
  on correction, and expose audit/reconciliation.
- **P4.TOUR.1c — Build tournament and operator UX.**
  **Summary/user story:** As a participant/operator, I want clear status and safe exception tools.
  **What/why/how/expected:** Build hub, registration/check-in, schedule, assigned queue, progress,
  accessible list alternative to bracket, advancement reveal, final Receipt, spectator view, and
  authorized postpone/pre-lock substitution/emergency void.

**Dependencies:** P4.SEASON.1, P3.SAFE.2, push.
**Acceptance criteria:** equal pool opportunities; no advance with unresolved required event;
ties published in advance; rerun duplicates nothing; correction before certification recomputes;
spectators cannot access hidden forecasts; disqualification has appeal.
**Evidence:** full synthetic tournament, correction-during-advance/concurrency tests, traffic load,
collusion red-team, operator game day, and accessibility review.

### Phase 4 bullet D — Creator and community-hosted events

#### P4.HOST.1 — Enable governed creator event supply

**Summary:** Let trusted hosts propose and eventually operate public events through templates,
review, trust tiers, conflict controls, history, sanctions, and appeals.

**User story:** As a trusted community organizer, I want to run prediction events for my audience
without weakening Hindsight’s integrity guarantees.

**Why:** Community supply scales variety and distribution; unrestricted publication would introduce
spam, ambiguous settlement, unsafe prompts, phishing, and manipulation.

**What:** Add host application/profile, policy acknowledgment, trust tier, structured proposal,
staff review, supervised/direct publishing permissions, host page/follow, resolution obligations,
conflict-of-interest approval, performance history, dashboard, sanctions, report/appeal, and pilot.

**How:** Start all hosts proposal-only; progress from measured event volume/timely resolution/
correction/dispute/moderation rates; enforce permissions server-side; never expose hidden forecasts;
require independent resolution approval where host controls outcome; retain emergency platform
control.

**Expected result:** Vetted communities expand event inventory while users can inspect host
reliability and report problems.

**Subtasks:**

- **P4.HOST.1a — Define host policy, trust, and conflicts.**
  **Summary/user story:** As a participant, I want host permissions earned and conflicts disclosed.
  **What/why/how/expected:** Define application identity/policy, tier permission matrix, measurable
  progression/regression, prohibited prompts, controlled-outcome conflict, source/resolution SLA,
  sanctions, appeal, and legal/privacy treatment.
- **P4.HOST.1b — Build proposal/review/publishing services.**
  **Summary/user story:** As a host/editor, I want structured authoring and accountable approval.
  **What/why/how/expected:** Add templates, automated validation, proposal queue, staff review,
  immutable publish rules, rate limits, independent approval, resolution dashboard, enforcement,
  and reassignment after suspension.
- **P4.HOST.1c — Build host pages, following, and dashboards.**
  **Summary/user story:** As a user/host, I want visible history and manageable operations.
  **What/why/how/expected:** Show verified status meaning, events, resolution timeliness,
  correction/dispute history, follow/mute/report; provide host upcoming locks/pending resolutions/
  disputes/warnings; sanitize links and protect legal identity.

**Dependencies:** P3.EVT.2, P3.RES.1, P3.SAFE.1–2, P4.SEASON.1.
**Acceptance criteria:** new host cannot direct-publish; tier enforced server-side; same immutable
rules/evidence apply; conflicted host cannot solely resolve; history/report visible; revocation
preserves participant/audit records.
**Evidence:** tier permission tests, conflict/hidden-forecast tests, prompt policy fixtures,
suspension/reassignment simulation, moderator usability, and invited-host pilot metrics.

### Phase 4 bullet E — Sophisticated analytics and forecasting personality

#### P4.ANALYTICS.1 — Build advanced, sample-aware calibration stories

**Summary:** Turn finalized forecast history into surprising, reproducible insights by confidence,
category, horizon, time, and group comparison.

**User story:** As a forecaster, I want to know where I am overconfident, where I add signal, and
whether I am improving.

**Why:** Personalized revelation is Hindsight’s deepest retention payoff and its most shareable
noncompetitive artifact.

**What:** Add confidence-band accuracy, expected/observed gap, Brier trend, surprise rate,
resolution discipline, category/horizon fingerprint, paired consensus comparison, improvement
trend, weekly/monthly fact feed, drill-through, share card, and insufficient-data states.

**How:** Compute versioned server aggregates from finalized eligible ledgers; enforce minimum n and
cohort privacy; show time range/n/uncertainty/exclusions; generate facts from deterministic
templates; recompute after corrections; provide accessible table plus chart.

**Expected result:** Insights feel playful and personal while any number or sentence can be traced
to source calls and reproduced.

**Subtasks:**

- **P4.ANALYTICS.1a — Specify statistics and claim gates.**
  **Summary/user story:** As a user, I want a fact such as “80% calls land 58%” to include enough
  evidence.
  **What/why/how/expected:** Define formulas/buckets/time windows, recommended no declarative
  insight below 10 relevant resolutions and no stable trait below 30, uncertainty/early-signal
  copy, paired cohort requirements, sparse-cell suppression, correction/exclusion, and golden data.
- **P4.ANALYTICS.1b — Implement aggregate and insight-fact engine.**
  **Summary/user story:** As a learner, I want stats updated consistently after each final result.
  **What/why/how/expected:** Build materialized aggregates/incremental recompute, version/source IDs,
  deterministic fact selection/templates, exact denominator/explanation API, correction
  idempotency, export/delete propagation, and performance/reconciliation.
- **P4.ANALYTICS.1c — Build premium insight UI and sharing.**
  **Summary/user story:** As a user, I want one compelling insight first, then evidence on demand.
  **What/why/how/expected:** Build top story, calibration curve/table, domain/horizon/trend cards,
  drill-through, “why this,” insufficient/progress states, share projection with private text off,
  VoiceOver summaries, Dynamic Type, Reduce Motion, and no shaming.

**Dependencies:** P3.SCORE.1, sufficient final data.
**Acceptance criteria:** every statistic matches ledger query; correction/void applies once;
sparse cohorts suppressed; each chart has n/date/accessibility table; share excludes text by
default; copy distinguishes calibration/correlation/causation.
**Evidence:** independently calculated golden datasets, property/recompute tests, statistical/copy
review, accessibility suite, and five-insight comprehension research.

#### P4.PERSONA.1 — Create explainable forecasting personalities and recaps

**Summary:** Generate memorable, optional archetypes such as Cautious Oracle or Bold Optimist from
transparent evidence—never diagnosis or permanent identity.

**User story:** As a user, I want a fun description of my forecasting style that I can understand,
improve, keep private, or share.

**Why:** Identity artifacts are more memorable and viral than metric dashboards, but careless
labels can shame users or infer sensitive traits.

**What:** Define versioned persona rules/features, minimum sample/diversity, primary/secondary
tendency, strength of fit, evidence explanation, constructive next action, scheduled refresh,
history, private/profile/share controls, premium reveal, and recap integration.

**How:** Use only allowed forecasting behavior—confidence distribution, calibration, Brier,
long-shot rate, resolution follow-through, category diversity, horizon; exclude demographics and
sensitive inferred traits; store snapshot inputs/version; use deterministic classification;
internationalize/emotional-safety test.

**Expected result:** A user receives a delightful evidence-backed report without being ranked as a
better or worse person.

**Subtasks:**

- **P4.PERSONA.1a — Define safe archetype system.**
  **Summary/user story:** As a user, I want labels grounded in behavior and not insulting.
  **What/why/how/expected:** Define names, allowed features, thresholds, sample/diversity gate,
  secondary tendency, uncertainty, refresh, explanation, change reason, constructive guidance,
  prohibited inference, and localization/bias review.
- **P4.PERSONA.1b — Implement reproducible snapshots.**
  **Summary/user story:** As a user, I want my result reproducible and able to change as evidence
  changes.
  **What/why/how/expected:** Create versioned definition/snapshot/evidence, deterministic classifier,
  boundary/stability tests, privacy projection, opt-in profile publication, remove/share, history,
  export/delete/correction behavior.
- **P4.PERSONA.1c — Build reveal, share, and recurring recap.**
  **Summary/user story:** As a user, I want an emotionally safe reveal and a useful next step.
  **What/why/how/expected:** Design premium and static reduced-motion reveal, primary/secondary/
  evidence/how-determined/progress UI, accessible reading order, explicit share preview, and
  weekly/monthly/annual recap integration with notification budget.

**Dependencies:** P4.ANALYTICS.1, content/privacy review.
**Acceptance criteria:** no persona below thresholds; snapshot reproducible; user can keep private/
share/remove; no clinical/intelligence/moral claim; classifications not ranked; changed result
explains evidence; accessible equivalent.
**Evidence:** golden/boundary/stability/bias fixtures, emotional-safety/localization research,
accessibility recording, and privacy snapshots.

## 9. Cross-phase QA, release, and completion contract

Every feature task above implicitly includes the following unless the task strengthens it:

1. **Unit coverage:** validation, pure calculations, state transitions, mapping, retry, and exact
   edge fixtures.
2. **Backend integration:** authentication, authorization, idempotency, concurrency, pagination,
   schema migration, and negative-access cases against an isolated database.
3. **Contract coverage:** generated client/API schema compatibility and stable error codes.
4. **UI smoke:** happy path plus loading, empty, offline, permission, failure/retry, expired,
   removed-access, and corrected states.
5. **Persistence/relaunch:** draft/outbox/cache/migration survive termination and never cross
   accounts.
6. **Accessibility:** VoiceOver, largest Dynamic Type, contrast, 44-point targets, reduced motion,
   non-color status, accessible chart/table.
7. **Security/privacy:** threat cases, content-free logs/analytics/push, access matrix, exported/
   deleted derived data, no fake identity/resolver evidence.
8. **Performance:** agreed p95 API/UI/load target and deadline-spike behavior.
9. **Release evidence:** exact commit, client/backend/schema/scoring versions, command/result,
   screenshots/device/OS, checks not run, risks, rollout and rollback.

Status meanings:

- `planned`: contract exists; implementation has not started.
- `in_progress`: active work exists but is incomplete.
- `code_complete`: implementation and automated checks exist; named external/manual checks remain.
- `verification_pending`: a candidate is built, but one or more required evidence gates remain.
- `done`: all acceptance and evidence exists for the promoted QA SHA and environment.

## 10. Branch and environment workflow

Git branches and backend accounts are different controls:

- `dev` is the integration branch. Feature branches merge here after task-level checks.
- `qa` only fast-forwards to a specific verified `dev` SHA. No feature commits are made directly
  on `qa`.
- Production is an immutable QA-approved tag/artifact; production implementation is not started by
  this planning baseline.
- Backend development, QA, and production require separate service projects/accounts, databases,
  OAuth audiences, APNs topics/credentials, storage, secrets, domains, budgets, and synthetic data.
  Creating Git branches does not provision them.
- A promotion manifest records app SHA, backend SHA, schema version, scoring version, feature
  flags, environment, build number, test artifacts, and approver.
- A QA defect is fixed on `dev`, reverified, then re-promoted; `qa` history is never rewritten.

## 11. Recommended execution order

1. F0.1–F0.7 and the premium prototype.
2. P1.CAP.1–2, P1.ID.1, P1.SYNC.1–2.
3. P1.GRP.1–2, P1.PRED.1–2, P1.LOCK.1, P1.RES.1.
4. P1.SCORE.1–2 and P1.RCPT.1; run Phase 1 private beta gate.
5. P2.LINK.1, P2.CHAL.1, P2.MSG.1, P2.SOC.1, P2.RECAP.1.
6. P3.EVT.1–2 and P3.RES.1.
7. P3.SCORE.1, P3.SAFE.1–2, P3.LOC.1, P3.LEAG.1, P3.OPS.1.
8. P4.TEAM.1 and P4.ANALYTICS.1–P4.PERSONA.1.
9. P4.SEASON.1, P4.TOUR.1, and P4.HOST.1.

## 12. Jira creation map

Create four parent epics plus one foundation epic:

- **SOC-F0 — Social Architecture and Safety Foundation**
- **SOC-P1 — Premium Social MVP**
- **SOC-P2 — Viral Distribution**
- **SOC-P3 — Public Network**
- **SOC-P4 — Advanced Community**

Create one Story or Task for every `F0.*`, `P1.*`, `P2.*`, `P3.*`, and `P4.*` heading in this
document. Create each lettered/numbered subtask as a Jira Sub-task only when the HIND configuration
allows optional lifecycle fields at creation. Preserve IDs in the Jira `Task ID` field and labels
(`PM`, `DESIGN`, `ENG`, `QA`, `OPS`, `LEGAL`, `MKT`, `UA`) during refinement.

The repository remains the source of truth until Jira CR-002 is resolved. Do not fabricate
`Actual`, `Delay Cause`, component, fix-version, agent, or commit fields merely to create tickets.

## 13. Explicitly deferred decisions and non-goals

The following require their own accepted decision before implementation:

- Exact backend vendor and approved client dependencies (F0.3).
- Whether private personal items sync by default after account opt-in (recommend per-domain clear
  consent, never implicit legacy upload).
- Exact Foresight Score display transform and public eligibility thresholds (P1.SCORE.1).
- Contact-book discovery (deferred; exact handle/link/shared group first).
- Arbitrary user-created public events (deferred until creator governance proves safe).
- Political, medical, tragedy, financial-advice, wagering, cash-prize, and precise-neighborhood
  markets.
- Direct messages, comments/chat, follower popularity feeds, pay-to-rank, and engagement-maximizing
  recommendations.
- Monetization and organization billing; paid entitlements must not affect competitive score.
