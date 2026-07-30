# Social v2 Foundation Execution Wave 2 — 2026-07-30

## Scope and lifecycle

This wave executes dependency-safe local portions of F0.3, F0.4, F0.5, and F0.7 on `dev`.
Lifecycle remains `verification_pending`. It introduces no Social v2 UI, networking, provider
SDK, cloud account, credentials, external users, production data, analytics delivery, or runtime
flag-loading path.

## Integrated results

### F0.3 disposable PostgreSQL parity

`Backend/Spike/PostgresParity/run.sh` ran outside the restricted workspace sandbox because
PostgreSQL requires local shared memory. It created its own `mktemp` cluster and private Unix
socket, used only synthetic environment-prefixed IDs, then stopped and removed the cluster.

```text
BASE_TEST=PASS
PARITY_RESULT=PASS
RACE_FORECAST_AUDIT=1/1
OUTBOX_RECLAIM=PASS
FEED_RECONCILIATION=2
RESTORE_COUNT_CHECKSUM=2:18489366fc3a91181fdd13fa86740141
```

Verified: RLS read projection, active-membership authorization, outsider/removed/cross-environment
rejection, server-UTC deadline, same-request idempotent replay, changed-payload rejection, two
concurrent `psql` sessions producing one forecast/audit pair, immutable forecast/audit/resolution
ledgers, generic content-free outbox reclaim, durable missed-event reconciliation, separate
synthetic development/QA databases, and logical backup/restore forecast checksum equality.

Not verified: Apple identity, Supabase-hosted RLS/Broadcast, real APNs, provider projects, hosted
load, hosted isolation, or production restore objectives.

### F0.4 contract CI

`Scripts/social_v2_contract_ci.sh` passed. It validates OpenAPI 3.1 structure, all internal JSON
pointers, unique operation IDs, explicit bearer security, required idempotency headers on writes,
component-backed JSON/error schemas, secret/content-free examples, two positive expectation
declarations, and all sixteen named negative expectation declarations.

The fixture result is declaration validation only. No live backend executed these expectations;
external OpenAPI lint and generated-client compatibility remain pending.

### F0.5 privacy payload guard

`Scripts/social_v2_privacy_ci.sh` passed 13/13 deterministic fixtures: three allowed payloads and
ten intentional rejections. The closed allowlist rejects content/private field classes, group
names/handles/email, invite/auth/secret-like material, raw URLs, precise coordinates, unknown
fields, oversized values, mixed environments, and free-form APNs thread identifiers. Generic push
localization keys and typed opaque routes are allowed.

This is a local payload boundary, not analytics/APNs delivery, server-side scrubbing, privacy
approval, or legal approval.

### F0.7 client rollout and CI

The new `SocialV2RolloutPolicy` has no persistence, network, `UserDefaults`, process-argument, or
runtime loading path. All five flags default off. Decisions fail closed for invalid dependency
graphs, environment/account mismatch, unsupported contract epoch, and unsupported app build.
Opaque account identifiers reject short, oversized, whitespace, and direct-identifier punctuation.

Focused result:

```text
/private/tmp/hindsight-social-rollout-20260730.xcresult
7 passed / 0 failed / 0 skipped
```

Integrated result:

```text
/private/tmp/hindsight-social-foundation-wave2-20260730.xcresult
80 passed / 0 failed / 0 skipped
iPhone 17 Pro simulator / iOS 26.5
```

The dynamic resolver emitted a valid ID-based destination without a hardcoded model or UUID.
`.github/workflows/social-v2-foundation.yml` is locally syntax-validated and defines read-only,
range-aware contract/privacy/client gates for `dev` and `qa`; it is not hosted evidence until a
pushed GitHub run succeeds.

## Remaining gates

- Product-owner decisions and actual prototype research.
- Claude Design/Figma prototype and design/accessibility review.
- Apple-auth and Supabase-hosted proof, accepted ADR-008, and isolated provider projects.
- External OpenAPI lint/generated client and live-backend fixture execution.
- Privacy/safety/legal approvals, runtime telemetry/APNs enforcement, and deletion/export proof.
- Real environment manifests/secrets, green hosted CI, dashboards/budget alerts, and QA
  backup/restore/rollback game day.

Phase 1 remains queued until those governing gates are accepted.
