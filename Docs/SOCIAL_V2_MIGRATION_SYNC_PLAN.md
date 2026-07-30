# Hindsight Social v2 — Local Data Migration and Sync Recovery Plan

**Task:** F0.6 — Plan local-data migration, offline behavior, and sync recovery
**Status:** `code_complete` for the planning/contract deliverable; application and backend implementation are not started.
**Owners:** iOS, backend, privacy, QA, release operations
**Prerequisites:** F0.3 backend ADR accepted, F0.4 domain/API contracts accepted, F0.5 privacy/deletion rules accepted, and F0.7 environment/kill-switch controls implemented before any user-facing rollout.

## 1. Purpose and non-negotiable rules

**Summary:** Introduce networked Social v2 without changing the ownership of an existing journal by surprise.

**User story:** As an existing Hindsight user, I want my decisions to remain intact and private while I decide, item by item, whether any new account-backed capability is useful to me.

**Why:** The present SwiftData graph contains potentially irreplaceable decision notes and outcomes. A server-authoritative social forecast is a different object and must never be manufactured by uploading or relabelling legacy data.

**What:** This contract defines the data inventory, authority boundaries, migration stages, optional private sync, explicit social conversion, offline outbox/cache behavior, recovery, and proof requirements.

**How:** Keep legacy `Decision` graphs device-authoritative by default; place future storage behind repository protocols; use versioned local migrations, stable IDs, durable idempotency keys, server versions, and an independently controllable migration feature flag.

**Expected result:** A failed upgrade, sign-out, reinstall, backend outage, or rollout rollback never deletes local journal records and never shows a social forecast as locked without server acknowledgement.

### Rules

1. **No silent upload:** No legacy decision, option, prediction, review, note, derived statistic, export, notification content, or preference is sent to a network endpoint before a deliberate, recorded consent action.
2. **No false authority:** A device may say `draft`, `queued`, `sending`, `failed`, or `cached`; only a server response can say `locked`, `resolved`, or `scored` for social data.
3. **No implicit conversion:** A legacy `Prediction` is never retroactively a social forecast. Conversion creates a new social event/forecast and states that its server timestamp begins at conversion.
4. **Preserve local utility:** Local capture, review, reminders, export, and deletion continue when unauthenticated and offline.
5. **Bound identity:** An outbox entry is permanently bound to one internal account ID and one environment. It cannot run after sign-out or under a different user.
6. **Minimize stored network content:** Cache only the minimum authorized social read model; never put auth tokens, private journal text, invite tokens, or raw remote payloads in analytics/logs.
7. **User choice survives release changes:** Consent and migration receipts are locally durable, exportable as metadata, reversible for future sync (by stopping future copies), and never treated as blanket permission for a new visibility scope.

## 2. Legacy-data inventory and disposition

The inventory is derived from the current SwiftData models and `AppStorageKeys`. “Private sync eligible” means a later, F0.4/F0.5-approved private vault schema may copy the data only after explicit consent; it is **not** permission to publish or turn it into a group prediction.

| Current object / field | Current meaning | v2 disposition and authority | Privacy/default rule | Migration verification |
|---|---|---|---|---|
| `Decision.id` | Stable local UUID / reminder identity | Preserve unchanged as `legacyLocalID`; never reuse as a server social ID. Device authority. | Never upload by default. | Unique UUID count and duplicate scan match preflight. |
| `Decision.title` | Decision text | Retain local verbatim; optionally private-sync only as encrypted/content-bearing data after separate consent. Not eligible for automatic social conversion. | Local-only default; never log. | UTF-8/content hash and count match. |
| `Decision.notes` | Free-form private notes | Retain local only; private-sync eligible only behind an explicit “include notes” consent choice. | Local-only default; conversion excludes it. | Hash/count match, including empty/non-empty split. |
| `Decision.category` | Local category enum | Retain local; private-sync eligible as metadata if item opted in. | Local-only default. | Raw-value validity and count by category match. |
| `Decision.stakesLevel` | Local sensitivity/impact | Retain local; do not map to social ranking or visibility. | Local-only default. | Raw-value validity/count match. |
| `Decision.status` | Local lifecycle | Retain local; never map directly to social event state. | Local-only default. | Count by status matches. |
| `Decision.isReversible`, `clarityScore` | Local decision metadata / derived score | Retain local. `clarityScore` may be recomputed only after migration and must match current algorithm or be marked recomputed. | Do not upload automatically. | Boolean distribution and recomputation report. |
| `Decision.chosenOptionTitle` | Local selected option | Retain local; never infer a social outcome or vote. | Local-only default. | Referential check against option titles; retain orphaned legacy values. |
| `Decision.createdAt`, `decidedAt`, `dueDate`, `deadline` | Historical and reminder dates | Preserve exact instants/time-zone semantics. They are not server-lock evidence. | Local-only default. | Min/max/count and per-record checksum match. |
| `Decision.options` / `DecisionOption.id` | Local alternatives | Preserve relationship and all child IDs locally; private-sync only with the parent and explicit consent. | No automatic upload; never become social outcome choices without editing. | Parent/child cardinality and IDs match. |
| `DecisionOption.title`, `upside`, `downside` | Often sensitive free text | Retain local verbatim; optional private sync only when parent and content consent permit. | Local-only default; conversion starts with a fresh social outcome editor. | Field hashes and null/empty counts match. |
| `DecisionOption.effortLevel`, `riskLevel`, `gutFeeling` | Local ratings | Retain local metadata; no social-score mapping. | Local-only default. | Range validation/count match. |
| `Decision.predictions` / `Prediction.id` | Local forecasts | Preserve locally. A user may choose private sync or use it as editable source text for a **new** social event. | Never server-lock retrospectively. | Parent count, IDs, due dates, statuses match. |
| `Prediction.title`, `probabilityPercent`, `dueDate`, `status`, `actualResult` | Local forecast content/result | Preserve locally. Private-sync eligible per item; social conversion requires fresh audience/outcomes/deadline/visibility and an explicit submit. | Local-only default; no automatic score/leaderboard import. | Content hash, range and status checks match. |
| `Decision.outcomeReview` / `OutcomeReview.id` | Local retrospective | Preserve locally; private-sync eligible only with separate rich-content consent. Never map to server resolution evidence. | Local-only default. | One-to-one relationship and checksum match. |
| `OutcomeReview` content/ratings/date | Personal outcome narrative | Retain exact local record. Social conversion may not copy it into group resolution or score. | Never automatically upload. | Field hash/range/timestamp match. |
| SwiftData relationships / cascade rules | Decision owns options, predictions, review | Preserve graph before adding sidecar sync tables; no destructive rewrite of existing graph. | Device-authoritative legacy graph. | Orphan, cycle, and cascade-integrity report. |
| Demo decisions (`SampleData` stable provenance) | Removable sample records | Preserve or remove only through existing explicit demo control. Exclude from migration counts for user data, exports of user data, analytics, and sync eligibility by default. | Never upload as user records. | Demo IDs counted separately. |
| Local notifications / request IDs | Review reminder scheduling | Reconcile from retained local graph after successful migration; social push state is separate. | No notification body/content upload. | Expected pending reminder IDs match eligible local records. |
| `userName` | Local greeting preference | Retain locally; do not assume it is a public handle. Offer deliberate profile-choice UI later. | Local-only default. | Value remains present after relaunch. |
| `reviewReminders`, `didRequestNotifications` | Local reminder and permission flow | Retain device-local settings; never sync permission state as account data. | Device-only. | Exact defaults/values preserved. |
| `hasLaunchedBefore`, `hasCompletedOnboarding`, quick-capture nudge | Device UX progress | Preserve locally; Social v2 onboarding adds versioned keys rather than reusing semantic meaning. | Device-only. | Existing flows do not re-trigger unexpectedly. |
| `hapticsEnabled` | Device preference | Retain device-local only. | Device-only. | Exact value preserved. |
| JSON/PDF exports | User-generated files outside the store | Not migrated or deleted; remain user-controlled artifacts. New export includes scope/source metadata. | Never scan/upload. | Existing export still opens; new export flags local vs synced scope. |
| Store-recovery exports/backups | Recovery artifact | Preserve until explicit user deletion; do not auto-upload or include in social cache. | Local/user-controlled. | Recovery artifact discoverability test. |

## 3. Authority, consent, and conversion contract

### 3.1 Data domains

| Domain | Authority | Offline behavior | Default | User control |
|---|---|---|---|---|
| Unsaved composer draft | Device | Durable local draft; never networked until an allowed submit | Local | Edit/discard/export where supported |
| Legacy decision journal | Device | Fully usable offline | Local-only | Per-item/bulk private-sync opt-in; never public by migration |
| New private synced item | Server for its copy; device cache for reads | Local edit drafts may queue only if contract permits; confirmation reconciles server version | Off until opted in | Stop future sync, delete server copy per policy, retain local original |
| New group/social event and forecast | Server | Cache/view allowed; submit queues only when deadline policy permits | Explicit group audience | Leave group, delete eligible draft, never rewrite lock |
| Profile/session/membership | Server | Cache may be stale-labelled; no client authorization | Not created until sign-in | Sign out/deletion/resume only after server confirmation |

### 3.2 Consent flows

**Private sync opt-in:** The user selects one or more local items (or an explicitly scoped bulk selection), sees exactly which fields will be copied, selects whether notes/reviews are included, confirms account and environment, and receives a `syncConsentReceipt` containing local IDs, field-scope version, timestamp, account ID, and operation IDs. Default answer is **Not now**. Cancellation sends nothing.

**Social conversion:** From a local prediction/decision, “Create group prediction” opens a new composer prefilled only as an editable draft. It requires a group, outcomes, visibility, future server deadline, resolution rule, explicit confidence, and final submit. The confirmation says: “Your original local entry stays private. This new group prediction will be timestamped when the server accepts it.” It never copies private notes/reviews by default and never represents the original `createdAt` as a social timestamp.

**Consent withdrawal:** Stopping private sync prevents future uploads and pauses the related outbox. It does not silently delete a server copy; provide an explicit server-copy deletion action governed by F0.5 retention/deletion policy. It never deletes the local original.

### 3.3 Repository boundary

Views and view models must depend on domain protocols, not SwiftData context or HTTP clients. Initial protocol families: `LocalJournalRepository`, `PrivateSyncRepository`, `SocialEventRepository`, `SyncOutboxRepository`, `AccountSessionRepository`, and `MigrationRepository`. Each exposes typed snapshots, state transitions, opaque IDs, cancellation, and typed errors. The SwiftData adapter owns legacy graph access; the API adapter owns request/response mapping; the coordinator owns ordering/retry. Deterministic in-memory fakes are required for UI and state-machine tests.

## 4. Local state, outbox, cache, and confirmation semantics

### 4.1 Sidecar records (planned; do not alter existing models until F0.4)

Create new versioned sidecar storage rather than mutating legacy semantics: `MigrationCheckpoint`, `LegacyItemMapping`, `SyncConsentReceipt`, `OutboxOperation`, `RemoteSnapshot`, `Tombstone`, and `SyncCursor`. Every record includes schema version, environment ID, account binding where applicable, created/updated UTC timestamps, and opaque correlation ID. Sensitive content is stored only where the approved encryption/key-management design permits it.

### 4.2 State machine

| State | Meaning / UI copy | Allowed transition | Prohibited claim |
|---|---|---|---|
| `local_only` | “Saved only on this iPhone” | opt-in → `queued` | synced/shared/locked |
| `draft` | Incomplete local work | edit/discard/eligible submit | submitted |
| `queued` | Permitted mutation durably waiting for network | sending/cancel/expired/rejected | locked/resolved |
| `sending` | Request in flight; duplicate taps disabled | confirmed/retryable failure/rejected | accepted before response |
| `server_confirmed` | Server returned ID/version/UTC receipt | cached/stale refresh | future local edits rewrite history |
| `failed_recoverable` | Network/transient fault with retained work | retry/cancel/export | automatic loss |
| `rejected_final` | Server returned non-retryable rule violation | copy/edit-as-new/discard | retry will succeed unchanged |
| `conflicted` | Concurrent editable record requires policy/user choice | merged/choose-copy/discard-local | one side silently won when policy says user choice |
| `tombstoned` | Server/local deletion marker blocks resurrection | purge after retention / restore only through approved recovery | active/readable data |
| `removed_access` | Membership/account authorization ended | retain permitted local draft/export; stop operations | continued group access |

### 4.3 Server confirmation

A successful social mutation response must include `operation_id`, server resource ID, server version, server UTC acceptance/lock time where applicable, state, and canonical snapshot or cursor. The client atomically records the receipt before rendering a `Locked` state. A timeout after request dispatch is **unknown**, not failure or success: retain the same idempotency key, query operation status after reconnect, and do not generate a new mutation. Broadcast/push may trigger reconciliation but is never confirmation.

### 4.4 Idempotency, retry, and backoff

- Generate one UUID idempotency key per logical mutation before dispatch; persist it before any network attempt.
- Server deduplicates by `(environment_id, actor_account_id, idempotency_key, operation_type)` and returns the original receipt for replay.
- Store request contract version, sanitized payload digest, target resource/local ID, deadline, expected server version, account ID, environment ID, attempt count, last safe error code, and next-attempt time.
- Retry only retryable transport/5xx/rate-limit codes; use full-jitter exponential backoff (base 2 seconds, cap 5 minutes, maximum 8 automatic attempts) plus reachability as a hint, not proof. Respect server `Retry-After`.
- Social forecast submits stop automatic retries at server deadline; status query may still resolve an unknown operation. Expired unsent work becomes `rejected_final: deadline_passed` with “Copy as a new prediction.”
- Never retry authorization, validation, membership removed, account mismatch, environment mismatch, or final lock/deletion errors without a new user action and new operation.

## 5. Conflict matrix

| Entity / fields | Concurrent situation | Resolution | User experience |
|---|---|---|---|
| Legacy local journal | Any remote event | No remote merge unless separately opted into private sync | Original remains local and untouched. |
| Private synced rich text | Different edits to same text fields | Preserve both versions; require explicit compare/choose/copy-as-new. | “We kept both versions; choose what to keep.” |
| Private synced scalar metadata | Non-overlapping field edits | Field-level merge using server version/vector policy from F0.4. | Silent only when non-overlapping and auditable. |
| Profile handle | Same handle claimed | Server wins uniqueness; user chooses a new handle. | Clear availability error. |
| Profile display preferences | Two devices | Last server version wins only for non-sensitive preferences, with timestamp displayed in diagnostics. | No hidden overwrite for handle/avatar. |
| Group membership/invite | Member removed/revoked while queued | Server rejects; tombstone access cache; retain unrelated local draft. | “You no longer have access; your private draft is still on this device.” |
| Social event prompt/outcomes/deadline | Admin edit races participant action | Server version precondition; immutable-after-publish policy; conflict rejects stale edit. | Refresh then edit new revision where allowed. |
| Social forecast | Duplicate/replay or two devices submit same logical call | First atomic server acceptance wins; replay returns same receipt; distinct second forecast rejected per event rule. | One confirmed lock, never two. |
| Locked forecast/resolution/score | Any client edit | Server immutable ledger; correction only append-only authorized flow. | Read-only history plus correction explanation. |
| Delete vs local cached edit | Server delete arrives before queued edit | Tombstone wins; cancel mutation, preserve exportable local draft only where policy permits. | Explain deletion, do not resurrect data. |
| Account deletion vs outbox | Deletion requested/confirmed | Freeze all account-bound operations; destroy credentials; retain only local journal and policy-required tombstones. | Deletion status/recovery support route. |

## 6. Account, device, and lifecycle behavior

### Sign out

Pause and encrypt/preserve only account-bound outbox diagnostics needed to explain pending work; do not dispatch them. Remove session credentials from Keychain, clear decrypted server cache, unsubscribe realtime/push routes, and mark outbox `account_binding_required`. On next sign-in, resume only after exact internal account ID and environment match. If they differ, retain eligible local drafts as private drafts; never transplant a group mutation.

### Account deletion

Before confirmation, show server deletion effects and local-data distinction. After server confirmation, revoke tokens, remove server cache, cancel/terminalize outbox operations, and retain the device-local journal unless the user separately selects local deletion. Maintain privacy-approved tombstones only to prevent replay/resurrection for the required retention period. Never call local journal deletion as a side effect of account deletion.

### Reinstall/new device

Uninstalled app data may be removed by iOS; therefore existing local-only records cannot be promised to restore after uninstall unless the user first created/exported a backup or explicitly opted into approved private sync. After authentication, restore only authorized server/private-synced records and social history. Do not infer that absence of a local store grants permission to upload from a backup.

### Downgrade

Use additive sidecar schema changes and keep legacy model fields readable. A pre-v2 binary may not understand sidecar records or social features; it must continue reading the original journal or show a safe “update required for synced/social data” gate. Never destructively alter legacy graph shape merely to support a downgrade. If a new migration cannot downgrade, offer export and retain original preflight backup until the release rollback window closes.

## 7. Versioned migration, preflight, and interruption recovery

### 7.1 Stages

1. **Detect:** Read store schema/app version without writing; determine supported upgrade path.
2. **Preflight:** Confirm free disk budget, writable store, no unresolved recovery state, supported schema, and backup destination. Calculate record/relationship counts and content-safe hashes.
3. **Backup:** Create encrypted/recoverable local store copy and a manifest containing app/schema version, SHA-256 file hash, per-entity counts, relationship counts, timestamp, and backup location. Never upload it.
4. **Prepare:** Add only sidecar metadata/schema in a transaction; set checkpoint `prepared`, not complete.
5. **Transform:** Assign migration metadata and preserve original UUIDs/timestamps without creating remote mappings or network work.
6. **Validate:** Reopen store, validate graph/invariants, compare manifest counts/checksums, recompute derived reminders/indexes, and record discrepancies.
7. **Commit:** Atomically mark `local_schema_version` and checkpoint `validated`; only then expose v2 local UI. Sync consent remains a separate later action.
8. **Recover:** If interrupted or validation fails, reopen from checkpoint, retry idempotent local stage or restore backup; never reset/replace silently.

### 7.2 Reconciliation rules

Required zero-loss comparisons include Decision/Option/Prediction/OutcomeReview counts, IDs, parent-child cardinality, date min/max, enum/raw-value distributions, content hash for every content-bearing field, demo provenance count, and expected reminder IDs. A discrepancy blocks completion and produces a support-safe diagnostic with opaque store/migration IDs, not content. Migration data-loss SLO is **zero** for supported source stores.

### 7.3 Interruption and low-resource behavior

Persist each stage transactionally; operations are restartable and idempotent. On process termination, crash, device restart, power loss, storage-full, lock contention, malformed store, or canceled update, the next launch presents `Recovering your local journal` rather than onboarding/reset. It offers retry, export-for-support, and restore-from-backup; destructive reset remains separately double-confirmed and unavailable until an export/backup opportunity is shown.

## 8. Tombstones, kill switch, rollback, and recovery runbook

### Tombstones

Server deletes/access removals produce signed/versioned tombstones keyed by resource, account, environment, reason class, and server version. A tombstone prevents stale cache/outbox resurrection. Local legacy records have no tombstone merely because a server account or social copy is removed. Purge only after F0.5 retention approval and successful reconciliation.

### Kill switch

F0.7 must provide independently scoped, signed/configured flags: `social_read_enabled`, `social_write_enabled`, `private_sync_opt_in_enabled`, `migration_start_enabled`, and `background_sync_enabled`. A kill switch stops new network writes/consent presentation but preserves local reads, drafts, backup/recovery, and already-confirmed cached social history with accurate stale/offline labels. It must not delete data or report a failed operation as rolled back.

### Rollback/recovery runbook

1. **Detect and contain:** On migration discrepancy, unauthorized cross-account risk, elevated corruption, or unsafe sync rate, disable `migration_start_enabled` and/or `social_write_enabled`; preserve logs without content.
2. **Stop propagation:** Pause workers/outbox dispatch, revoke compromised environment credentials, and prevent QA/dev/prod cross-environment calls.
3. **Classify:** Use opaque migration IDs, app/build/schema versions, checkpoint, manifest result, operation IDs, and server audit records to identify scope.
4. **Recover local data:** Prefer transactional retry; otherwise restore the verified preflight backup into a copy, validate checksum/counts, and provide user export before any replacement. Never overwrite the only original store.
5. **Recover server state:** Reconcile by operation IDs and immutable audit ledger; replay only idempotent operations in the same account/environment after incident approval.
6. **Communicate:** Tell affected users what state is known, what remains local, what actions are paused, and the safe next action. Do not claim restoration until verification completes.
7. **Re-enable:** Require incident owner approval, fixture regression, migration dry-run, account-binding test, and documented root cause/rollback evidence before staged re-enable.

## 9. Fixture catalog and required tests

### 9.1 Fixture stores

Generate anonymized, deterministic copies—not customer data—from every supported shipping schema/build: baseline empty; one quick-capture record; full decision graph; multiple predictions with pending/correct/incorrect/partial results; reviewed decision; due and past-due reminders; all enum values; Unicode/long text; missing optional values; stable demo records; large 1k/10k-record stores; legacy title-based demo compatibility; duplicate/invalid relationships; malformed/corrupt store; low-disk simulation; interrupted checkpoints at every stage; prior backup/restore pair. Record source app/schema version, expected manifest, supported upgrade result, and fixture generator hash.

### 9.2 Named automated tests

- `LegacyJournalInventoryTests`: field-by-field inventory mapping, enum/range/relationship preservation.
- `MigrationPreflightTests`: disk/store/schema checks, immutable manifest generation, no write before backup.
- `MigrationChecksumReconciliationTests`: all fixture counts/hashes/cardinality/reminders equal before/after.
- `MigrationInterruptionRelaunchTests`: kill at Detect through Validate, relaunch, resume/recover without reset or loss.
- `MigrationRollbackRestoreTests`: failed validation restores a copy from backup and retains original/export.
- `MigrationNoNetworkBeforeConsentTests`: URLProtocol/network capture proves zero requests from detection through local migration and “Not now.”
- `PrivateSyncConsentTests`: field-scope receipt, cancellation, withdrawal, and per-item/bulk separation.
- `SocialConversionTests`: source remains unchanged; new event requires fresh required fields; no historic lock claim.
- `RepositoryBoundaryTests`: views use fakes; SwiftData/API adapters cannot leak each other’s storage semantics.
- `OutboxIdempotencyTests`: duplicate tap, timeout/retry, replay, and two-device race yield exactly one server operation/receipt.
- `OutboxAccountBindingTests`: sign-out, different-account sign-in, deleted account, and environment change cannot dispatch old work.
- `SyncBackoffDeadlineTests`: jitter/backoff/Retry-After behavior and deadline expiry create truthful final state.
- `SyncConflictMatrixTests`: every row in section 5 has deterministic server/client outcome and UI state.
- `TombstoneAntiResurrectionTests`: stale cache/outbox cannot recreate deleted/removed social data.
- `OfflineRelaunchNetworkCaptureUITests`: local capture/review/export work offline; queued vs locked text, largest Dynamic Type, VoiceOver labels, dark mode, and relaunch behavior are proven.
- `TwoDeviceConvergenceIntegrationTests`: same account converges authorized snapshots; different accounts and environments cannot.
- `DowngradeCompatibilityTests`: old binary opens legacy graph safely and never processes sidecar/social writes.

### 9.3 Manual/release evidence

For every supported source fixture, attach before/after manifests, checksum reconciliation output, migration build/schema version, device/OS, offline recording, and a redacted network capture. Run the recovery tabletop on QA with synthetic accounts only. Record exact commit, API/schema versions, feature flags, test command/result bundle, checks not run, owner sign-off, and rollback decision in the promotion manifest.

## 10. Acceptance, evidence, and unresolved gates

### Acceptance criteria

1. Every listed legacy field has an implemented, tested disposition and no removed/unmapped data path.
2. A supported upgrade preserves 100% of fixture records/relationships/content hashes and does not initiate network traffic before consent.
3. Consent text differentiates local-only, private sync, and group conversion; a conversion cannot present original local timestamps as server verification.
4. Offline/relaunch/retry flows retain work, avoid duplicate consequential operations, and do not attach work across accounts or environments.
5. Server-confirmed locks are immutable client snapshots; unknown operation status is reconciled rather than guessed.
6. Kill switch and recovery tabletop demonstrate that rollback stops new writes without data deletion.
7. Accessibility states expose local/queued/sending/locked/failed/conflicted/recovery status without color or motion alone.

### Required evidence before F0.6 is `done`

- Accepted F0.3/F0.4/F0.5/F0.7 gates and approved sidecar/API schemas.
- Fixture catalog and generator committed; all named unit, integration, relaunch, UI, and network-capture tests green in isolated QA.
- Two-device same-account convergence recording and wrong-account/environment rejection evidence.
- Backup restore and kill-switch recovery game-day report with synthetic data.
- Privacy/security review confirming no silent upload or sensitive logs, plus product copy review of consent/conversion.

### Open gates/blockers

- ADR-008 is proposed pending its decisive spike; no production backend or provider SDK is approved.
- F0.4 must specify canonical private-sync fields, resource versions, error codes, deletion retention, and operation-status endpoint before implementation.
- F0.5 must approve encryption/key management, consent copy, private-sync retention/deletion, support access, and export policy.
- F0.7 must provision isolated environments, remote configuration/kill switches, observability, QA fixtures, and promotion/recovery ownership.
- Product owner must choose whether private sync permits rich `notes`/`OutcomeReview` content per item; this plan defaults them to local-only.

## 11. Implementation handoff order

1. Ratify the open gates; create the sidecar/API data contract under F0.4.
2. Build deterministic fixture generator and preflight/migration harness before user-facing migration UI.
3. Add repository protocols and fakes; preserve current local paths through the SwiftData adapter.
4. Implement migration/checkpoint/backup/reconciliation with all local-only tests and no network dependency.
5. Implement authenticated cache/outbox/operation-status reconciliation behind disabled flags.
6. Implement consent and conversion UI only after privacy copy/backend confirmation are accepted.
7. Run QA recovery and two-device evidence; then perform a staged, reversible rollout with flags.
