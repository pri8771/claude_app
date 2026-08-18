# Decisions

## DEC-001 — Project registration

- **Status:** accepted
- **Context:** This repository is governed by the App Factory standards.
- **Decision:** Use `.factory/project-context.json` as the authoritative project classification marker.
- **Consequences:** Agents must read the registration and quality files before coding.

## DEC-002 — Capture depth

- **Status:** proposed
- **Context:** The four mandatory steps create excessive friction before value.
- **Decision:** Support a compact quick capture and treat alternatives, detailed trade-offs, and predictions as optional enrichment.
- **Consequences:** A worker must define minimum fields and behavior for partial decisions before implementation.

## DEC-003 — Demo data

- **Status:** accepted
- **Context:** Empty Insights and zero-count dashboards do not explain the product.
- **Decision:** Recommend an explicit removable demo during onboarding; allow it alongside user data and remove only tagged demo records.
- **Consequences:** Demo data must remain distinguishable, idempotent, and excluded from user exports unless clearly disclosed.

## DEC-004 — Insights purpose

- **Status:** accepted
- **Context:** A long metric stack is less useful than a clear lesson or next action.
- **Decision:** Prioritize review backlog, calibration, recurring patterns, and sample-aware explanations.
- **Consequences:** Every displayed claim requires deterministic statistics coverage.

## DEC-005 — Networked social product direction

- **Status:** accepted
- **Date:** 2026-07-30
- **Context:** Private group predictions, friends, shared scoreboards, iMessage challenges, curated
  public events, and public leaderboards require identity, shared state, server-authoritative
  timestamps, resolution operations, moderation, and anti-cheat controls. The previous
  local-only/backend-prohibited constraint cannot support the approved product.
- **Decision:** Hindsight becomes a networked social prediction platform with a valuable private
  mode. A backend is permitted. The Social v2 program is governed by
  `SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md`; its foundation gates precede social feature code.
- **Consequences:** App Store disclosures, privacy policy, account deletion, Terms, infrastructure,
  support, safety, and release operations must change before a networked build reaches testers.
  The existing Build 1 release remains a separately testable local product and is not represented
  as already networked.

## DEC-006 — Hybrid data authority and explicit sharing

- **Status:** accepted
- **Date:** 2026-07-30
- **Context:** The factory currently exposes a Boolean `localFirst` constraint, but the approved
  architecture needs different authority by data domain.
- **Decision:** Unsaved drafts and legacy journal records remain device-authoritative until
  explicit migration consent. Accounts, relationships, groups, social/public events, forecasts,
  server timestamps, resolutions, scores, and leaderboards are server-authoritative. Devices may
  cache server data and queue permitted mutations, but must not claim a social lock or result
  before server acknowledgement.
- **Consequences:** Existing content is never silently uploaded. Visibility is explicit
  (`private`, `group`, `unlisted`, or `public`) and enforced server-side. The project context sets
  `localFirst` to false because the product is no longer exclusively local-first; this decision is
  the more precise authority contract until the central schema supports a hybrid value.

## DEC-007 — Backend dependencies require a separate architecture decision

- **Status:** accepted
- **Date:** 2026-07-30
- **Context:** A backend is approved, but no vendor, hosted processor, or iOS client SDK has been
  selected.
- **Decision:** Keep third-party runtime dependencies prohibited until F0.3 records a specific ADR
  and change request naming each dependency, purpose, privacy/license impact, update owner, cost,
  exit strategy, and native/protocol boundary.
- **Consequences:** Planning may evaluate vendors and use throwaway spikes, but production feature
  code must not introduce an unapproved SDK or credential.

## DEC-008 — Conditional managed-Postgres backend direction

- **Status:** proposed; not accepted until the F0.3 proof-of-fitness spike passes
- **Date:** 2026-07-30
- **Context:** The weighted comparison in `SOCIAL_V2_BACKEND_EVALUATION.md` favors relational
  authorization and transactions for groups, immutable forecast locks, resolution ledgers,
  scoring, moderation, and leaderboards. A fully custom service provides maximum control but
  transfers operations and security ownership too early; Firebase increases relational and
  aggregation complexity; CloudKit does not satisfy the independent public-network authority.
- **Proposed decision:** Use Supabase-hosted Postgres in isolated projects, behind a thin
  vendor-neutral Hindsight API and transactional server functions. iOS uses native
  `AuthenticationServices`; no Supabase iOS SDK or generic direct-table mutation is approved.
- **Acceptance gate:** Prove Apple-token validation/replay rejection, outsider/removed/blocked
  authorization, one atomic server-UTC forecast lock and audit event under concurrency, immutable
  resolution/score ledgers, private realtime/APNs recovery, backup/export, and dev/QA isolation
  with synthetic data.
- **Consequences:** Until the spike passes, this remains an evaluation target rather than a
  dependency or infrastructure commitment. Failure reopens the decision; it never permits a
  client-authoritative fallback.

## DEC-009 — Future Postcards v3 reflection-first personal baseline

- **Status:** accepted
- **Date:** 2026-08-08
- **Context:** The approved `Hindsight - Future Postcards - Production Candidate v3 - Guided Start - Complete Clickable` design and its v3 specification establish a guided-start, reflection-first experience. Existing Social v2 planning remains valuable but would be premature as the first implementation target if it replaces the personal habit loop.
- **Decision:** Implement the Future Postcards v3 personal core first: one local prediction statement, intentional 0–100 confidence, optional Why, future return date, atomic local seal, durable draft, later resolution/reflection, and central sample-aware analytics. Personal records remain local SwiftData-authoritative in this slice. Social capabilities are additive—not a replacement for private reflection—and must remain feature-flagged off/fail-closed until their separately approved account, authority, safety, and backend gates are met.
- **Consequences:** The implementation baseline is `FUTURE_POSTCARDS_V3_IMPLEMENTATION_BASELINE.md` and the executable quality boundary is `quality/feature-contracts/future-postcards-v3-personal-core.json`. Guided samples require explicit provenance and strict isolation from personal metrics and data. Accounts, synchronization, friends, Circles, shared forecasts, messages, public events, leaderboards, and backend vendor work are staged later work; this decision neither claims they ship nor reverses DEC-005 through DEC-008.

## DEC-010 — VoiceOver deferred across the portfolio, not descoped

- **Status:** accepted
- **Date:** 2026-08-17
- **Context:** The manual VoiceOver device pass (`RELEASE_CHECKLIST.md`, `TEST_PLAN.md`) has sat unexecuted as an open checklist item. The owner made a portfolio-wide call to defer VoiceOver work across every app for now, to focus effort on the free/local-only real-world testing pass first.
- **Decision:** VoiceOver manual review is deferred, not descoped — unlike Mala/Japa's `DEC-010` (permanent, product decision, VoiceOver ruled out entirely for that app), Hindsight's VoiceOver work is expected to resume later, once free-tier real-world testing across the portfolio is done. Discrete, already-identified VoiceOver gaps found during code review (e.g. the two unlabeled icon buttons fixed 2026-08-17) are still fixed as found — this defers the *systematic device pass*, not opportunistic fixes. Dynamic Type remains in scope and is not deferred.
- **Consequences:** `RELEASE_CHECKLIST.md` and `TEST_PLAN.md`'s VoiceOver line items are not launch-blocking until this is revisited. Do not claim VoiceOver support is verified or complete in any release notes or store copy while this stands.
- **Related Files:** `Docs/RELEASE_CHECKLIST.md`, `Docs/TEST_PLAN.md`, `Docs/BUGS.md`

## DEC-011 — Ship 1.0 (4) to App Review on simulator evidence; device/accessibility gates waived, not done

- **Status:** accepted
- **Date:** 2026-08-18
- **Context:** Version 1.0 with build `1.0 (4)` was ready to submit (listing pack in `APP_STORE_LISTING.md`, build processed in App Store Connect). The two remaining open gates in `RELEASE_CHECKLIST.md` — the build-4 physical-device pass and the manual notification-permission / largest Dynamic Type / contrast / reduced-motion review — could not be run: the paired iPhone 16 Pro Max is unavailable and no other device was at hand. VoiceOver is already deferred by DEC-010.
- **Decision:** The owner consciously waived those two gates for the 2026-08-18 App Store submission of 1.0 (4) only, and version 1.0 was submitted for App Review the same day (ASC "Waiting for Review"). The gates are recorded as **waived**, not satisfied; the checklist items stay unchecked. The candidate stays `verification_pending` until App Review approves and the release is live.
- **Consequences:** Waiver record: `quality/waivers/1.0-4-device-and-accessibility-owner-waiver-2026-08-18.md`. Any later build (a 1.0 resubmission after rejection, or 1.1) must run the gates with dated evidence or obtain a new explicit waiver. Do not describe 1.0 as device-verified in any doc, release note, or store copy.
- **Related Files:** `Docs/RELEASE_CHECKLIST.md`, `Docs/STATUS.md`, `Docs/DEFERRED_EXTERNAL_ACTIONS.md`, `quality/evidence/app-store-submission-1.0-4-2026-08-18.md`
