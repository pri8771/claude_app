# Future Postcards v3 — Implementation Baseline

**Status:** approved design baseline; implementation contract is `in_progress`  
**Date:** 2026-08-08  
**Owner:** Product / iOS implementation

## Authority and scope

The authoritative approved design reference is the Claude Design prototype named
**`Hindsight - Future Postcards - Production Candidate v3 - Guided Start - Complete Clickable`**.
The authoritative companion specification is **`Hindsight - Future Postcards - Production Design Specification v3`** (the “v3 spec”). The Claude Design artifacts remain the visual and interaction source; they have not been exported into this repository.

This document converts that approved guided-start/personal-product direction into an implementation boundary. If a prior local journal document or a later social planning document conflicts with the personal v3 behavior below, this baseline governs the first implementation slice. It does not revoke DEC-005 through DEC-008; it sequences them. Backend, accounts, friends, Circles, shared predictions, public events, and messages remain later, separately gated work.

## Product promise

Hindsight is reflection-first: write a falsifiable future belief, state confidence, return later, and compare belief with reality. The immediate experience is personal-first, warm, and private. Analytics are a central payoff of the loop, not a settings report. Social features may become additive after the personal loop is durable; they must not replace or silently broaden a personal record.

## First implementation slice

Build the smallest complete personal loop before any social surface:

1. Open **Capture** from the primary navigation.
2. Enter one prediction statement.
3. Select an intentional confidence value on a **0–100** slider with a textual percentage equivalent.
4. Optionally add **Why?** reasoning.
5. Choose a future return date (suggested choices or custom date).
6. Seal once, persist atomically, and return to **Now**.
7. Reopen the sealed postcard when due and resolve it without modifying its original statement, confidence, or reasoning.

The durable local draft is part of this slice: interruption, validation failure, or persistence failure must retain entered text, confidence, optional reasoning, and return date until the user deliberately discards it.

### Slice acceptance boundary

- Local SwiftData is authoritative for personal drafts, personal postcards, and local resolutions.
- A seal is locally confirmed only after the SwiftData transaction succeeds; the UI must never show a sealed success state before that confirmation.
- A duplicate tap or stale save may create at most one personal postcard.
- Sample content, if loaded in guided start, is explicit, deterministically identified, visibly marked, and excluded from all personal statistics, counts, streaks, exports, reminders, notifications, and relationships.
- All social rollout flags default off and fail closed. No social route, remote request, account migration, or background synchronization is introduced by this slice.

## Initial information architecture and screen inventory

The native shell uses five destinations: **Now**, **Hindsight**, **Capture**, **Insights**, and **Circles**. Circles is a gated future destination: until its separately approved phase exists it must expose a truthful unavailable/coming-later state or remain inaccessible; it must not simulate live social activity.

| Area | Initial screen / state | Required behavior |
| --- | --- | --- |
| Guided start | Welcome / tour step 1: write a prediction | Explain the personal loop; skip is always available. |
| Guided start | Tour step 2: stamp confidence | Use the same production 0–100 confidence control and text value. |
| Guided start | Tour step 3: return and compare | Explain resolution and reflection without claiming future data exists. |
| Guided start | Start choice | Explicitly choose `Explore with sample postcards` or `Start with my own`; samples are never inserted automatically. |
| Now | Active mailbox | Show due, upcoming, and recently sealed real postcards; use loading, empty, error, and retry states. |
| Now | Active postcard detail | Show immutable original content, confidence, optional Why, return date, and time state. |
| Capture | One-screen composer | Statement, confidence slider, optional Why, suggested/custom return date, validation, durable draft, and one Seal action. |
| Capture | Sealing / success / failure | Disable duplicate submission while saving; only show animation/haptic after commit; preserve draft and offer retry after failure. |
| Resolution | What happened? | Offer correct, incorrect, partially correct, cancelled, and unresolvable with optional reflection; preserve original belief. |
| Hindsight | Resolved history | Chronological resolved postcards with search, filters, empty/loading/error/retry states. |
| Hindsight | Resolved postcard detail | Compare original belief and confidence with outcome and reflection; never rewrite history. |
| Insights | Personal summary | Present honest accuracy/calibration insight cards plus denominator and insufficient-data state; samples excluded. |
| Insights | Detail/explainer | Explain the metric, date range, eligible record count, filters, and no-data state. |
| Sample mode | Banner / labelled sample cards | Persistent exploration marker; every sample surface has exactly one `SAMPLE` marker. |
| Sample mode | Removal confirmation / progress / failure | State exact sample count and breakdown, delete only explicit sample records, preserve real records, retry safely, and offer a short undo where supported. |
| Settings | Tour, sample, and data controls | Replay tour without resetting data; load/remove samples explicitly; do not automatically remove samples after real capture. |
| Circles | Gated placeholder | Truthfully represent future social work; no fake members, messages, scores, or network state. |

## Reusable component inventory

- App shell, tab items, capture affordance, navigation chrome, sheets, dialogs, and confirmation banner.
- Postcard preview, postcard detail, sealed state, due state, resolved comparison, postcard paper/stamp treatment.
- Statement field, optional Why field, confidence slider/stamp and accessible textual value, suggested-date chips, custom date picker.
- Primary, secondary, destructive, disabled, loading, retry, and text actions.
- Status badge, sample badge, persistent sample banner, exact-count removal confirmation, toast/inline error, empty/loading/error/retry views.
- Insight summary card, metric card, chart container, low-sample explanation, and accessible chart summary.

All controls preserve the v3 visual language through semantic SwiftUI tokens for color, typography, spacing, radius, elevation/material, status, and motion. The implementation must support light/dark mode, 44×44-point controls, Dynamic Type including largest accessibility sizes, VoiceOver labels/focus order, non-color status cues, and a reduced-motion equivalent for sealing/opening/reveal states.

## Interaction and state rules

### Capture and seal

- Prediction text is required and normalized only for whitespace; its authored meaning must not be changed.
- Confidence is required as an intentional 0–100 selection and is always announced/read as text (for example, `75% confident`).
- Why is optional and may be blank.
- Return date must be valid and in the future under the device calendar/time-zone rules disclosed by the date control.
- Save is a single transaction. While saving, controls prevent repeat submission and a second tap cannot create another item.
- Failed saves retain the visible composer and its durable draft, announce an actionable error, do not play success feedback, do not dismiss, and do not schedule reminders.
- A sealed personal postcard is immutable for statement, confidence, return date, and original Why. Any future edit capability must create explicit revision semantics, not rewrite history.

### Resolution and reflection

- Resolution records the selected outcome and optional reflection separately from the original sealed belief.
- Cancelled and unresolvable records are not eligible for accuracy/calibration claims unless a future metric contract explicitly defines them.
- Resolution save follows the same atomic, duplicate-protected, retained-draft requirements as seal.

### Insights

- Insights use only eligible, real, resolved personal records.
- Every claim shows a denominator/sample count, date range where applicable, and a path to an explanation.
- Sparse data produces an honest `not enough history yet` state rather than a favorable or unfavorable claim.
- Initial metrics include accuracy, average confidence, calibration gap, confidence bands, and over/under-confidence direction. Brier score and category/timeframe analysis may follow once their deterministic specifications and tests exist.

### Sample lifecycle

- Sample records carry explicit stable sample provenance; titles, text, or appearance are never used to identify them.
- Loading is idempotent and cannot create duplicate samples.
- Samples never become real records through editing, sharing, resolution, or migration.
- Removal is idempotent, transactional where possible, and targets only explicit sample provenance plus sample-derived state.

## Explicit exclusions from this baseline slice

- Authentication, user accounts, server APIs, remote synchronization, push registration, or any migration/upload of existing private records.
- Friends, invitations, shared lists, group voting, group analytics, leaderboards, public profiles, curated/public events, referrals, or social sharing beyond future separately approved share-safe artifacts.
- Direct/scheduled messages, comments, feeds, contact import, precise location, betting, prizes, or real-money mechanics.
- Any backend vendor SDK, third-party runtime dependency, secret, tracking SDK, or personal-content telemetry.
- Invented social/sample activity, simulated delivery, false locks, fabricated insights, or misleading “coming soon” claims.

## Implementation order and evidence

1. Establish tokens/components and the personal local domain/repository boundary.
2. Implement and test durable capture plus atomic seal.
3. Implement Now, due state, resolution, and local history.
4. Implement sample isolation/removal and guided start.
5. Implement calculation engine and Insights only from eligible real records.

The companion feature contract defines acceptance tests. This baseline remains `in_progress` until code and the required unit, persistence/relaunch, UI-smoke, accessibility, dark-mode, responsive-layout, and sample-isolation evidence exist.
