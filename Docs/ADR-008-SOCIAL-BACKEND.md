# ADR-008 — Social v2 Backend Architecture

- **Status:** proposed — approval is gated on F0.3 spike evidence
- **Date:** 2026-07-30
- **Deciders:** product, iOS, backend, security/privacy, and operations owner
- **Related:** DEC-005 through DEC-007; F0.3, F0.4, F0.7; `SOCIAL-V2-FOUNDATION`

## Context

Hindsight Social v2 needs server-authoritative accounts, private groups, membership, immutable
forecast locks, objective resolutions, score ledgers, moderation, notifications, and public
rankings. Existing Build 1 remains local-only. A device must never be authoritative for social
time, authorization, forecast state, resolution, or score.

The repository permits a backend but prohibits third-party runtime dependencies until an explicit
decision and change request. The full evidence and cost assumptions are in
[`SOCIAL_V2_BACKEND_EVALUATION.md`](SOCIAL_V2_BACKEND_EVALUATION.md).

## Proposed decision

Pending the spike, select **Supabase hosted Postgres in a selected single region per environment,
behind a thin, versioned Hindsight API and server-side transactional functions**.

- Use native `AuthenticationServices` for Sign in with Apple; validate identity server-side and
  map Apple subject to an internal immutable user ID. Do not make Apple email a public identifier.
- Use PostgreSQL schema constraints, transactions, append-only audit/score ledgers, and RLS as
  defense in depth. Forecast locks, resolutions, scores, moderation, and membership changes go
  through server-authoritative versioned endpoints/functions, not generic client table writes.
- Use authorized Supabase Broadcast after committed changes for group/reveal updates. Treat it as
  a notification/caching mechanism; clients reconcile with the versioned API after reconnect.
- Run scheduled reveal, retry, moderation, and APNs dispatch work server-side. Keep APNs keys,
  database credentials, and service keys out of iOS and source control.
- Maintain separate Supabase projects, auth configuration, databases, storage, domains, APNs
  configuration, budgets, and secrets for development, QA, and production. `dev`/`qa` Git branches
  are not backend environments.
- Keep API payloads and migrations vendor-neutral. Maintain schema migration history, periodic
  encrypted logical export, restore rehearsal, and an outbox/audit export so a managed/custom
  Postgres migration remains feasible.

## Why this option

Postgres matches the product's inherently relational authorization and leaderboard domain,
supports one atomic lock transaction, and preserves a practical migration path. Supabase adds
managed auth, realtime, functions, regions, backups, and local tooling without selecting a
client SDK prematurely. Firebase is viable but shifts relational and aggregate complexity into
document denormalization; CloudKit does not satisfy the independent server-authority/public-network
requirements; a custom Postgres API is attractive later but prematurely transfers operations and
security burden to an unstaffed team.

## Consequences

### Positive

- The core integrity rule can be enforced by constraints and a transaction at the data authority.
- Group reads and mutations can share explicit relational ownership checks and durable audit IDs.
- Public score/reveal queries remain explainable and exportable SQL rather than derived client
  state.
- The team can run a bounded disposable spike before committing product data or an iOS dependency.

### Costs and risks

- RLS and privileged-function design can create severe authorization defects if misconfigured;
  automated negative security tests and review are release gates.
- Realtime must use private topics, minimal payloads, and Broadcast scale tests; it is not a source
  of truth.
- Managed-platform outages, pricing, regional availability, and function limitations remain
  vendor risks. Budget alerts, rate limits, export/restore tests, and a custom-Postgres exit plan
  are mandatory.
- Supabase's iOS client library is **not approved by this ADR**. F0.3c must separately record any
  dependency/version/license/privacy review or use URLSession against the versioned API.

## Rejected for Phase 1

- **Firebase/Firestore:** use only if the spike demonstrates materially better delivery and an
  equivalent server-side relational/ledger design. It is not the default because document reads,
  denormalization, and aggregate authorization increase the implementation and cost risk.
- **CloudKit:** reject as the server authority for Social v2. iCloud identity/public database
  semantics, quota-based planning, and server/public-network constraints do not meet the required
  independent account, moderation, and portable relational authority model.
- **Custom API plus managed Postgres now:** defer. Reconsider after Phase 1 if reliability,
  residency, scale, or vendor constraints justify dedicated operational ownership.

## Decisive spike and acceptance

This ADR changes to **accepted** only when a disposable development spike proves all of the
following with redacted evidence:

1. Apple token nonce, audience, signature, expiry, and replay rejection; no token logging.
2. Server-side authorization rejects outsider, removed-member, blocked-user, forged-role, and
   cross-environment accesses.
3. A concurrency race at the server deadline creates exactly one immutable forecast plus audit
   event, rejects late/duplicate/replay requests, and uses server UTC rather than client time.
4. Resolution writes an append-only evidence/reference and a versioned proper-score ledger;
   rewrite attempts fail.
5. Private realtime delivery and APNs job retries work after reconnect without exposing content or
   treating a notification as confirmation.
6. Backup restore, schema/data export, and dev/QA isolation have been rehearsed using synthetic
   fixtures.

Failure or a material cost/latency/security issue reopens this ADR and evaluates Firebase or a
custom managed-Postgres API; it does not permit a client-authoritative fallback.

## Implementation constraints after acceptance

- F0.4 defines vendor-neutral OpenAPI/domain contracts before Phase 1 feature code.
- F0.5 approves privacy, Terms, deletion, abuse/moderation, and telemetry policy before external
  testers receive social features.
- F0.6 keeps legacy SwiftData content local until per-item/bulk explicit consent.
- F0.7 creates isolated environments, secret rotation, CI contract/security/migration gates,
  observability, feature flags, budget alerts, and rollback playbooks.
- A change request must approve each third-party runtime dependency before source-code addition,
  per DEC-007.

## Review trigger

Review before public-network launch, on any incident involving authorization/locking, if expected
monthly cost exceeds the approved budget, when a residency requirement changes, or six months after
acceptance. The next review must compare real measured requests, connection fan-out, storage,
backup recovery, and support load against the estimates.
