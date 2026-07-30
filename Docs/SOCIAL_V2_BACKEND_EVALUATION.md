# Social v2 Backend Evaluation

**Status:** decision input for F0.3; researched 2026-07-30; no account, credential, SDK, or
production data created.  This evaluates the mandatory Social v2 integrity boundary, not the
current local Build 1 application.

## Decision to make

Choose a backend capable of server-authoritative identity, private-group authorization,
immutable forecast locks, resolutions, score ledgers, moderation, and a versioned API. The client
may cache and queue work, but it must never authoritatively lock, resolve, rank, or authorize.

## Non-negotiable architecture requirements

- Native Sign in with Apple uses `AuthenticationServices`; the backend verifies the Apple token,
  nonce, signature, issuer, audience, expiry, and replay protection before creating an internal
  immutable user ID. Apple documents server token verification and revocation in its
  [Sign in with Apple REST API](https://developer.apple.com/documentation/signinwithapplerestapi).
- A single server-side transaction must check actor, membership, role, event state, deadline using
  server UTC, idempotency key, and existing forecast before inserting a forecast plus immutable
  audit record. Client transactions alone are insufficient.
- Private group reads, writes, invite redemption, blocks, moderator actions, and score changes
  require server enforcement. UI hiding is never authorization.
- The selected service must support separate development, QA, and production environments,
  backup/restore rehearsal, content-free telemetry, export/delete, and a documented exit path.

## Weighted matrix

Scale: 1 = inadequate or requires major custom work; 3 = feasible with material trade-off;
5 = directly fits. Scores are an architecture assessment, not a vendor security certification.

| Criterion | Weight | Supabase / Postgres | Firebase / Firestore | CloudKit | Custom versioned API + Postgres |
|---|---:|---:|---:|---:|---:|
| Relational authorization and query shape | 15 | 5 | 2 | 2 | 5 |
| Atomic immutable lock and audit ledger | 14 | 5 | 4 | 3 | 5 |
| Apple identity and session control | 11 | 4 | 4 | 2 | 5 |
| Security/trust-boundary expressiveness | 12 | 5 | 3 | 2 | 5 |
| Realtime group/reveal delivery | 8 | 4 | 5 | 3 | 4 |
| Jobs, scheduled reveals, APNs integration | 8 | 4 | 5 | 2 | 5 |
| Backups, restore, retention | 7 | 4 | 4 | 2 | 5 |
| Local development and deterministic tests | 6 | 4 | 4 | 2 | 5 |
| Observability and incident operations | 6 | 3 | 5 | 2 | 5 |
| Cost predictability at scale | 5 | 4 | 2 | 1 | 3 |
| Residency, portability, vendor exit | 5 | 5 | 3 | 1 | 5 |
| Delivery speed / iOS integration | 3 | 4 | 5 | 4 | 2 |
| **Weighted total / 5** | **100** | **4.39** | **3.63** | **2.16** | **4.69** |

The custom stack scores highest on pure control but is not the recommended first implementation:
its operations, security ownership, incident response, and delivery burden are not yet staffed or
costed. Supabase/Postgres is the strongest bounded Phase 1 default because it retains Postgres
portability while reducing initial infrastructure work. The recommendation is conditional on the
spike below; no client SDK is approved by this evaluation.

## Candidate assessment

### 1. Supabase hosted Postgres plus thin versioned API — recommended for the spike

**Fit.** Each project has a full Postgres database; Supabase documents Row Level Security (RLS),
backups, and point-in-time recovery on paid plans in its [database overview](https://supabase.com/docs/guides/database/overview).
Use SQL constraints, a security-definer transaction/RPC or server function, immutable append-only
audit tables, and RLS as defense in depth. Do not expose generic table mutation for forecasts,
resolutions, score entries, or moderation: expose versioned server endpoints that invoke the
transaction.

**Identity.** Supabase documents native Apple login support
[here](https://supabase.com/docs/guides/auth/social-login/auth-apple). The spike must still prove
the native token/nonce exchange and internal-user mapping; hosted auth does not remove the product
need for replay tests, revocation handling, and account deletion.

**Realtime and jobs.** Realtime supports Broadcast, Presence, and Postgres Changes. For group
feeds, prefer authorized Broadcast triggered after a committed transaction; Supabase recommends
Broadcast over Postgres Changes for scalability and security in its
[subscription guide](https://supabase.com/docs/guides/realtime/subscribing-to-database-changes).
Its Postgres Changes documentation warns that per-subscriber authorization can become the
bottleneck and recommends Broadcast above roughly 3,000 concurrent subscribers
([limitations](https://supabase.com/docs/guides/realtime/postgres-changes)). Scheduled jobs and
push dispatch need a server-side worker/function with APNs credentials held only in the server
environment; benchmark that worker in the spike.

**Operations and exit.** Select an exact region per environment; Supabase lists available AWS
regions [here](https://supabase.com/docs/guides/platform/regions). Pro has seven days of daily
backups; point-in-time recovery is a paid add-on and longer retention needs an explicit policy
([backup documentation](https://supabase.com/docs/guides/platform/backups)). Exit is `pg_dump`,
migrations, API contracts, and object exports into independently controlled storage. Risks are
RLS policy mistakes, administrative service keys, Edge Function limits, and realtime fan-out;
mitigate with deny-by-default policies, server-only secrets, contract/security tests, and Broadcast
benchmarks.

### 2. Firebase Authentication + Firestore + Cloud Functions — viable but second choice

**Fit.** Firebase supports Apple sign-in on iOS with a nonce
([official guide](https://firebase.google.com/docs/auth/ios/apple)) and Firestore transactions are
atomic, but a transaction runs client-side when using client SDKs, can retry, and fails offline
([transaction documentation](https://firebase.google.com/docs/firestore/manage-data/transactions)).
For Hindsight, authoritative locks and scores must therefore be callable server functions backed
by Admin privileges, not Security Rules plus a client transaction.

**Trade-offs.** Excellent realtime delivery, Cloud Functions/Cloud Tasks/FCM ecosystem, and Google
Cloud logging; Firestore's document data model makes joins across memberships, events, forecasts,
resolutions, score ledger, reports, and global rankings more denormalized and operationally
complex. Security Rules have bounded document-access calls, so authorization structures must be
tested under worst-case group queries. Firestore locations are selected at provisioning and cannot
be changed for an instance ([locations documentation](https://cloud.google.com/firestore/docs/locations)).

**Exit/risk.** Export documents to Cloud Storage/BigQuery and write a relational migration, but
that is a material future transformation. Firestore billing is per document read/write/delete,
index reads, storage, and egress ([pricing documentation](https://cloud.google.com/firestore/pricing));
viral feeds and leaderboards make read costs and accidental fan-out less predictable.

### 3. CloudKit — reject for the Social v2 server authority

**Fit.** CloudKit can share records and send subscription notifications, and it has development
and production container environments. However, its public database is world-readable/owner-writable
by default and roles are configured in the portal rather than the client API
([Apple documentation](https://developer.apple.com/documentation/cloudkit/ckdatabase/scope/public)).
CloudKit's identity model is iCloud-centric, not the product's independent Sign in with Apple
account/session model. Server-to-server access is limited to public-database operations using
signed requests ([Apple web-services reference](https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitWebServicesReference/SettingUpWebServices.html)).

**Why reject.** These constraints make server-authoritative cross-platform identities, relational
moderation/audit operations, public rankings, explicit regional residency, and a clean backend
exit unusually difficult. Public storage is quota-governed and Apple documents a `QUOTA_EXCEEDED`
failure for the public database ([reference](https://developer.apple.com/documentation/cloudkitjs/cloudkit.ckerror/quota_exceeded)); a dependable MAU cost model cannot be built from public
price lists. CloudKit may remain an optional Apple-only private backup investigation, never the
authority for social locks or public scores.

### 4. Custom versioned API over managed Postgres — retain as scale/exit alternative

**Fit.** A custom service provides the clearest trust boundary, API versioning, Apple token
validation, outbox/jobs, APNs, moderation tooling, audit logs, and Postgres transactional locks.
Postgres also supports logical replication/filtering, which helps controlled export/transition
([PostgreSQL documentation](https://www.postgresql.org/docs/current/logical-replication-row-filter.html)).

**Why not first.** It requires owning infrastructure-as-code, migrations, auth/session issuance,
rate limits, queues, backups, monitoring, on-call, WAF/abuse controls, and incident response from
day one. Managed PostgreSQL providers offer multi-AZ options, but this increases cost and operator
responsibility ([RDS overview](https://aws.amazon.com/rds/postgresql/pricing/)). Adopt later only
if the spike reveals a hosted-platform blocker or product scale justifies the operational team.

## Cost model — planning estimates, not quotes

**Shared assumptions:** USD/month; three isolated environments; North America region; text-first
records; 20 feed/profile reads, 5 writes, 2 realtime events, and 1 push per MAU/month; no video,
AI, paid email, or human moderation labor; 20% contingency. Actual pricing depends on region,
storage, egress, concurrency, retention, support, and abuse. Recalculate with vendor calculators
before account creation or any budget commitment.

| Candidate | 10k MAU | 100k MAU | 1m MAU | Interpretation |
|---|---:|---:|---:|---|
| Supabase/Postgres | $75–250 | $300–1,500 | $4,000–12,000 | Pro starts at $25/month; first project includes Micro compute and Pro includes 100k MAU, after which Auth is listed at $0.00325/MAU. Multiple environments, larger compute, egress, PITR, logs, and push worker drive the range. See [pricing](https://supabase.com/pricing). |
| Firebase/Firestore | $50–400 | $250–2,000 | $1,500–12,000 | Authentication is no-cost through 50k MAU; Firestore reads/writes/index reads, Functions, egress, and high fan-out drive variance. See [Firebase pricing](https://firebase.google.com/pricing) and [Firestore pricing](https://cloud.google.com/firestore/pricing). |
| CloudKit | **Not safely priceable** | **Not safely priceable** | **Not safely priceable** | Treat as a quota/contract risk, not “free.” Apple publishes quotas/errors rather than a comparable MAU rate card; obtain written quota confirmation before any proposal. |
| Custom API + managed Postgres | $300–1,500 | $1,500–8,000 | $8,000–40,000+ | Includes highly variable managed DB, API/worker, observability, WAF/queue, backup, and 24/7 ownership assumptions; excludes engineering/on-call labor. Use a provider calculator for a real quote. |

## Mandatory proof-of-fitness spike

Run only synthetic fixtures in a disposable development environment. Do not add an iOS SDK, create
production users, or make a production project.

1. Verify a native Apple identity token/nonce server-side; reject wrong audience, expired token,
   replayed nonce, and revoked credential. Confirm no token enters logs.
2. Create owner, member, removed member, blocked actor, and outsider fixtures. Prove every group
   read/write/invite path denies unauthorized access at the server/API boundary.
3. At a server-clock deadline, race 100 requests using duplicate and unique idempotency keys.
   Prove exactly one valid immutable forecast/audit pair, correct deadline rejection, and no client
   timestamp authority.
4. Resolve an objective synthetic event; append evidence, calculate a versioned proper-score
   entry, and prove mutation attempts cannot rewrite the forecast or ledger.
5. Trigger committed feed/reveal events; benchmark normal and 3,000-concurrent-subscriber
   behavior, reconnect/cursor recovery, and APNs job retry/dead-letter behavior.
6. Restore a backup to a separate disposable project; prove environment keys are rejected across
   dev/QA; export schema/data and replay the API contract fixtures.

**Pass threshold:** all negative authorization/integrity cases pass; no forecast text or secret in
logs; a 95th-percentile lock request target and backup restore target are agreed before implementation.
Failure means revise the ADR, not weaken the contract.

## Primary sources

- [Apple: Sign in with Apple REST API](https://developer.apple.com/documentation/signinwithapplerestapi)
- [Supabase: database and RLS overview](https://supabase.com/docs/guides/database/overview), [Apple login](https://supabase.com/docs/guides/auth/social-login/auth-apple), [pricing](https://supabase.com/pricing), [backups](https://supabase.com/docs/guides/platform/backups), [regions](https://supabase.com/docs/guides/platform/regions)
- [Firebase: Apple authentication](https://firebase.google.com/docs/auth/ios/apple), [Firestore transactions](https://firebase.google.com/docs/firestore/manage-data/transactions), [pricing](https://firebase.google.com/pricing), [Firestore pricing](https://cloud.google.com/firestore/pricing), [locations](https://cloud.google.com/firestore/docs/locations)
- [Apple: CloudKit public scope](https://developer.apple.com/documentation/cloudkit/ckdatabase/scope/public), [web services](https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitWebServicesReference/SettingUpWebServices.html)
- [PostgreSQL: logical replication row filters](https://www.postgresql.org/docs/current/logical-replication-row-filter.html), [AWS RDS PostgreSQL pricing](https://aws.amazon.com/rds/postgresql/pricing/)
