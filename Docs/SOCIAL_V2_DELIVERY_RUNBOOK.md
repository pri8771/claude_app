# Hindsight Social v2 Delivery Runbook

**Task:** F0.7 — vendor-neutral/local delivery foundation
**Status:** `code_complete` for local documentation and validation tooling; `verification_pending` for real environments, CI hosting, observability, and recovery rehearsal.
**Owners:** release owner (accountable), iOS, backend, security/privacy, QA, and operations.
**Prerequisites:** ADR-008 accepted after its decisive spike; F0.4 contract, F0.5 policy, and F0.6 migration gates accepted before external Social v2 testing.

## 1. Purpose, scope, and hard stops

**Summary:** Define a traceable promotion path from `dev` to `qa` to an immutable production artifact without sharing data, credentials, or unverified schema versions.

**User story:** As a release owner, I need every client build to prove which environment, API, schema, scoring policy, and flags it used so a failed promotion can be stopped and recovered safely.

**Why:** Social forecasts have server timestamps, authorization, notifications, and immutable score/resolution records. A QA build accidentally targeting production is both a privacy and integrity incident.

**What:** This runbook defines environment isolation, least-privilege access, promotion evidence, CI gates, content-free observability, flags, migrations, rollback, and approval roles. It does not provision a vendor account or introduce a runtime dependency.

**How:** Fill a protected, non-secret copy of `Config/SocialV2/environment-manifest.example.json`, validate it with `Scripts/validate_social_environment.sh`, and run `Scripts/social_v2_client_ci.sh` on a specific simulator. Store all credentials only in the selected provider/deployment secret store.

**Expected result:** A release can be reproduced from immutable inputs and stopped without deleting local data or claiming an unverified restore.

**Hard stops:** Do not enable social writes, private-sync consent, migration, production APNs, or an external TestFlight cohort until ADR-008/F0.4/F0.5 gates and the environment-specific evidence below are accepted. `dev` and `qa` Git branches are not backend environments.

## 2. Environment inventory and access controls

| Control | Development | QA/staging | Production |
|---|---|---|---|
| Git/ref | `dev` | fast-forwarded `qa` SHA only | immutable `refs/tags/v*` created from approved QA SHA |
| Backend/auth/database/storage | Separate project, auth audience/client, database, storage bucket, service identities | Separate project, synthetic-only users/data, independent auth audience/client/database/bucket | Separate project, real-user data, production-only identities/database/bucket |
| iOS identity | `*.dev` bundle and matching APNs topic | `*.qa` bundle and matching APNs topic | unsuffixed production bundle/topic |
| Domains | isolated development API/auth/realtime/link domains | isolated QA domains; no production redirects/cookies | production-only domains, TLS, associated domains |
| Budgets | low hard cap and owner alert | capped load-test/fixture budget | approved monthly cap, forecast, anomaly alerts |
| Access | named engineers, time-bound developer roles | named QA/release roles; no production reads | minimum named operators; break-glass separately audited |
| Data | disposable synthetic fixtures only | deterministic synthetic fixtures only | customer data only; never copied into lower environments |

### Secrets, least privilege, and rotation

1. Create distinct service identities for deployment, migrations, APNs dispatch, backup/restore, observability, and read-only support diagnostics. Grant each only the environment and operation required.
2. Never put keys, refresh tokens, Apple private keys, service-role credentials, database URLs with credentials, or push certificates in source, manifests, test fixtures, logs, screenshots, shell arguments, or result bundles.
3. Use the provider/deployment secret manager with named owner, creation time, scope, expiry/rotation interval, and revoke procedure. Rotate on personnel change, suspected exposure, and the scheduled interval; prove rotation in dev then QA before production.
4. Require multi-party, auditable break-glass access for production. Record incident ID, reason, time limit, approver, commands/artifacts, and revocation confirmation.
5. `qa` must never share a production credential, database, auth audience, invite namespace, APNs topic, storage bucket, or domain.

## 3. Manifest, bundle, and promotion record

Create a protected real manifest outside Git from the example. It contains identifiers and versions, never secrets: environment ID, Git ref, provider project/region, HTTPS endpoints, bundle/app/APNs IDs, domains, schema/API/scoring/feature-flag versions, telemetry/SLO/alert policies, and build/release/migration/approval identifiers.

Validate a development example (expected to fail until placeholders are replaced):

```bash
Scripts/validate_social_environment.sh --manifest /secure/path/development.json --branch dev
Scripts/social_v2_client_ci.sh --destination 'platform=iOS Simulator,id=SIMULATOR_UUID' \
  --manifest /secure/path/development.json --branch dev
```

The validator fails closed for missing/placeholder values, secret-like field names, HTTP endpoints (except explicit development localhost), mismatched branch/ref/bundle/APNs values, foreign environment markers, non-boolean flags, or content logging. QA requires `--branch qa`; production requires a matching `refs/tags/v*` value, never a mutable branch.

For every promotion, create an immutable promotion manifest/artifact containing: commit SHA; client build/version; backend release SHA/ID; environment/project/region; API, database schema, migration, scoring, and flag configuration versions; feature-flag values; test commands and result bundles; contract/security/migration results; physical-device evidence; checks not run and risks; approvers; rollout percentage; rollback decision; and incident links. It must contain no user content, invite tokens, credentials, or raw auth data.

## 4. CI and compatibility gates

### Local deterministic client gate

`Scripts/social_v2_client_ci.sh` runs `git diff --check`, validates the checked-in example JSON, runs the existing no-network audit, validates a supplied real manifest, and runs the shared Hindsight scheme (unit plus UI tests) against the supplied simulator destination. `--skip-xcode` is planning-only and cannot be used for QA or production approval.

### Required hosted gates after a backend is selected

| Stage | Required pass evidence | Block on failure |
|---|---|---|
| Feature → `dev` | formatting/lint, deterministic client unit/integration/UI smoke, accessibility smoke, no-network/privacy scan until approved networking exists, API-contract compatibility, secret scan | merge |
| `dev` → `qa` | exact dev SHA, filled QA manifest validation, server auth/authorization negatives, migration dry-run on fixtures, schema lint, generated-client/contract compatibility, content-scrub tests, QA TestFlight build | fast-forward/promotion |
| QA release candidate | two-device group loop, offline/relaunch, push/deep-link on physical devices, load/deadline race, backup/restore, rollback game day, manual VoiceOver/largest text/dark mode | external tester expansion |
| QA → production tag | all prior evidence, immutable tag, production manifest validation, approved change window, budget/alert readiness, privacy/security/release approvals | production deploy/flag enable |

Version compatibility rule: client sends supported API/contract range and schema/migration capability; server rejects unsupported writes with a stable update-required error. Database migrations are additive/expand-first, backward compatible through the QA window, and only contract/removed after all supported clients are past the minimum version.

## 5. Migration and release order

1. Accept ADR-008 and create isolated development/QA/production environments; leave all social flags false.
2. Run F0.4 contract/security tests and F0.5 privacy approval; produce synthetic fixtures.
3. Apply an additive migration to development, run migration dry-run/reconciliation and rollback on fixtures, then deploy compatible backend release.
4. Build/test the client against development with disabled flags. Promote the exact commit and backend/schema versions to QA; apply the same migration to QA only after QA backup/restore preflight succeeds.
5. Perform QA recovery game day and release candidate evidence. Create immutable production tag/artifact, verify production backup/restore readiness, apply expand migration, then deploy backend/client in compatibility order.
6. Enable flags gradually (`social_read`, then restricted `social_write`; private sync/migration only after their specific consent/recovery tests). Record every change in the promotion manifest. Never enable a flag to work around a failed gate.
7. Contract only after the minimum client-version window, migration completion evidence, and explicit approval. Legacy records remain local unless the user consents.

## 6. Content-free telemetry, SLOs, and alerts

Use opaque correlation/operation/resource IDs, environment, build/API/schema/scoring/flag versions, state/result/error class, duration bucket, retry count, and authorized role class. Never record prediction/outcome/note text, group names, handles, invite/auth tokens, email, raw URLs with identifiers, precise location, raw push payloads, or request/response bodies.

Before launch, approve numeric SLOs and owners for: API availability/latency, lock acceptance/rejection/error rate, queue age, unknown-operation reconciliation, sync convergence, delayed reveal jobs, push delivery attempts, auth failures, authorization denials, migration discrepancy, backup success, restore RTO/RPO, moderation/report backlog, and budget burn. Alerts must include environment and correlation ID, page only actionable severity, and route lower severity to the owning queue. Validate telemetry scrubbing with fixtures and tests before writing any social content.

## 7. Flags, incident response, rollback, and database recovery

Maintain independently scoped, auditable flags: `social_read_enabled`, `social_write_enabled`, `private_sync_opt_in_enabled`, `migration_start_enabled`, and `background_sync_enabled`. Default all false. A flag stops new action paths but must preserve local journal access, drafts, backup/export/recovery, and honest cached/offline labels; it must never delete records or turn an unknown operation into a successful one.

### Rollback and restore game day

1. **Detect/contain:** identify environment/version/correlation IDs; disable the narrowest relevant flag and pause workers/outbox dispatch. Do not inspect content to diagnose.
2. **Protect boundaries:** revoke suspected credentials, stop cross-environment traffic, retain immutable audit and promotion evidence, and freeze destructive migrations.
3. **Classify:** establish impacted account/resource scope from opaque IDs, schema/checkpoint, audit ledger, and content-free telemetry.
4. **Recover:** retry an idempotent local/server operation where safe; otherwise restore into an isolated copy from verified backup, validate counts/checksums/audit continuity, and obtain approval before cutover. Never overwrite the sole original database/store.
5. **Communicate/re-enable:** explain known state and safe next action without false success claims. Re-enable only after root cause, fixed release, fixture regression, authorization and account-binding checks, migration dry-run, and release/security approval.

Run a QA-only synthetic-data game day before Social v2 beta: simulate a bad migration, cross-environment endpoint attempt, credential revocation, delayed job, and restore. Capture RTO/RPO, alert timing, flag change, integrity validation, approvals, and follow-up items. Production restore is a scheduled, approved rehearsal; never test by restoring over live data.

## 8. Required approvals and current blockers

| Decision/approval | Accountable owner | Current state/blocker |
|---|---|---|
| Backend/provider and ADR-008 spike | product, backend, security | Proposed; no provider/project/SDK approved |
| F0.4 API/schema and compatibility range | backend + iOS | Not accepted |
| F0.5 privacy, retention, deletion, telemetry | privacy/legal + product | Not accepted |
| Environment creation/budgets/secrets | operations + finance/security | Blocked until backend choice and owners |
| APNs, associated domains, app IDs | iOS release owner | Blocked until bundle/domain plan is approved/provisioned |
| Hosted CI/secret scanning/observability | operations + engineering | No hosted implementation in this task |
| QA promotion and TestFlight cohort | QA + release owner | Blocked on all QA gates above |
| Production deploy/flag enable | release owner + security/privacy | Blocked on immutable QA evidence and approvals |

## 9. Evidence checklist and handoff

Before calling F0.7 `done`, attach redacted environment inventories; validated real manifests; access/rotation evidence; hosted pipeline links; exact result bundles; environment-isolation negatives; migration dry-run/backup/restore report; content-scrub test results; dashboards/alerts; budget proof; QA game-day report; promotion manifests; and approver records. Until then, F0.7 is `verification_pending` beyond the local assets in this repository.
