# Hindsight Social v2 — Domain and API Contract

**Status:** proposed draft — not approval to implement, select a vendor, process participant data, or generate a client.

**Applies to:** F0.4. **Depends on:** F0.3 ADR acceptance and F0.5 privacy/safety/legal approvals. This is the normative semantic companion to `Contracts/social-v1.openapi.yaml`; the API description does not expose database or provider APIs.

## 1. Global conventions

- IDs are opaque, immutable UUID or ULID strings. Clients must not infer creation time, tenancy, or identity from an ID.
- All authoritative timestamps are server-issued RFC 3339 UTC instants (`...Z`). Client timestamps are diagnostic only and never decide a deadline, lock, membership, resolution, or score.
- Every server record has `version` (positive integer) and `created_at_utc` / `updated_at_utc`; an update requiring concurrency protection supplies `If-Match: "<version>"`. A mismatch returns `CONFLICT_VERSION` and the current representation when safe.
- Write endpoints require an opaque `Idempotency-Key` (1–128 printable characters, unique per authenticated actor and operation for a retention window **TBD by F0.5/operations**). Same key + same canonical request returns the original response; same key + different request returns `IDEMPOTENCY_KEY_REUSED`.
- List endpoints use opaque, signed/encoded cursors; cursors are not offsets and must not be parsed. Results have a stable sort documented per endpoint, `next_cursor`, and a snapshot/as-of boundary where the endpoint needs one.
- Payloads carry `schema_version: "social.v1"`. Additive compatible fields are allowed; breaking changes require a new path/version and a deprecation window **TBD by F0.7**. Unknown enum values must render safely as unavailable/unknown and must not become permission grants.
- `deleted_at_utc` means tombstoned rather than physically erased. A tombstone preserves minimum IDs, type, deletion time, deletion actor category, and legal/operational hold marker; it suppresses normal reads and cannot expose deleted content. Actual retention periods and legal-hold policy are **TBD F0.5**.
- Server responses include `X-Request-ID`; accepted writes include an `audit_event_id`. Realtime messages are hints only: clients reconcile from the API using a version/cursor after reconnect or a sequence gap.

## 2. Domain entities, ownership, visibility, and lifecycle

Visibility values: `private` (owner only), `group` (current eligible membership as of each read), `unlisted` (explicit link/receipt recipient policy; no search/indexing), `public` (not Phase 1), and `system` (authorized operators only). Phase 1 permits only private/group social objects and deliberately redacted unlisted Receipts.

| Entity | Owner / authority | Visibility & sensitivity | Retention / delete behavior |
|---|---|---|---|
| User | Server; immutable account ID | `system`; identity/auth attributes highly sensitive | Account deletion creates a deletion request/tombstone; hard-delete schedule and legal hold TBD F0.5. Apple subject/auth material is never public or in analytics. |
| Profile | User, subject to moderation | Private by default; display handle/avatar policy TBD F0.5 | User may edit subject to version; deletion anonymizes/disassociates public-facing fields as policy permits. |
| Friendship | Server relationship between two users | Private to endpoints; Phase 1 does not require friend graph | Both endpoints may remove; block overrides any discoverability. Retention/audit TBD. |
| Group | Creator/admin; server enforces roles | `group`; name/avatar/description are sensitive UGC | Owner delete archives group, revokes invites, removes access; historical integrity records are tombstoned/retained per policy. |
| Membership | Server, group/admin action or accepted invite | `group`; role/status sensitive | Leaving/removal ends future access; it never rewrites eligible historical forecast/audit records. |
| Invite | Group admin; server-generated opaque credential | Secret token is highly sensitive; preview is minimum, policy-gated | Revocable, expiry-bound, single/multiple use policy TBD. Store token only hashed at rest; never log it. |
| PredictionEvent | Group-authorized creator; server owns lifecycle clock | `group`; prompt/outcomes can be sensitive UGC | Archive/tombstone hides content but preserves minimum integrity ledger; no public events in Phase 1. |
| OutcomeOption | Event creator before open; immutable after open | Same as event | Cannot be changed after event opens; event draft edits replace draft version. Tombstoned only with event/void policy. |
| Forecast | Author; server owns lock/time/state | Author sees own; other members depend on blind/reveal policy | Immutable once locked. Account/group deletion removes normal access but preserves redacted ledger per policy. |
| ForecastRevision | Forecast author before lock; server append-only | Author plus authorized integrity access | Never mutates locked original; pre-lock revisions identify supersession. Retain with forecast integrity record. |
| ResolutionRule | Event creator/admin before open; server validates | `group`; rule must be visible to eligible forecasters before submit | Immutable after open; a changed rule requires a new/draft event. |
| Resolution | Authorized resolver; server owns state | `group`; evidence metadata visible to eligible members | Append-only proposals/corrections; void/correction preserves prior version and reason. |
| Evidence | Resolver/authorized contributor | `group`; URL/text may be sensitive and untrusted | Validation/redaction/retention TBD F0.5; content not sent to product analytics. |
| Appeal | Eligible affected member | Reporter, resolver, and least-privilege operator only | Closed/withdrawn records retained under safety/legal policy TBD; no silent deletion. |
| ScoreEntry | Server-only derived ledger | Eligible group members; public aggregation not Phase 1 | Append-only versioned score entries; correction creates compensating entry, never overwrites. Formula/sample gates **TBD Product/Data**. |
| Receipt | Author-requested server/client render primitive | `private` until explicit share; generated output is `unlisted` only if policy approves | Contains only allowlisted, redacted fields; can be revoked/expired; no invite/group name by default. |
| NotificationPreference | User | `private`; sensitive behavioral preference | User editable; account deletion removes except minimal audit required by law/policy. |
| Report | Reporter submits; server controls state | Reporter/moderator only; highly sensitive narrative | Retain/access/appeal SLA TBD F0.5; never expose reporter identity to subject by default. |
| Block | Blocking user; server-authoritative | Private to blocker/system | Immediate mutual interaction/discovery suppression; removing a block is prospective and audited. |
| ModerationAction | Authorized moderator | `system`, with outcome notice to affected party where policy requires | Append-only, reversible only by a new reviewed action; retention TBD F0.5. |
| AuditEvent | Server | `system`; contains actor category, target ID, action, request/correlation IDs—not secrets/content | Append-only/WORM-style logical ledger; retention/access/export policy TBD F0.5/F0.7. |

Required referential behavior: no child record can silently become visible because a parent is deleted; delete/leave/revoke revokes future authorization atomically. Integrity artifacts (locked forecast, resolution history, score ledger, audit) are not cascade-erased by ordinary UI deletion. F0.5 must approve exact data-subject deletion/anonymization and retention periods before participant data exists.

## 3. Actors and authorization baseline

`anonymous` may validate an opaque invite landing route only; it cannot retrieve group/event/forecast data. `member` has active membership. `admin` is an active membership with configured admin role. `creator` is the event/group creator only where the group policy grants the capability. `resolver` is explicitly appointed by the event rule. `moderator` is a least-privilege service role. `system` runs scheduled deadlines/scoring/notification jobs. Authorization is evaluated on every request at commit time; hiding UI is never authorization.

Blocks take precedence over friendship/discovery/invite interaction. Exact blocked-user behavior within an existing group is **TBD F0.5**; until ratified, a block must at minimum prevent new direct discovery/invite interactions and raise a policy-safe `BLOCK_RESTRICTED` response rather than reveal information.

## 4. State machines

### 4.1 PredictionEvent

States: `draft`, `open`, `locked`, `resolving`, `resolved`, `disputed`, `corrected`, `voided`, `archived`, `deleted`.

| Transition | Authorized actor / preconditions | Atomic side effects and emitted event | Retry |
|---|---|---|---|
| create → draft | Creator/admin; active group membership | Validate future deadline/rule/outcomes; audit `event.created` | Idempotent create key returns same draft. |
| draft → open | Creator/admin; ETag matches; >=2 explicit outcomes; future deadline; rule/audience complete | Freeze options/rule/visibility; audit `event.opened`; emit `event.updated` | Same key safe; stale version conflicts. |
| open → locked | System at server deadline, or authorized early-lock policy **TBD** | Reject new forecasts at commit; audit `event.locked`; emit `event.locked` | Job is idempotent; exactly one state change. |
| locked → resolving | Resolver/system; deadline reached | Audit and notify eligible members `event.resolving` | Idempotent transition. |
| resolving → resolved | Resolver; evidence satisfies declared rule; outcome valid; no unresolved blocking moderation/appeal policy | Append resolution + score-work request; audit `resolution.recorded`; emit `event.resolved` only after commit | Key/replay returns same resolution. |
| resolved → disputed | Eligible member/authorized operator; appeal accepted by policy | Append appeal reference; pause displayed finality as policy specifies; audit | Duplicate appeal deduped by idempotency key. |
| disputed → corrected | Resolver + required approval threshold **TBD** | Append correction/evidence; append compensating score entries; audit; emit `event.corrected` | Never overwrites old resolution. |
| resolving/disputed → voided | Authorized resolver/admin/system under declared reason policy | Append void reason; do not qualify ranking; audit/notify | Idempotent. |
| terminal → archived/deleted | Admin/system policy; no mutation of integrity ledger | Revoke normal content access/tombstone; audit | Idempotent. |

Forbidden: editing outcomes/rule/audience after `open`; resolving without evidence; moving terminal history backward; client-clock lock; direct score mutation.

### 4.2 Forecast and ForecastRevision

States: `draft_local` (client-only, never server truth), `queued` (client), `submitting` (client), `locked`, `rejected`, `superseded`, `tombstoned`.

| Transition | Authorized actor / preconditions | Side effects / invariants | Retry |
|---|---|---|---|
| local draft → queued/submitting | Forecast author; client action | No server lock claim | Local retry preserves same idempotency key. |
| submit → locked | Author is active eligible member, event `open`, server_now < deadline, one forecast-per-author/event policy, valid outcome/confidence, block/moderation checks pass | Transaction creates immutable forecast, server lock timestamp/version, audit `forecast.locked`; blind policy suppresses peers/aggregates | Same key returns locked forecast; concurrent duplicate yields original or `FORECAST_EXISTS`, never two locks. |
| pre-lock revision | Author, existing unlocked server draft only if server supports drafts **not Phase 1 default** | Append revision / supersede prior pre-lock draft | Version/key protected. |
| locked → superseded | System only for formally allowed correction before deadline **TBD; default prohibited** | Original remains ledger; replacement references original | No silent overwrite. |
| queued/submitting → rejected | Server rejects auth/deadline/validation/rate/version | Client receives stable code/retryability; local draft remains recoverable | Retry only when `retryable=true`; never attach to different user. |

Invariant: exactly one accepted locked forecast per `(event_id, author_id)` unless a future, ratified explicit revision policy says otherwise. A `ForecastRevision` is append-only and must identify `forecast_id`, prior revision/version, author, reason category, server time, and content hash; it does not change a locked value.

### 4.3 Invite

States: `active`, `redeemed`, `revoked`, `expired`, `exhausted`, `tombstoned`.

| Transition | Actor / preconditions | Side effects / retry |
|---|---|---|
| create → active | Admin; group active; rate policy passes | Generate opaque token once, store verifier/hash, audit `invite.created`; token returned only on create. |
| active → redeemed | Authenticated invitee; token valid, not blocked, capacity/policy passes | In one transaction create/activate membership and consume allowed use; audit `invite.redeemed`. Replay returns membership only to same actor or `INVITE_ALREADY_REDEEMED`. |
| active → revoked | Issuing/current admin | Immediate redemption denial; audit `invite.revoked`; no disclosure to prior opener. |
| active → expired/exhausted | System | Deny future redemption; audit. |
| any → tombstoned | Policy/deletion | Remove secret/verifier as permitted while retaining audit reference. |

### 4.4 Membership

States: `pending`, `active`, `left`, `removed`, `banned`, `tombstoned`.

| Transition | Actor / preconditions | Side effects / retry |
|---|---|---|
| create → pending/active | System via valid invite or admin policy; invite policy determines pending vs active | Membership + invite consumption atomically; audit; emit `membership.changed`. |
| pending → active | Invitee/admin where approval policy applies | Grant reads/actions only after commit. |
| active → left | Member | Revoke future authorization; queued writes fail authorization; preserve eligible historic ledger. |
| active/pending → removed | Admin; cannot violate owner/admin continuity rule **TBD** | Revoke token/session authorization and invites as applicable; audit/notify. |
| any nonterminal → banned | Moderator/admin under approved policy | Deny group access; audit; policy-safe notification. |
| terminal → tombstoned | Group/account deletion policy | Suppress ordinary representation; retain integrity reference. |

### 4.5 Resolution and Appeal

Resolution states: `proposed`, `resolved`, `disputed`, `corrected`, `voided`, `tombstoned`. Appeal states: `submitted`, `under_review`, `upheld`, `rejected`, `withdrawn`, `tombstoned`.

A resolver creates `proposed` only while event is `resolving`, with declared outcome and evidence references. The authorized finalizer rule, dual-approval threshold, evidence classes, correction and appeal SLA are **TBD F0.1/F0.5**; until approved, endpoint access can validate/record a proposal but must return `POLICY_NOT_CONFIGURED` for final public-facing resolution. `resolved` drives an asynchronous idempotent score-ledger calculation tagged with the scoring rule version. `corrected` and `voided` append, never mutate, prior resolution/score history.

## 5. API behavior and errors

All protected requests use a bearer session token supplied by the eventual identity boundary; its protocol is intentionally out of scope. `401` means missing/invalid session; `403` means authenticated but not authorized and must not leak existence. `404` may intentionally represent inaccessible resources. `409` is a valid state/concurrency outcome; `422` is a validation/policy outcome. Rate limits return `429` and `Retry-After` where known.

| Stable code | HTTP | Retryable | Meaning / client action |
|---|---:|---|---|
| `UNAUTHENTICATED` | 401 | no | Reauthenticate; preserve recoverable draft. |
| `FORBIDDEN` | 403 | no | Do not reveal hidden resource details. |
| `NOT_FOUND` | 404 | no | Object absent, tombstoned, or intentionally undiscoverable. |
| `VALIDATION_FAILED` | 422 | no | Render field-safe validation details. |
| `EVENT_NOT_OPEN` | 409 | no | Refresh event; do not claim lock. |
| `FORECAST_DEADLINE_PASSED` | 409 | no | Preserve local draft as late/unsubmitted. |
| `FORECAST_EXISTS` | 409 | no | Reconcile to returned/current forecast when authorized. |
| `CONFLICT_VERSION` | 409 | no | Fetch latest; offer explicit retry/review. |
| `IDEMPOTENCY_KEY_REUSED` | 409 | no | Create a new intentional operation/key. |
| `INVITE_INVALID` | 404 | no | Generic invalid/expired/revoked response; do not disclose group. |
| `MEMBERSHIP_INACTIVE` | 403 | no | Stop queued mutation and explain access changed. |
| `BLOCK_RESTRICTED` | 403 | no | Apply policy-safe restriction; reveal no counterpart data. |
| `POLICY_NOT_CONFIGURED` | 409 | no | Feature gated pending approval; no partial final action. |
| `RATE_LIMITED` | 429 | yes | Retry after supplied interval; do not spin. |
| `TEMPORARY_UNAVAILABLE` | 503 | yes | Keep draft/queue and exponential backoff. |
| `INTERNAL_ERROR` | 500 | maybe | Show non-content error + request ID; retry only if operation is idempotent. |

Every error body has `code`, safe `message`, `request_id`, `retryable`, optional `retry_after_seconds`, and safe `field_errors`. Never return SQL/provider details, auth material, invite token, private text, or hidden membership.

## 6. Realtime, audit, and reconciliation

After a committed mutation, server emits a minimal authorized envelope: `event_id`, `topic`, `resource_type`, `resource_id`, `resource_version`, `occurred_at_utc`, `sequence`, `schema_version`. Topics are authorization-scoped (`group:{opaque_id}` / `user:{opaque_id}`), never public raw IDs if a transport exposes them. The message must not contain prompt, evidence text, forecast choice, token, avatar, or group name unless a separately approved endpoint fetch is authorized.

Client reconciliation algorithm: persist last per-topic sequence; on reconnect, authorization change, sequence gap, or a mutation response with newer version, call a versioned list/detail endpoint from last durable cursor; apply only newer versions; treat tombstones as removal from local visible cache; retain the local unsent draft separately. Realtime delivery loss/duplication/out-of-order messages must be harmless.

Minimum audit actions: account/session lifecycle category, profile change, group create/update/archive, membership/invite create/redeem/revoke/leave/remove, event transitions, forecast lock/rejection, resolution/evidence/appeal/void/correction, score calculation version, receipt generate/revoke, notification preference, report/block/moderation, delete/export request, privileged read. Audit has actor ID/category, target IDs/types, action, before/after version hashes or safe metadata, server time, request/correlation ID, outcome, and policy reason—not secret or UGC payloads.

## 7. Contract-test negative fixtures

Fixtures are synthetic only; no real names, prompt text, tokens, credentials, or production identifiers.

1. outsider reads private group/event → `NOT_FOUND`/`FORBIDDEN`, no existence leak.
2. removed member submits queued forecast → `MEMBERSHIP_INACTIVE`, no forecast/audit lock created.
3. two simultaneous same-author submissions before deadline → exactly one `locked` record/audit; retries resolve deterministically.
4. server time at/after deadline → `FORECAST_DEADLINE_PASSED`, regardless of client clock.
5. same idempotency key with changed confidence → `IDEMPOTENCY_KEY_REUSED`.
6. stale ETag changes event draft → `CONFLICT_VERSION`, original draft remains.
7. attempt to edit outcome/rule after open → `EVENT_NOT_OPEN` or `VALIDATION_FAILED`; version unchanged.
8. blind member requests peer forecasts/aggregate before own lock → redacted/forbidden; own forecast remains readable.
9. revoked/expired/exhausted invite redemption → generic `INVITE_INVALID`, no group disclosure.
10. inviter/admin removes the final owner/admin contrary to owner-continuity policy → `POLICY_NOT_CONFIGURED` until explicit policy; no partial mutation.
11. resolver resolves without evidence or finalization policy → `VALIDATION_FAILED`/`POLICY_NOT_CONFIGURED`; no scores.
12. correction attempts to overwrite existing resolution/score → append-only new records or reject; original audit survives.
13. client sends direct score mutation/vendor-table endpoint → route absent/`NOT_FOUND`.
14. realtime duplicate/out-of-order/gap → cache converges by API version/cursor; no false lock/reveal.
15. tombstoned group/event appears in cursor continuation → no content leak; cursor remains valid or returns documented `NOT_FOUND`.
16. cross-environment credential/resource request → `UNAUTHENTICATED`/`NOT_FOUND`, no data crossing.

## 8. Open gates

This contract deliberately leaves unresolved: scoring formula, ties/sample thresholds, private-group size/member event policy, owner continuity, resolver finalization/evidence/appeal rules, age/region/prohibited content, retention/legal holds, profile discoverability, rate-limit numbers, notification retention, backend identity protocol, and generated client. Each must be decided in its named F0.1/F0.3/F0.5/F0.7 gate before the corresponding endpoint is enabled for participants.
