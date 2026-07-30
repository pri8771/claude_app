# Hindsight Social v2 — Draft Legal, Safety, and App Store Release Checklist

**Status:** draft execution checklist. It is not legal advice, legal approval, an App Store submission, or evidence that an external review has occurred.

**Use:** Convert F0.5 policy work into assigned, reviewable launch gates. All entries are required before the relevant release scope; Phase 1 private-group testing must not be represented as public-network approval. “Owner” is a role to assign, not a statement that an owner has accepted the task.

## 1. Release sequence and rule

1. Complete the drafts and technical evidence below using synthetic/dev data.
2. Assign a named owner, target release scope, decision date, and evidence link for each row.
3. Obtain qualified legal/privacy and App Store review where the row says **approval required**.
4. Store final public-facing documents at stable URLs, version them, and record the effective version in consent records.
5. Do not enable a capability merely because copy exists. Server authorization, UI, support process, moderation staffing, and evidence must all be green.

## 2. Policy and user-facing document checklist

| Deliverable | What must be completed | Why / expected result | Proposed owner | Evidence required | Gate |
|---|---|---|---|---|---|
| Privacy Policy | Replace Build 1-only representation for Social v2 with final public policy covering controller/contact, data categories, purposes, legal bases as applicable, sharing/processors, retention, security, rights, deletion/export, children/age, location, notifications, analytics, cross-border transfers, changes, and contact/complaint process | Users can make an informed choice and disclosure matches actual data flow | Privacy/legal owner | Final version, counsel approval, public URL, effective date, version ID, data-flow mapping | Required before any external Social v2 testing or submission |
| Terms of Use | Define permitted use, forecast limitations/no professional advice, prohibited content/markets, account rules, user content/license, enforcement, disputes, liability/consumer terms, changes, and contact | Social behavior and enforcement have an enforceable, comprehensible boundary | Legal owner | Final Terms, counsel approval, acceptance UI/version record | Required before account creation for external testers |
| Community Guidelines | Publish simple examples of allowed content, prohibited harassment/sensitive-person predictions/scams/betting/advice, reporting, blocking, enforcement, and appeals | Members understand safe group behavior before posting | Safety + legal owner | Final guide, in-app/help URL, moderation macros/training | Required before UGC is externally available |
| Account deletion page | Provide in-app and web/support entry point, eligibility/authentication, immediate effects, timeline, exceptions, status/confirmation, recovery window if any, and support route | Deletion is discoverable and operationally executable | Privacy + support owner | Live/staged page, UX screenshots, synthetic end-to-end deletion evidence | Required before external accounts |
| Data export page/process | Explain downloadable categories, exclusions, secure delivery, request status, identity checks, and support escalation | Users can access their permitted data without exposing others | Privacy + support owner | Staged page, synthetic export file, fulfillment runbook/test | Required before external accounts unless counsel approves phased limitation |
| Support and safety pages | Provide contact route, report/block help, urgent-safety disclaimer/escalation guidance, account recovery, deletion/export, appeal route, and service hours | Users have a path that does not rely on group admins or developer DMs | Support + safety owner | URLs, queue ownership, templates, tested routing | Required before external UGC |
| Consent/preference copy | Finalize account/Terms acknowledgement, group audience/lock copy, migration consent, notification, location, analytics, sharing, and withdrawal behavior | Consent is specific and visible, not bundled or implied | Product + privacy owner | Annotated screens, consent record schema, usability findings | Required before each optional processing feature |

## 3. App Store and UGC compliance checklist

| Requirement | Required work | Owner | Evidence | Release gate |
|---|---|---|---|---|
| Privacy Nutrition Labels | Map each actual collected data type to Apple’s current disclosure categories, linkability, tracking status, purpose, and optional/required collection. Reconcile with production SDK/network capture; do not copy labels from Build 1 | Privacy + release owner | Approved mapping, network capture/redaction test, App Store Connect draft reviewed against final implementation | Before TestFlight external testing/submission; re-review on each new SDK/data flow |
| App privacy policy URL | Host final Social v2 policy at stable public URL; link in app and App Store metadata; preserve prior versions | Legal + release owner | URL accessibility check, screenshots, version record | Before external testing/submission |
| UGC safeguards | Implement report, block, content filtering/rate limits as appropriate, review/escalation, enforcement, appeal, and contact information. Confirm all user-generated fields are covered | Safety + engineering owner | Coverage matrix, UI/API tests, moderation runbook, staffing/on-call proof | Before groups, handles, prompts, avatars, or public content are externally enabled |
| Age rating and minors | Select rating only after age/content policy, questionnaires, UGC behavior, sensitive-content controls, and jurisdictional strategy are approved | Product + legal + release owner | Owner decision, counsel review, App Store questionnaire record | Before submission; hard blocker while age policy is unresolved |
| Sign in with Apple / account policy | If any third-party/social sign-in exists, evaluate Apple sign-in requirements; support account deletion in app; avoid prohibited credential handling | Engineering + legal/release owner | Auth flow review, deletion test, App Store checklist | Before submission |
| In-app purchases / contests / betting | Confirm no real-money wagering, prize contest, betting odds, financial trading, or regulated gaming mechanics. Escalate any future reward/season design for legal review | Product + legal owner | Scope attestation, copy review, feature-flag inventory | Before any build with social scoring/competition |
| Push notifications | Generic payloads; clear opt-in; no sensitive/private content on lock screen; accurate purpose disclosure | Engineering + privacy owner | Payload tests/screenshots, permission copy review | Before notifications are externally enabled |
| Data security and review access | Ensure demo/test accounts use synthetic data, reviewer instructions do not expose secrets, and support contact works | Release + engineering owner | TestFlight notes, synthetic review path, secret scan | Before external TestFlight/App Review |

## 4. Technical-to-policy evidence map

| Policy claim | Technical evidence that must exist | Responsible team | Required before |
|---|---|---|---|
| “Existing journal entries stay private unless you choose to share.” | Network-capture, migration interruption, and no-pre-consent-upload tests | iOS + backend QA | External Social v2 testers |
| “Forecasts lock at the shown time.” | Server UTC, concurrency/late/duplicate/replay rejection, immutable-ledger tests | Backend + QA | Any social forecast |
| “Only your group can see group content.” | Per-endpoint authorization tests for outsider/removed/blocked/cross-account access; invite token tests | Backend security + QA | External groups |
| “You can block and report.” | Server block semantics, report receipt, role-limited case view, audit tests, staffing SLA evidence | Safety + backend + QA | External UGC |
| “We minimize notification/share content.” | Push payload and Receipt render redaction tests | iOS + backend QA | Notifications/sharing |
| “We respect deletion/export requests.” | Synthetic request through revocation, queue, vendor reconciliation, secure download, completion confirmation | Privacy + support + engineering | External accounts |
| “Analytics does not contain private content.” | Event allowlist, redaction/unit tests, log sampling review, vendor configuration evidence | Data + engineering | Production telemetry |
| “QA is isolated from production.” | Separate project/account/domain/APNs/secret manifests and denied cross-environment test | Release + operations | QA promotion |

## 5. Approval register template

Do not mark a row approved without an actual reviewer, date, version, and evidence link.

| Approval | Required reviewer | Status | Version / date | Evidence / notes |
|---|---|---|---|---|
| Social v2 Privacy Policy | Qualified privacy/legal reviewer | Not started | — | — |
| Terms of Use | Qualified legal reviewer | Not started | — | — |
| Community Guidelines and enforcement matrix | Safety owner + legal reviewer | Not started | — | — |
| Age/minors decision and App Store rating | Product owner + qualified legal/release reviewer | **Owner decision required** | — | — |
| Data inventory, retention, subprocessors | Privacy owner + engineering owner | Not started | — | — |
| Deletion/export workflow | Privacy + support + engineering owner | Not started | — | — |
| Moderation roles, staffing, escalation SLA and appeals | Safety owner + operations owner | Not started | — | — |
| App Store labels, metadata, privacy URL, review notes | Release owner + privacy reviewer | Not started | — | — |
| Incident and legal-request runbooks | Legal/privacy + security/operations owner | Not started | — | — |

## 6. Phased go/no-go gates

### Gate A — Internal prototype/backend spike

- Use synthetic fixtures only; no external user accounts or user-generated content.
- No production analytics/notifications/third-party runtime SDK without approved dependency process.
- Draft policy can guide design but is not user-facing legal text.

### Gate B — External private-group test

- Final or counsel-approved test versions of Privacy Policy, Terms, Community Guidelines, deletion/support routes, and age decision are live and accepted through appropriate flow.
- Account, group, invite, visibility, immutable-lock, block/report, telemetry/push redaction, deletion/export, and environment-isolation evidence passes.
- Named support/safety owner and escalation channel are staffed for the test scope; no public discovery or public leaderboards are enabled.
- App Store Connect/TestFlight disclosures and test notes accurately match enabled data flows and UGC capabilities.

### Gate C — Public-network launch

- All Gate B requirements remain green; public profile/discovery/location/leaderboard-specific copy and authorization are separately verified.
- Public-event evidence, resolution/appeal operations, anti-cheat controls, moderation capacity, public UGC policy, rate limits, incident game day, and country/category restrictions are approved.
- Re-evaluate age rating, privacy labels, Terms, retention, processor list, cost/abuse SLOs, and legal restrictions before rollout.

## 7. Open blockers and ownership needed now

1. **Age/minors policy:** product owner and qualified counsel must choose the supported audience/jurisdictions and gating approach.
2. **Retention schedule:** privacy/legal owner must replace proposed ranges with approved, jurisdiction-aware periods and backup/legal-hold policy.
3. **Processor/vendor disclosures:** defer final list until F0.3/F0.7 select and provision services; no SDK/vendor commitment is implied by this checklist.
4. **Moderation operations:** safety/operations owner must name staff, coverage, escalation contacts, tooling, and realistic SLAs before external UGC.
5. **Final public documents:** qualified review and hosting are required; this repository draft is not a substitute.

## 8. Change control

Any new social field, third-party SDK, public visibility, location behavior, profile/UGC surface, notification payload, retention change, or regional rollout triggers: data-inventory update; privacy-label review; Terms/Guidelines/consent impact assessment; security/threat-model review; test update; and approval-register entry. Feature flags must keep unapproved scopes disabled by default.
