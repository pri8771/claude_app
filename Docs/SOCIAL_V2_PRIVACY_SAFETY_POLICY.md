# Hindsight Social v2 — Draft Privacy, Safety, and Trust Policy

**Status:** draft policy specification; requires product-owner, privacy, safety, and qualified legal review before any external social release. This is not legal advice, a public privacy policy, Terms, community guidelines, or an approval record.

**Scope:** the networked Social v2 product only. It does not alter the Build 1 local-only privacy policy. It is a product/API/moderation contract for F0.5 and must agree with the product contract, ADR-008, and the Social v2 feature contract.

## 1. Policy intent and non-negotiable defaults

Hindsight lets people record probability forecasts and learn from outcomes. Social participation must not turn a private journal into a discoverable profile by accident. New social objects are server-authoritative; unsynced drafts and legacy local journal records remain device-authoritative until explicit, separate consent.

- **Default visibility:** new legacy records are `private_local`; new social events are `private_group` only after the creator chooses an existing or newly created group. There is no default public posting.
- **No silent conversion:** installing, signing in, joining a group, enabling backup, or accepting an invite does not upload an existing journal record. Conversion/sync requires an item- or clearly scoped bulk-level consent screen and a confirmation.
- **No public network in Phase 1:** public discovery, public profiles, arbitrary public events, searchable handles, city discovery, and global boards remain disabled until their separate Phase 3 gates pass.
- **Server truth:** only server confirmation can show a social forecast as locked, a result as resolved, or a score as changed. Offline work is labelled draft/queued/failed, not locked.
- **Least data and access:** collect fields needed for the requested capability; support, moderation, analytics, and engineering access use role-based, case-bound, audited views.

## 2. Data inventory, visibility, retention, and control matrix

Retention periods below are proposed operational targets, not approved legal retention periods. Counsel must set jurisdiction-specific schedules before external release. “Delete” means user-facing removal plus a documented lifecycle for backups, fraud/security records, and legally required preservation.

| Data category / fields | Authority and purpose | Default visibility and disclosure | Proposed retention / deletion | Access and controls |
|---|---|---|---|---|
| **Legacy local journal:** decision text, options, notes, predictions, reviews, local reminders | Device; preserve existing private use | `private_local`; never readable by server or group by default | On device until user deletes app data/record; app deletion behavior explained in product | Device sandbox; export/delete controls; network-capture test proves no pre-consent upload |
| **Social account:** immutable account ID, auth provider subject/credential reference, session/security metadata | Server; authenticate and secure account | Never visible to members; user sees account method only | Account lifetime; session/security logs per approved schedule; remove/anonymize on deletion where allowed | Auth service only; no raw credential/token logs; encryption, rotation, replay protection |
| **Profile:** display handle, optional avatar, optional short bio after policy approval | Server; identify members in allowed social contexts | Phase 1: group members only; handle is not globally searchable | Until user changes/deletes account; removed avatar/media purged on approved schedule | Separate legal identity from handle; uniqueness/reservation; report/impersonation workflow; media scanning before display |
| **Optional contact data:** email/phone if an approved auth/recovery path needs it | Server; authentication/recovery only | Never shown to groups or analytics | Until deletion or verified change; minimal security hold where required | Do not import address books; no contact matching; redact from support exports and telemetry |
| **Group:** group name, optional image, settings, membership roles | Server; private shared space | Members only; no search/indexing; invite preview exposes only owner-selected minimal label | While active; delete/tombstone per group/account lifecycle | Per-request membership checks; membership changes audited; group name omitted from telemetry/share payloads |
| **Invites:** opaque token/hash, issuer, group ID, role, expiry, revocation and redemption state | Server; join a private group | Token itself never displayed after creation or logged; landing page exposes only approved preview | Expire/revoke promptly; retain hashed/audit event per approved schedule | Store token hash, one-time or bounded redemption, rate limits; `noindex`; revoke and rotate |
| **Prediction event:** prompt, outcome options, deadline, resolution rule, evidence policy, visibility | Server for social events | Eligible group members; blind-vote state hides other choices/aggregates before own lock | Active lifecycle plus export/delete/ledger policy | Authorization on every read; user-generated prompt never enters telemetry; no public indexing |
| **Forecast:** selected outcome, confidence, author opaque ID, server lock time, revision/ledger reference | Server; credible immutable record and scoring | Author sees own forecast; group visibility follows event stage; hidden before participant lock when blind | Ledger retained through event/account lifecycle; account deletion applies de-identification/tombstone policy, not silent record rewrite | Atomic UTC lock/idempotency; no client timestamp authority; audit all lock/revision/correction attempts |
| **Resolution/evidence/appeal:** outcome, source URL/reference, evidence text/media, resolver, dispute and void history | Server; fair result explanation | Eligible members; least-access moderation/support as case needs | Retain resolution ledger and appeal outcome per approved schedule; evidence may have shorter media retention | Resolver role; append-only correction/void history; evidence URL/text not in telemetry or push payloads |
| **Scores/leaderboards:** score version, aggregate, eligibility/sample metadata | Server; learning comparison | Phase 1 private group only; public ranks are out of scope | While related account/group/event persists; recomputable ledger retained per approved schedule | Proper-scoring version; denominator/sample gate; private results never exported to verified public rank |
| **Block/report/moderation:** reporter, subject, category, narrative, attachments, decision, timestamps | Server; safety enforcement and appeals | Reporter/subject do not see each other’s report narrative; limited case view | Proposed: retain reports and decisions 24 months, attachments 180 days unless escalated/legal hold; counsel approval required | Case ID, need-to-know access, immutable access/action audit, redacted analytics, appeal linkage |
| **Coarse location:** country/region or city bucket only after explicit opt-in and approved feature gate | Server/client; optional local/community relevance | Off by default; never precise coordinates, live location, or location history | Until feature use ends/consent withdrawal; delete derived bucket promptly | No background location; explain audience before use; city membership must not reveal a participant’s presence |
| **Notifications:** permission state, generic event type, device push token | Server/device; alerts requested by user | Content minimized; lock-screen copy must not expose private prompt/group by default | Token until invalid/opt-out; delivery logs on approved short schedule | APNs credentials server-side; no event text/token in payload; preference center and opt-out |
| **Share Receipt:** rendered template metadata, redaction choice, share-surface completion signal | Device; user-initiated sharing | Explicit OS share only; user previews outbound card | No server copy of rendered payload by default; aggregate event metric only if consent/approval allows | Strip invite token, group name, prompt, notes, member identity, exact time/location; warn external sharing is outside Hindsight controls |
| **Telemetry/diagnostics:** opaque IDs, app/build/version, route, coarse state/error codes, latency buckets | Client/server; reliability and aggregate product learning | Not visible to other users | Proposed: raw operational logs 30 days; aggregate metrics per approved schedule | Never include prompt, outcome label, notes, group/handle/avatar, invite/auth token, evidence URL/text, email/phone, IP, ad ID, fingerprint, exact time/location; redact before sink; deletion propagation verified |
| **Security/audit records:** actor ID, action type, case/correlation ID, timestamp, redacted target reference | Server; investigate misuse/integrity incidents | Internal least-privilege only | Proposed 24 months; legal-hold exception requires process | Append-only, encrypted, access-audited; no content payloads or credentials |

## 3. Visibility classes, conversion warnings, and consent

| Class | Meaning | Who may read | Conversion / user-facing warning |
|---|---|---|---|
| `private_local` | Existing or new device-only journal content | Device user only | “Stays on this device. Signing in does not upload it.” |
| `private_synced` | Future approved private backup/sync capability | Account holder only | Separate opt-in: “Encrypted account-backed copy; not visible to groups.” Not part of Phase 1 until contract/implementation approval. |
| `private_group` | Forecast/event shared with named current members | Authorized active members, limited resolver/moderator case access | “Members of **[group]** can see this after the event’s visibility rules allow it. Others cannot.” |
| `unlisted_link` | Deferred; opaque-link access rather than discovery | Only validated recipients under final authorization policy | “Anyone with this link may be able to open it. Do not include private information.” Disabled until separate approval. |
| `public` | Deferred; discoverable public content | Public audience under final moderation/ranking rules | “Public forecasts can be copied or discussed outside Hindsight.” Disabled through Phase 1/2. |

**Required conversion mechanics:** show source (`private_local`), destination, audience, fields that will be copied, fields that stay local, immutability after lock, deletion implications, and a cancel action. Confirmation must be explicit; a prechecked toggle, vague “continue,” or bundled consent is prohibited. Changes to broader visibility require a second confirmation and server authorization. Narrowing visibility does not erase information a previously authorized viewer already saw; explain this before confirmation.

## 4. Identity, handle, location, age, and consent policy

### Identity and handles

- Account authentication identity is separate from a group-visible handle. Do not expose legal name, email, Apple account subject, device identifier, or recovery method to groups.
- Phase 1 handles are unique within the service namespace but not globally searchable. Limit length/character set; reserve system/abusive/confusing names; normalize safely; prevent look-alike/impersonation patterns where feasible.
- Profile bio and avatar are optional and should remain disabled until media handling, reporting, scanning, and moderation capacity are accepted. If enabled later, they inherit report/block and audit controls.
- Impersonation reports are a priority safety category. Freeze/review a contested handle where warranted, preserve evidence, notify affected parties only with minimum necessary detail, and provide an appeal path.

### Location

- No precise, background, or live location collection. No location is required to use groups, forecasts, scores, or Receipts.
- Any future local feature requests explicit opt-in at the time of use, explains the coarse bucket and audience, offers “not now,” and supports withdrawal. Do not infer a city from IP or share membership/presence.

### Age and minors — owner-required decision

**Unresolved owner decision before external testing/public availability:** define the minimum age, supported jurisdictions, age-gate method, parental-consent treatment where applicable, and whether the product is adults-only. Until product owner and qualified counsel approve this, do not knowingly onboard minors, market to minors, enable public content, or claim compliance with child/privacy rules. The App Store age rating must be selected only after the approved content, UGC, and age policy exists.

### Consent

- Required, separate consent moments: account creation/Terms acknowledgment; social forecast audience/lock; legacy-data conversion; optional notifications; optional coarse location; optional analytics where law/policy requires it; and any future public sharing.
- Consent records contain policy/version ID, timestamp, actor opaque ID, surface, locale, and outcome—not the surrounding private content. Withdrawal stops the optional processing prospectively and triggers the documented deletion/preference workflow.
- Avoid coercion: core private/local usage remains available without social sharing, contacts, location, marketing permission, or public profile.

## 5. Safety, block, report, and content policy

### Block semantics

A block is a server-authoritative bilateral safety boundary. On confirmation, the blocked relationship is removed or suppressed, new direct discovery/invites/shared newly created spaces are prevented, and the blocker does not receive notifications or reveal activity from the blocked person. Existing shared-group behavior needs a final, explicit policy before Phase 1: minimum safe default is that block prevents new invitations/contact and flags co-membership to the safety workflow; it must not silently expose either party’s activity. A block does not erase immutable event ledger history; it restricts future access per membership/retention rules. Users can unblock from privacy settings; unblocking does not automatically restore friendship or group membership.

### Reporting

Every group-visible user-generated field and member interaction exposes a report route. Categories: harassment/hate, threats or self-harm concern, sexual content/exploitation, impersonation, spam/scam, doxxing/privacy, illegal/regulated-market content, cheating/manipulation, misleading resolution/evidence, and other. The report form explains what is sent, supports an optional narrative/attachment only if approved secure handling exists, offers “block this person,” and shows a receipt/case ID. Do not promise a particular outcome or disclose reporter identity.

### Content boundaries

Allowed Phase 1 content is ordinary, non-professional, lawful private-group forecasting with an objective or group-agreed resolution rule. Prohibit:

- threats, harassment, hate, sexual exploitation, doxxing, non-consensual intimate material, impersonation, scams/spam, or content targeting a protected person/group;
- real-money wagering, prizes that create gambling or regulated-contest risk, odds/betting language, market manipulation, or instructions to evade applicable law;
- personalized financial, medical, legal, mental-health, safety, employment, insurance, credit, immigration, criminal-justice, or emergency predictions presented as advice or used to make decisions about a person;
- predictions about death, self-harm, violence, criminal acts, disaster victims, private health, pregnancy, sexuality, minors, or other highly sensitive personal facts without a separately approved policy; and
- content that violates law, intellectual-property/privacy rights, or the platform’s future approved Terms/community guidelines.

High-risk markets are prohibited until qualified review explicitly authorizes a bounded use: financial instruments/crypto/markets, gambling/sports betting, health/medical outcomes, elections/politics where applicable, emergency/crisis events, and decisions about protected or vulnerable individuals. The product must not label forecasts as expertise or professional advice.

### Moderation operations

| Role | Permitted action | Access limit | Audit / target SLA (draft) |
|---|---|---|---|
| Reporter/blocker | Submit report, block, appeal report closure where allowed | Own submission/receipt; not subject’s private data | Receipt immediately; status updates without sensitive details |
| Triage moderator | Categorize, prioritize, apply reversible precaution, request escalation | Case-scoped metadata/content only | Urgent credible safety threat: acknowledge/triage within 4 hours; standard reports within 72 hours |
| Senior safety reviewer | Remove content, suspend/restrict account, uphold/modify action, decide appeal | Case plus necessary related audit history | Appeal initial response within 14 days; final target depends on severity/jurisdiction |
| Support operator | Account/deletion/support assistance | No moderation narrative/content unless escalated | Audit every case access/action |
| Engineer/admin | Break-glass incident support only | Time-bound approval, minimal data, no routine browsing | Ticket + reason + approver + immutable access record; post-incident review |

Moderation actions use reason codes, policy version, actor/case IDs, timestamp, scope, expiry/review date, and appeal status. Enforcement options are warning, content/event removal, visibility restriction, invite/rate restriction, temporary suspension, permanent removal, and referral/escalation under an approved incident process. Staff may not silently alter locked forecasts, scores, or resolutions; corrections remain ledgered.

### Appeals and fairness

Users receive a concise notice of material enforcement unless doing so would create a safety, fraud, or legal risk. Notices state affected capability/content, high-level reason category, duration/review path, and appeal route. Appeals are reviewed by a different qualified reviewer when practical; outcome, policy version, evidence considered, and rationale are logged. Repeated abusive appeals may be limited with an auditable reason. Resolution disputes follow the event’s dedicated evidence/void/correction path and are not silently decided through account moderation.

## 6. Account lifecycle, export, deletion, incidents, and legal requests

### Account lifecycle

1. **Create:** authenticate, choose a safe handle, acknowledge approved Terms/policy version, receive default private settings.
2. **Active:** user manages profile, groups, blocks, notification/consent preferences, export and deletion. Authentication/session changes require re-authentication where risk warrants.
3. **Deactivate/delete request:** in-app route and web/support route must be discoverable without contacting a group admin. Explain immediate effects, pending forecasts/groups, immutable/audit limitations, recovery window if offered, and final date.
4. **Deletion execution:** revoke sessions/tokens, remove/disassociate profile and active access, delete or anonymize eligible personal data, process media/telemetry/vendor deletion queues, preserve only narrowly documented security/legal/audit data, and issue completion confirmation. Do not make account deletion delete other members’ history without an approved consistent ledger/tombstone rule.
5. **Post-deletion:** retain a non-reusable tombstone or anti-fraud marker only if necessary, proportional, documented, and counsel-approved; prevent restoration after the promised irreversible date unless the policy says otherwise.

### Export and deletion requirements

Provide a machine-readable export of the requestor’s permitted profile, memberships, own forecasts, consent/preferences, and account lifecycle history. Exclude other members’ private data, security-sensitive records, and data restricted by law; explain exclusions. Authenticate requests, rate-limit them, encrypt delivery, time-limit the download, log fulfillment, and test the workflow with synthetic fixtures. Define a target completion window only after legal/operational review; do not promise statutory timelines without confirmation.

### Incident handling

Maintain an incident playbook: detect → contain/disable affected feature → preserve minimum audit evidence → assess data/safety impact → notify designated owners/counsel → remediate → determine required user/regulator/vendor notice → document root cause and prevention. Never send incident notifications until facts, scope, and counsel/owner approval are established. Kill switches must disable public sharing, invites, notifications, realtime delivery, and/or social read/write independently without corrupting local records or falsely confirming locks.

### Legal and government requests

Route all requests to designated legal/privacy owners. Verify authority, jurisdiction, scope, and authenticity; preserve only what a valid hold requires; disclose the minimum permitted data; maintain a request log; challenge/seek narrowing when appropriate; notify the affected user only when legally permitted and safe. Moderators and engineers must not respond directly or use ad-hoc exports. This workflow needs counsel approval before launch.

## 7. Notification, sharing, and telemetry rules

- **Notification defaults:** off until the OS/user grants permission. Generic copy by default: “A Hindsight update is ready.” Never show private prompt, group name, member handle, chosen outcome, invite token, score, evidence, or sensitive result on a lock screen. Deep links require authentication and authorization.
- **Share defaults:** no automatic sharing; preview first; system share sheet only after user action. Receipt payload excludes private text, notes, private group identity, members, invite data, exact timestamp/location, auth/session data, and unapproved public rank. Explain that recipients may re-share a Receipt once it leaves the app.
- **Telemetry:** use the restricted event dictionary in the product contract. Server/client redaction tests are release gates. Sampling, retention, access, and deletion propagation need written approval before production analytics. Diagnostics may use correlation IDs and coarse error/latency buckets, never content or direct identifiers.

## 8. User-facing copy baseline (draft)

| Moment | Draft copy | Required behavior |
|---|---|---|
| Local journal | “Private on this device. Signing in will not upload your existing entries.” | Link to details; no implied sync |
| Group forecast audience | “Only current members of **[group]** can see this forecast when the event reveals.” | Name audience, deadline, blind/open rule before submit |
| Lock confirmation | “Locked at **[server time]**. You can’t edit this forecast now.” | Show only after server acknowledgement |
| Offline submit | “Saved as a draft. It isn’t locked until Hindsight confirms it.” | Retry/cancel/recovery route |
| Conversion warning | “You’re sharing a copy with **[group]**. Your original private entry stays on this device.” | List copied fields; explicit confirm/cancel |
| Location | “Optional: use a broad area, never your precise location. You can change this anytime.” | Off by default |
| Block | “Block **[handle]**? They won’t be able to invite or contact you through Hindsight. This won’t erase past event records.” | Confirm; offer report |
| Report | “Reports are reviewed privately. We don’t share your report details with the person you report.” | Receipt/case ID; safety route |
| Share Receipt | “Check what you share. This card leaves out private group details and invite links.” | Preview/redaction controls |
| Deletion | “Deleting your account removes access and eligible personal data. Some ledger and safety records may remain only as explained in our policy.” | Explain timeline/recovery/exceptions before confirmation |

## 9. Abuse threat cases and required mitigations

| Threat case | Harm | Required control / verification |
|---|---|---|
| User submits forecast just after deadline by changing device clock/retrying | Credibility and score fraud | Server UTC transaction, idempotency, duplicate/late/replay negative tests; no client-success state |
| Invite token is forwarded, guessed, indexed, or logged | Private-group intrusion | Opaque hashed token, expiry/revoke, rate limits, `noindex`, token redaction in logs/screenshots/share, authorization after redemption |
| Harasser repeatedly creates accounts/invites/joins shared contexts | Harassment and evasion | Server block boundary, rate/invite limits, abuse signals, device/account safeguards subject to review, moderation escalation; do not rely on UI hiding |
| Impersonator uses a look-alike handle/avatar | Deception/trust loss | Handle normalization/reservations, report category, review/freeze/remediation, audit and appeal |
| Group admin abuses role or resolver manipulates outcome | Coercion/unfair scores | Immutable forecasts, resolver evidence, membership/action audit, appeal/void/correction ledger, least privilege |
| Forecast prompt reveals health, location, employer, or a private person | Sensitive inference/doxxing | Prohibited content policy, report route, no public indexing, moderator removal, no content telemetry/push/share |
| Receipt or notification leaks private group/prediction details | External disclosure | Redacted templates and generic push copy; automated payload/render tests; explicit share preview |
| Insider/support browses private content without cause | Privacy breach | Case-bound RBAC, break-glass approval, immutable access audit, periodic review, redact exports |
| Analytics vendor/log captures prompt/token/email | Irreversible disclosure | Allowlist schema, client/server scrubbers, CI payload tests, no production vendor before approval, access/retention controls |
| Deletion request leaves active sessions or third-party copies | Ongoing exposure | Central deletion workflow, token revocation, vendor queue/receipt, export/delete integration tests and reconciliation |
| Public prediction market evolves into betting/advice | Regulatory and user harm | Phase 1 private scope, prohibited high-risk markets, no prizes/odds, content/moderation gates, counsel review before expansion |

## 10. Approval and release gates

Before an external social tester receives access, the product owner, safety/privacy owner, engineering owner, and qualified legal reviewer must approve: this policy’s final retention/age/Terms decisions; data-flow/threat-model review; visibility/consent copy; deletion/export support process; moderator staffing and escalation contacts; App Store disclosure mapping; and telemetry/push redaction evidence. Until then, Social v2 remains `verification_pending`/planned and any prototype or backend spike uses synthetic data only.
