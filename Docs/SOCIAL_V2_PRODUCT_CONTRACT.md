# Hindsight Social v2 — Product Contract

**Status:** draft for product-owner approval and prototype validation; not implementation approval

**Owner:** Product owner (approval); Product/Design lead (research); Engineering lead (event
implementation review); Safety lead (guardrails review)

**Applies to:** F0.1 and the Phase 1 private-group MVP. This contract narrows, but does not
replace, [the Social v2 master plan](SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md), DEC-005 through
DEC-007, or the Social v2 foundation feature contract.

## 1. Executive summary

Hindsight helps people make a time-stamped probability call, then learn from the outcome. The
first networked release makes that loop useful with people a user already knows: a private group
creates or shares a prediction, every member makes an independent call before the lock, and the
group returns to reveal the outcome and compare calibration.

The product is **not** a social feed, a general chat product, gambling, or a public-opinion
market. Its value is the credible record: private by default, server-confirmed timestamps for
social forecasts, hidden group consensus before an individual commits, an understandable outcome,
and sample-aware insight rather than confidence theatre. Legacy journal content stays local unless
the owner explicitly opts into a separate sharing or sync action.

The Phase 1 launch hypothesis is deliberately narrow: small, pre-existing groups will complete a
shared forecast loop and return for its result often enough to justify deeper social distribution.

## 2. People, jobs, and permissions

### 2.1 Primary and secondary users

| Segment | Job to be done | First success | Product obligation |
|---|---|---|---|
| **Primary: private-group forecaster** | “When my friends and I make calls about something uncertain, help us record independent probabilities and discover who was calibrated after it resolves.” | Join a trusted group, submit a forecast, and see a server-confirmed lock. | Make capture fast, explain visibility before submission, and protect independent judgment. |
| **Secondary: group organizer** | “When our group wants a recurring prediction game, help me create a safe shared space without becoming a moderator or project manager.” | Create a group and issue a revocable invite. | Provide clear membership, invite, role, and deletion controls. |
| **Secondary: invitee** | “When a friend sends a prediction, let me understand it and make my own call with little setup.” | Open an invite and reach the submission path without losing context. | Preserve opaque invite context, show group and prompt visibility, and never expose the invite token. |
| **Secondary: result-seeking forecaster** | “After an outcome is known, show me a fair, legible explanation of what happened.” | See the result, their scored forecast, and a sample-aware group comparison. | State the source, resolution status, score version, denominator, and uncertainty. |

### 2.2 Actor, permission, and job matrix

| Actor | Primary job | Can do | Cannot do | Sensitive data and required controls |
|---|---|---|---|---|
| Anonymous visitor | Understand an invitation and decide whether to join. | View a deliberately limited invite landing screen and begin authentication. | View forecasts, member lists, group history, or invite metadata beyond what the inviter chose to preview. | No account inference; no prediction text or private group name in telemetry. |
| Account holder / solo forecaster | Preserve private thinking and optionally participate socially. | Create local drafts; create or join groups; submit one eligible forecast; view their own history. | Cause an existing private journal item to upload implicitly; rewrite a locked social forecast. | Separate local journal from social records; explicit visibility and migration consent. |
| Group member | Make an independent group call and learn with the group. | View open group events allowed by membership; submit before deadline; view reveal after resolution; leave or block. | View others’ forecasts or aggregates before their own submission when blind voting applies; resolve or change membership. | Membership authorization on every read/write; block behavior takes precedence over discovery. |
| Group admin | Run a trusted small group. | Create/revoke invites; remove members; configure permitted group settings; start drafts if granted by the final event policy. | Read blocked users’ private records; alter a locked forecast; silently convert visibility; override resolution rules. | Audited membership and invite changes; clear handoff/owner-loss policy required before implementation. |
| Resolver | Apply a predeclared outcome rule. | Submit evidence and a proposed resolution through the approved workflow. | Alter forecasts or scores directly; resolve without evidence; bypass appeal/void process. | Resolver actions are audited; source/evidence and state must be visible to eligible members. |
| Moderator / support operator | Handle credible safety and integrity reports. | Review reports, enforce defined actions, record an auditable rationale, and process appeals. | Browse private content without a report-supported, least-privilege case; change scores silently. | Role separation, access log, retention policy, and escalation SLA are prerequisites for public launch. |

## 3. First-session promise and normative core loop

### First-session promise

“Make a real call in seconds. Hindsight locks the time and probability, then shows what the group
learned when the outcome is known.”

The first social session must make three facts legible before a user submits: (1) who can see this
forecast, (2) the deadline and that the server—not the phone—confirms a lock, and (3) whether
other members’ choices remain hidden until the user participates. No social success state may be
shown until the server returns confirmation.

### Normative Phase 1 loop

1. A signed-in user creates or opens a private-group event with a clear binary or explicitly
   enumerated outcome, a future deadline, a declared audience, and a resolution rule.
2. An eligible member opens it from the group or a validated invite. Before their submission,
   blind-vote events hide individual forecasts and group aggregates.
3. The member selects an outcome and confidence, reviews the audience/deadline/lock explanation,
   and submits once. The client displays `Submitting` or `Queued` while offline; only a server
   acknowledgement changes the state to `Locked`.
4. At the deadline, the event locks. A resolver supplies outcome evidence through the approved
   rule. Members see `Resolving`, not a premature result.
5. After authoritative resolution, eligible members see the result, their forecast, a documented
   score calculation, and a group comparison whose denominator and sample qualification are shown.
6. A member may share a deliberately redacted Receipt only through explicit user action; no share
   contains invite credentials, private-group names, forecast text, private notes, or precise
   location by default.

### Loop invariants

- A social forecast has one server-issued lock timestamp and cannot be rewritten after lock.
- A failed, late, duplicate, unauthorized, stale, or cross-account submission must remain visibly
  unconfirmed and recoverable where retry is safe.
- Any shown score names its scoring-rule version, eligible forecast count, and whether it is a
  private-group comparison rather than a public verified rank.
- Resolution correction, voiding, and appeal behavior is explicit; a correction appends ledger
  history rather than erasing the original decision.

## 4. Phase 1 scope and non-goals

### In scope

- Account creation/sign-in subject to the F0.3 architecture decision, a profile with safe default
  identity, private groups, member roles, revocable invites, and leave/remove flows.
- A rapid social composer for group predictions: prompt, permitted outcomes, deadline, visibility,
  and independent outcome/confidence submission. The capture target is at most four deliberate
  actions after text entry.
- Server-authoritative membership, UTC lock timestamps, immutable forecast ledger, queue/retry
  state, objective resolution record, evidence, and a limited appeal/void path.
- Private group result view, proper-score-based group leaderboard with eligibility/sample gates,
  a personal calibration explanation, and explicit shareable Receipt primitives.
- Reporting, blocking, basic rate limits, audit records, privacy/consent, user-data deletion
  workflow design, accessible states, and isolated development/QA environments.

### Explicit non-goals

- Public global, city, or category leaderboards; public discovery; arbitrary public events; creator
  programs; team leagues; seasons; tournaments; and follower graphs.
- Direct messages, comments, a general feed, reposting, live chat, contact scraping, or automatic
  friend import.
- Real-money forecasts, prizes, betting language, financial or health prediction use cases, and
  any feature that encourages users to treat group consensus as professional advice.
- Precise location, background location, raw contact uploads, public indexing of group content, or
  silent migration/upload of existing journal data.
- A production backend SDK, backend vendor commitment, or external analytics SDK before F0.3 and
  DEC-007 are approved.

## 5. Measurable launch hypothesis

### Hypothesis

For invite-based private groups of 3–12 adults who already communicate together, the combination
of quick independent capture, credible lock confirmation, and a reveal will produce a meaningful
repeat loop: eligible activated users will return for a result and a material subset will create or
join a second resolved group event without product-team intervention.

### North-star metric

**Qualified Group Learning Loops (QGLL), measured weekly**

- **Numerator:** count of distinct `(group_id, prediction_event_id)` pairs that, in the same event
  lifecycle, have: (a) at least 3 distinct eligible members, (b) at least 2 server-confirmed
  forecasts submitted before deadline, (c) an authoritative resolution with evidence or a
  documented void, and (d) at least 2 distinct forecasting members open the result within 14 days
  after resolution. A voided event does not qualify.
- **Denominator:** none; QGLL is a weekly count. Report companion *QGLL per active private group*
  as `QGLL / distinct private groups with >= 2 eligible members active in the same seven-day
  window`.
- **Eligibility window:** events created in the prior 28 days, with a server deadline and no
  moderation removal. Count each event once, in the week the second forecast-member views the
  result.
- **Owner:** Product owner; Data/Analytics owner validates the query; Backend owner validates
  server-event integrity.
- **Privacy rule:** calculate on opaque IDs. Do not export prediction text, group name, invite
  token, private note, precise location, IP address, or profile free text into product analytics.

## 6. Measurement contract

### 6.1 Common analytics rules

- Emit only from a defined client/server boundary after the described state is true. The server is
  source of truth for lock, resolution, membership, score, report enforcement, and notification
  delivery outcome.
- Every event includes `event_name`, `event_version`, `occurred_at_utc`, `surface`,
  `app_build`, `platform`, `environment`, opaque `actor_id` when authenticated, opaque
  `group_id`/`prediction_event_id` only when needed, and a random correlation ID. IDs must be
  pseudonymous and access-controlled.
- Prohibited properties: prompt or prediction text, notes, outcome labels when user-generated,
  group name, display name, avatar URL, email, phone, contacts, invite token, auth credential,
  source URL contents, exact location, IP address, ad identifier, or device fingerprint.
- Analytics retention, access roles, deletion propagation, and consent copy require F0.5 approval.
  Until then, use development fixtures only; do not send production participant data to a vendor.

### 6.2 Event dictionary

| Event name | Authoritative emitter and trigger | Allowed properties beyond common envelope | Never include |
|---|---|---|---|
| `onboarding_completed_v1` | Client after required onboarding confirmation is persisted. | `entry_path`, `has_existing_local_journal` | Free-form answers or journal counts by title. |
| `auth_completed_v1` | Server after identity/session validation succeeds. | `auth_method`, `is_new_account` | Apple subject, email, credential, failure detail. |
| `group_created_v1` | Server after group record commits. | `group_size_bucket`, `visibility_class=private` | Group name, image, creator display name. |
| `group_invite_opened_v1` | Client after a validated opaque invite route opens. | `invite_channel`, `install_state`, `invite_age_bucket` | Token, recipient identity, referrer message. |
| `group_joined_v1` | Server after membership commits. | `join_path`, `group_size_bucket` | Invite token or member list. |
| `prediction_event_opened_v1` | Client after a member opens an authorized event. | `entry_path`, `event_type`, `deadline_bucket`, `blind_vote` | Prompt, outcomes, group name. |
| `forecast_submit_requested_v1` | Client when the user explicitly presses submit. | `event_type`, `confidence_bucket`, `deadline_remaining_bucket`, `network_state` | Chosen outcome label, prompt, typed content. |
| `forecast_locked_v1` | Server only after immutable lock transaction commits. | `event_type`, `confidence_bucket`, `deadline_remaining_bucket`, `submission_path` | Chosen outcome label, exact timestamp, forecast body. |
| `forecast_lock_rejected_v1` | Server after safe rejection. | `reason_code`, `retryable`, `event_type` | Request payload, server internals, account identity. |
| `resolution_recorded_v1` | Server after authorized resolution commits. | `resolution_type`, `evidence_class`, `time_to_resolution_bucket` | Evidence text/URL, outcome label if user-generated. |
| `result_viewed_v1` | Client after eligible result screen is visible for 2 seconds. | `view_scope`, `scoring_version`, `forecast_count_bucket`, `days_after_resolution_bucket` | Individual/member scores or names. |
| `receipt_share_requested_v1` | Client when system share sheet opens. | `receipt_template`, `redaction_level`, `share_surface` | Shared image payload, recipient, group/event name. |
| `receipt_share_completed_v1` | Client only if the OS completion callback reports completion. | `receipt_template`, `share_surface` | Recipient or copied content. |
| `report_submitted_v1` | Server after report storage commits. | `subject_type`, `report_category` | Report narrative, reporter/subject identity, attachments. |
| `block_applied_v1` | Server after block commits. | `subject_type`, `entry_path` | Blocked identity or rationale. |
| `notification_permission_changed_v1` | Client after system permission state is observed. | `new_status`, `entry_path` | Notification content. |
| `notification_opened_v1` | Client after a user opens a generic notification route. | `notification_type`, `route_type` | Notification body, prompt, group/event name. |

### 6.3 Funnel and guardrails

All rates are calculated separately for new accounts and existing local-only accounts. Exclude
internal test accounts, deleted accounts, and events generated by fixtures before calculation.

| Metric | Exact calculation | Eligibility window | Owner | Guardrail / interpretation |
|---|---|---|---|---|
| Invite open rate | `distinct invitees with group_invite_opened_v1 / distinct delivered opaque invites` | 14 days after invite issue | Growth | Diagnostic only; invite delivery must be measured without recording recipients’ contact data. |
| Account completion | `distinct users with auth_completed_v1 / distinct users with group_invite_opened_v1` | Same session or 24 hours | Product | Low rate indicates trust/onboarding friction, not a reason to request more personal data. |
| First forecast activation | `distinct authenticated users with first forecast_locked_v1 / distinct authenticated users eligible to open an event` | 7 days after eligibility | Product | Primary early activation signal; only server locks count. |
| Reveal return | `distinct forecasters with result_viewed_v1 / distinct forecasters on resolved eligible events` | 14 days after resolution | Product | Core evidence for the learning loop. |
| Week-4 social retention | `distinct activated users active in days 22–28 / distinct activated users` | Cohort measured 28 days after first lock | Product | “Active” requires authorized group/event open, lock, or result view; app foreground alone does not count. |
| Repeat resolved participation | `distinct activated users with a lock or result view on a second resolved event / distinct activated users` | 28 days after first lock | Product | Distinguishes a novelty action from recurring value. |
| Resolution reliability | `resolved eligible events with evidence and no correction/void within 14 days / resolved eligible events` | Each resolution plus 14-day correction window | Event operations | A low rate blocks public expansion. |
| Report rate | `distinct accounts submitting report_submitted_v1 / weekly active social accounts` | Rolling 7 days | Safety | A rising rate requires qualitative review; never optimize it down by hiding reporting. |
| Block rate | `distinct accounts with block_applied_v1 / weekly active social accounts` | Rolling 7 days | Safety | Segment by private-group size bucket only; no target identity reporting. |
| Notification opt-out | `distinct authorized users moving permission to denied / distinct authorized users previously not denied` | Rolling 7 days | Product + Lifecycle | High rate means notification frequency/content needs review. |
| Lock integrity failure | `forecast_lock_rejected_v1 due to late/duplicate/stale/auth / forecast_submit_requested_v1` | Rolling 7 days | Backend | Expected rejections are separately classified; unexpected system failures must be near zero. |

## 7. Decision thresholds

These are provisional gates, not research results. Use a minimum of 10 independent private groups,
at least 30 activated accounts, and enough complete lifecycle time before interpreting them. Do not
average away a safety incident.

| Decision | Quantitative and qualitative condition | Required action |
|---|---|---|
| **Scale** | At least 40% first-forecast activation, at least 50% reveal return, at least 25% repeat resolved participation, and at least 0.50 QGLL per active group over two consecutive 28-day cohorts; 80%+ of research participants correctly explain lock and visibility; no unresolved critical safety/integrity incident. | Expand the controlled private beta and prioritize F0.2/Phase 1 delivery; public-network work remains gated by F0.5 and Phase 3 requirements. |
| **Iterate** | Activation is 20–39%, reveal return is 25–49%, repeat participation is 10–24%, or comprehension is below 80% without a critical safety breach. | Diagnose by funnel step and session observation; change one or two highest-confidence friction points; rerun five uncoached sessions and a fresh cohort. |
| **Kill / pause social expansion** | Activation below 20% or reveal return below 25% after two materially different prototype/cohort iterations; fewer than 10% repeat participation; participants cannot reliably explain visibility/lock; or any confirmed critical privacy, integrity, harassment, or unsafe-content incident. | Stop invitations and new social rollout, preserve local journal access, investigate, document the decision, and do not build Phase 2+ growth features. |

## 8. Assumptions to falsify

| ID | Assumption | Disconfirming evidence | Method and owner |
|---|---|---|---|
| HIND-A01 | Fast capture increases activation without degrading understanding. | Users submit quickly but cannot explain what is locked or make material errors. | Prototype timing/comprehension; Design lead. |
| HIND-A05 | Private groups produce repeat use. | Groups create one event but do not return for a reveal or second resolved event. | QGLL/repeat-participation cohort; Product owner. |
| HIND-A06 | Receipts and direct challenges create safe organic interest. | Shares are confusing, accidental, unsafe, or do not yield informed invite opens. | Receipt usability and privacy review; Growth + Safety. |
| HIND-A07 | Users understand a proper-score-based comparison. | They interpret rank as raw wins, cannot explain sample qualification, or feel misled. | Result-screen comprehension test; Product + Data. |
| HIND-A08 | Events can be resolved credibly and on time. | Evidence is ambiguous, corrections/voids are frequent, or resolver workflow stalls. | Resolver dry run; Event operations. |
| HIND-A09 | iMessage later reduces invite friction. | Universal-link baseline is already sufficient or extension context confuses users. | Phase 2 experiment only; Growth. |

## 9. Five-session uncoached prototype research plan

### Purpose and participants

Run five moderated-but-uncoached sessions with adults who are not product contributors and who
regularly communicate in a small trusted group. Recruit a mix of prospective organizer and member
behaviors; do not recruit minors. Obtain consent, use participant codes, and keep only aggregate
notes—no recordings, prediction content, contact information, or screenshots containing personal
messages in this repository.

### Prototype and setup

- Test a high-fidelity prototype covering invite/open, group context, quick forecast, lock,
  offline/error state, resolution, result, and Receipt-preview paths.
- Use a test account and fictional objective event. Tell participants the prototype is not live;
  do not create real social records or send actual invitations.
- Use their own device when practical; otherwise test both smallest supported iPhone dimensions and
  iPhone 16 Pro Max. Enable one accessibility condition in at least one session.

### Moderator script

1. “You received this from a friend. Please do whatever you think you would do next. I cannot help
   unless something is broken.” Start the invite landing state.
2. After natural exploration, ask: “Who do you think can see this prediction right now, and what
   will change after you submit?” Record the answer before clarification.
3. “Make your best call and confidence before the deadline.” Do not define score or blind voting.
   Observe taps, backtracks, time to submission, and whether they notice the lock state.
4. Present the queued/rejected state: “What do you think happened? What would you do next?”
5. Present the resolved result: “Tell me what this result means, how the score was produced, and
   whether this means this person is generally better at predicting.”
6. Present a Receipt preview: “What would be shared if you sent this? Is anything missing or too
   exposed?”
7. Ask: “What would make you use this with your group again? What would make you avoid it?”

### Measures and stopping rule

- Record task completion without coaching, time to first server-lock request, deliberate actions
  after text entry, misinterpretations of visibility/lock/scoring, error recovery, and qualitative
  trust concerns.
- A session passes the core comprehension check only if the participant independently states that
  the forecast is time-locked after server confirmation and correctly identifies the audience.
- After all five sessions, synthesize themes by task; do not declare a pass based on an average.
  Revise the prototype if fewer than four participants complete the core loop uncoached or if any
  participant discovers a material privacy/lock misunderstanding. Run another five sessions after
  a material redesign.

## 10. F0.1 acceptance checklist

F0.1 is **not complete** until all items below are evidenced and the product owner explicitly
approves the contract.

- [ ] Product owner approves the primary user, first-session promise, Phase 1 boundary, and
  non-goals in this document.
- [ ] Design, Engineering, Data/Analytics, Safety, and Event Operations owners are named and
  acknowledge the relevant metric/permission responsibilities.
- [ ] F0.3 confirms the technical feasibility of server-authoritative lock and identity; no vendor
  or SDK is implied by this document.
- [ ] The event dictionary is reviewed against F0.5 privacy policy and has a documented retention,
  access, consent, and deletion design before production analytics is enabled.
- [ ] Five uncoached sessions are completed with aggregate, non-PII research notes and measured
  completion/comprehension; no results are invented in advance.
- [ ] Any changed product rule is recorded as a decision instead of silently changing this
  contract or the Social v2 master plan.
- [ ] The defined kill/iterate/scale gate is reviewed before expanding beyond the controlled
  private beta.

## 11. Open decisions and owners

| Decision needed | Why it blocks or constrains work | Proposed owner | Due before |
|---|---|---|---|
| Minimum account age, region availability, and prohibited event categories | Defines eligibility, safety policy, onboarding, and store/legal requirements. | Product owner + Safety + counsel | F0.5 implementation. |
| Initial private-group size limit and whether members may create events | Defines abuse surface, permissions, and rate limits. | Product owner + Safety | F0.4 schema/state machine. |
| Resolver appointment, dual-approval threshold, evidence classes, correction/void and appeal SLA | Determines whether a group result can be trusted. | Event Operations + Product | F0.4 state machine. |
| Scoring formula, score naming, minimum sample, coverage, and tie-break rules | Prevents misleading leaderboard and analytics claims. | Data/Analytics + Product | Phase 1 scoring implementation. |
| Default profile discoverability and group invite preview content | Controls unintended identity/group exposure. | Privacy + Safety + Product | F0.5 UX/policy. |
| Analytics storage, retention, access, consent and deletion design | Required before real participant telemetry. | Privacy + Data/Analytics | F0.5 and analytics implementation. |
| Backend vendor, account ownership, and dev/QA/prod separation | Enables implementation but must satisfy DEC-007. | Engineering + Release owner | F0.3 ADR. |

## 12. Handoff for implementers

This document authorizes no production feature code, backend SDK, external analytics SDK, social
data upload, or public launch. An implementation task must cite its exact master-plan ID, receive
the F0.3/F0.4/F0.5 gates that apply, implement the event dictionary without prohibited fields,
and attach the named automated and manual evidence. If a requirement conflicts with the feature
contract, preserve user privacy and server authority, stop, and request a recorded product
decision.
