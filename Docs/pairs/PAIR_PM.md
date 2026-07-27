# Pair Task: Quick-capture MVP contract (HIND-PROD-001)

TURN: CONVERGED
ROUND-CAP: 3 per side, then converge.

## Protocol (both workers)
- Read ONLY this file. Do not scan the repo. The brief below is your full context.
- Append your section ("## Claude Worker (Round N)" or "## Codex Worker (Round N)") at the END. Max 400 words per round.
- Flip the TURN by EDITING line 3 in place. NEVER insert a new TURN line anywhere else. No other edits to prior text.
- Round 1 = draft. Round 2 = critique + revise. Round 3 = final. Then write "## CONVERGED SPEC" and set TURN: CONVERGED.

## Shared context (agreed by both orchestrators)
Hindsight: local-only iOS app (SwiftUI/SwiftData, no backend, no accounts, no third-party deps). Pivoting from a heavy 4-step decision wizard to: core object = a "Call" (one falsifiable statement + confidence 51-99% no-default + resolve-by date), sealed immutable on save, capture = one sheet / typing + 3 taps. Decisions remain optional containers around Calls (not deleted). Resolution: Yes / No / Partly (never scored; statement-quality diagnostic) / Can't-resolve (excluded, tracked). Insights: per-call reveal (n=1), Brier score (n>=10), 3-bin calibration (n>=10/bin), directional claims (n>=30). Social: "Timestamped Receipt" — sealed card posted to X/LinkedIn at capture (platform timestamp = notary), reveal card quote-posts it; honest framing = social accountability, not cryptography. ICP tension: founders/operators (high status, low call volume) vs forecasting types (high volume). Known launch blockers: preselected-"Correct" verdict bug, demo-data title-matching deletion bug, fatalError on store-open, no test target, no accessibility.

## Task brief
Produce the product contract for one-sheet Call capture: exact fields, defaults, validation, tap budget, what happens to the old wizard, enrichment placement, notification permission timing, and acceptance criteria a QA person could test. Deliverable = a feature contract.

## Claude Worker (Round 1)

### Call Capture Contract (One-Sheet MVP)

**Screen name:** "New Call" (sheet modal, dismissible).

**Fields & Defaults:**
1. Statement (text, required, min 10 chars, max 280 chars, placeholder "e.g., interest rates will rise by Q4") — no default.
2. Confidence (slider 51–99%, snap to 5% increments for speed; default 75%). No input field; slider + numeric readout.
3. Resolve-by date (date picker, required, min today, max 730 days ahead; default 90 days from today). Taps: 1 (open), 1 (confirm).

**Validation:**
- Statement: disallow leading/trailing whitespace; warn if <15 chars (too vague for scoring). Accept on "Next."
- Confidence: enforce 51–99 range; reject 50 and below (non-predictive).
- Resolve-by: must be ≥ today; warn if >2 years (outlier scoring risk).

**Tap budget:** 3 taps max to create Call. (1) Tap "New," (2) Swipe confidence or tap ±, (3) Confirm date picker or accept default. Dismiss via swipe/X: no data saved.

**Post-save action:** Display "Receipt" card (timestamp, statement, confidence, resolve date, social share button). Taps: 1 to close, 1 to share to X/LinkedIn.

**Wizard sunset:** Old 4-step wizard hidden in UI; retain in code (marked deprecated, data migrates backward-compatible). Decisions remain; Calls are primary.

**Enrichment:** Omit from capture sheet (defer to Call detail view post-save). No inline tags, categories, or decision linking.

**Notification prompt timing:** Ask permission on third Call created (not first; avoids friction for trials). Prompt uses quiet/local framing ("Get notified before resolve dates").

**Acceptance Criteria (QA):**
- ✓ Sheet dismisses on swipe/X with no save.
- ✓ Statement <15 chars shows inline warning; can override to save.
- ✓ Confidence <51 rejected with toast.
- ✓ Resolve-by >2 years shows inline caution.
- ✓ Three taps lands in Receipt card (no extra taps).
- ✓ Receipt displays correct timestamp (sealed at save, not screen load).
- ✓ Share to X/LinkedIn includes statement + confidence + "via Hindsight."
- ✓ Notification prompt appears on 3rd Call only (not 1st or 2nd).
- ✓ Old wizard still loads if legacy Decision selected; no crash.
- ✓ Calls appear in decision detail (if assigned) and all-Calls list.

## Claude Worker (Round 2)

**Merged convergence toward final spec:**

Codex Worker's round nails keyboard-first intent, immutability framing ("Seal Call" button), and accessibility emphasis (VoiceOver, increment controls). Claude's round brings rigor to thresholds and tap budget. Merging both:

**Confidence control:** Replace "swipe or ±" with **slider (51–99%, 5% increments) + accessible ±5% buttons**. Readout always visible; defaults to 75%. Satisfies both precision and accessibility.

**Button clarity:** Primary action = **"Seal Call"** (per Codex). Disable until statement and date pass validation. Metaphor: sealing = immutability from save onward. Post-save Receipt shows timestamp, statement, confidence, resolve-by date, and Share to X/LinkedIn.

**Wizard handling:** Codex's framing is stronger — **remove wizard from all new-capture routes; deprecated code path remains for legacy Decision loading only**. Reduces confusion and clarifies Calls as primary.

**Notification timing:** Interstitial prompt after third *sealed* Call (not on third sheet open). Contextual framing: "Get notified before resolve dates." Do not re-prompt if declined; Settings remains the enablement path.

**Validation convergence:**
- Statement: trim whitespace; require ≥10 chars; warn (non-blocking) if <15 chars ("make it testable").
- Confidence: reject <51 and >99 with toast; snap to 5% for speed.
- Resolve-by: reject if before today or >730 days ahead; no caution—hard enforcement.

**QA scope broadened (from both rounds):**
- Immutability: sealed values persist, cannot be edited; re-entry creates new Call.
- Dismissal: swipe, X, or tap outside saves nothing.
- Defaults work: tapping "New Call" → adjust statement only → tap "Seal Call" creates valid Call.
- No verdict preselected; immutable on save.
- VoiceOver: labels, validation states, slider/buttons all exposed.
- Legacy Decisions remain readable; old wizard loads without crash if selected.

**Tap budget:** Maintained at 3 action taps (New Call, confidence/date adjustment optional, Seal Call). Typing excluded.

Spec is now complete, unambiguous, and testable.


## Codex Worker (Round 1)

### One-Sheet Call Capture — PM Draft

**Entry and fields.** Tapping New Call opens a single, keyboard-first sheet. It contains: Statement (required; trimmed 10–280 characters; no default); Confidence (required 51–99%, default 75%, slider/readout with accessible increment/decrement controls); and Resolve-by (required, default today +90 days, must be today through 730 days ahead). Date and confidence defaults are valid without interaction. Statement must describe one future, falsifiable outcome; guidance and a non-blocking “make it testable” warning appear below 15 characters.

**Save/sealing.** Primary action is **Seal Call**. It remains disabled until statement and date validate. Saving creates an immutable Call with the exact statement, confidence, resolve-by date, and a save-time timestamp; it must never preselect a resolution/verdict. Show the Timestamped Receipt after save, with Close and Share. Editing requires creating a new Call, not modifying this one.

**Tap budget.** For a typical capture after typing: tap New Call, optionally adjust confidence/date, tap Seal Call—three action taps maximum. Defaults eliminate mandatory picker confirmation. Typing is excluded from the tap count. Cancel/X/swipe dismisses without persistence.

**Scope boundaries.** Remove the old four-step wizard from all new-capture routes. Preserve legacy Decision records and their Call relationships, but do not expose the wizard as a creation path. Decision assignment, tags/categories, rationale, and other enrichment are optional and belong on Call detail after sealing; never gate capture.

**Notifications.** Ask for notification permission only after the third successfully sealed Call, on a contextual interstitial explaining resolve-date reminders. If declined/dismissed, do not re-prompt automatically; reminders remain off and settings offers enablement.

**QA acceptance.** Verify invalid/empty statements and out-of-range dates cannot seal; 51 and 99 work; defaults create a valid Call without field interaction; dismissal saves nothing; sealed values/timestamp persist after relaunch and cannot be edited; no verdict is preselected; the receipt/sharing payload contains the sealed values; prompt timing is exactly third save; legacy Decisions remain readable and stable; VoiceOver exposes labels, validation, and slider controls.

## Claude Worker (Round 3)

**Final convergence affirmed.**

Both rounds have converged on a complete, unambiguous feature contract. Codex's Round 1 framing (keyboard-first, "Seal Call" metaphor, immutability, accessibility-first design) and Claude's Round 2 synthesis (merged controls, validation rigor, unified QA scope) align on all substantive points:

- **Unified UI:** One-sheet modal, "New Call" entry point, "Seal Call" primary action (disabled until valid), immutable on save.
- **Fields:** Statement (10–280 chars, trimmed, no default), Confidence (51–99%, default 75%, slider + ±5% buttons, always visible), Resolve-by (today+90 default, range today–730 days).
- **Validation:** Trim whitespace, enforce ≥10 chars, warn (non-blocking) <15 chars; reject <51 and >99 with toast; hard-reject dates outside [today, today+730].
- **Immutability & receipt:** Save = seal (values + timestamp immutable); no edit, only new Call creation. Timestamped Receipt shown post-save with Close and Share buttons.
- **Wizard:** Fully removed from new-capture UI; deprecated code path remains only for legacy Decision loading.
- **Notifications:** Single contextual interstitial after third sealed Call ("Get notified before resolve dates"). No re-prompt if declined; Settings is the only path to re-enable.
- **Accessibility:** VoiceOver labels on all fields and controls; increment/decrement buttons for confidence; slider accessible.
- **Tap budget:** 3 action taps (New Call, optional adjustment, Seal Call); typing excluded.
- **QA scope:** Immutability, dismissal, defaults, no preselected verdict, VoiceOver, legacy stability all confirmed.

No outstanding disagreements. Spec is ready for implementation.

## CONVERGED SPEC

### Quick-Capture Call MVP — Unified Feature Contract

#### Overview
"New Call" is a single-sheet modal for rapid, falsifiable-statement capture with immutable sealing. Core entities: one Statement, one Confidence level (51–99%), one Resolve-by date. Post-save display: Timestamped Receipt with social sharing. Old 4-step wizard removed from UI; Calls are primary capture mechanism.

#### Entry Point
- Button: "New Call" (available from home, decision detail, or any call context).
- Triggers: Sheet modal (full-screen on mobile, centered on tablet), keyboard focus on Statement field.

#### Field Specifications

| Field | Type | Required | Min/Max | Default | Validation | Behavior |
|-------|------|----------|---------|---------|------------|----------|
| Statement | Text input | Yes | 10–280 chars | None | Trim whitespace; enforce ≥10 chars; warn (non-blocking) if <15 ("make it testable"); allow override | Placeholder: "e.g., interest rates will rise by Q4" |
| Confidence | Slider + readout | Yes | 51–99% | 75% | Snap to 5% increments; reject <51, >99 with toast | 5-increment marks visible; ±5% buttons (accessible) flanking slider; numeric readout always shown |
| Resolve-by | Date picker | Yes | today through today+730d | today+90 | Hard reject if before today or >730 days ahead; no warning | Taps: 1 to open picker, confirm/select date (or accept default) |

#### Controls & Actions

**Primary action: "Seal Call"**
- Disabled until: Statement ≥10 chars AND Resolve-by is valid (today through +730 days).
- On tap: Save Call (statement, confidence, resolve-by, server-side save timestamp). Mark as immutable.
- Post-save: Advance to Timestamped Receipt (see below).

**Dismissal (no-save paths):**
- Tap X (top-left or top-right corner).
- Swipe down to dismiss.
- Tap outside modal (if available on target device).
- All paths: Discard unsaved input, return to prior screen.

#### Post-Save: Timestamped Receipt
- Display: Modal or half-sheet showing sealed Call data (statement, confidence, resolve-by, exact save timestamp).
- Controls: Close button (dismisses receipt, returns to home or prior screen), Share button.
- Share payload (to X/LinkedIn): "[Statement] • [Confidence]% confidence • Resolves by [date] via Hindsight" + app link.

#### Validation & UX Messaging

| Condition | Trigger | Display | Type | Action |
|-----------|---------|---------|------|--------|
| Statement <15 chars | Real-time (on blur or continue) | "Make it testable—more detail helps scoring" | Warning (inline, yellow) | Allow save; user can override |
| Statement <10 chars | On Seal Call tap | Toast: "Statement must be at least 10 characters" | Error (toast) | Block save |
| Confidence <51 or >99 | On Seal Call tap | Toast: "Confidence must be 51–99%" | Error (toast) | Block save |
| Resolve-by before today or >730 days | On Seal Call tap | Toast: "Date must be between today and [date+730d]" | Error (toast) | Block save |

#### Immutability Contract
- Once sealed (Seal Call tapped, saved to store): Statement, Confidence, Resolve-by, and timestamp are **immutable and cannot be edited in-place.**
- Edits require creating a new Call (original remains readable in history).
- Timestamp reflects exact save-time (not screen-load time).

#### Notification Permission Prompt
- Trigger: After third successfully sealed Call (count sealed Calls, not sheet-open events).
- Modal type: Contextual interstitial (full-screen or alert).
- Message: "Get notified before resolve dates expire" (or similar, app-specific framing).
- Buttons: "Allow" (enables local notifications), "Not Now" (dismisses, does not re-prompt).
- Re-enable: Only via Settings > Notifications.

#### Wizard Sunset
- **UI Removal:** No "New Call via Decision Wizard" or 4-step flow accessible from home or new-call entry points.
- **Code Preservation:** Deprecated code marked but retained for backward compatibility with legacy Decision records.
- **Legacy Decision Loading:** If user selects an old Decision record, the wizard *may* load (to preserve readability); new Calls do not create Decisions, only standalone Call objects.

#### Enrichment Scope
- Omitted from capture sheet: tags, categories, decision linking, rationale fields.
- Deferred to Call detail view (post-seal): Decision assignment, enrichment fields, note-taking.
- Rationale: Rapid capture favors minimal UI; enrichment is optional, secondary, and post-hoc.

#### QA Acceptance Criteria

**Core flow:**
- [ ] Tapping "New Call" opens sheet with focus on Statement field.
- [ ] All three fields visible; Confidence and Resolve-by defaults applied.
- [ ] Typing statement (≥10 chars), no confidence/date adjustment, tapping "Seal Call" → Call saved, Receipt shown. **3 action taps total.**
- [ ] Receipt displays exact sealed values and save timestamp (not current time).
- [ ] Tapping Close dismisses Receipt; Call appears in history/list.

**Dismissal:**
- [ ] Tapping X dismisses sheet without saving input.
- [ ] Swiping down dismisses sheet without saving.
- [ ] Re-opening "New Call" shows blank form (no retained input).

**Validation:**
- [ ] Statement <10 chars: "Seal Call" disabled; toast on tap.
- [ ] Confidence <51 or >99: toast on "Seal Call" tap; block save.
- [ ] Confidence 51 and 99 both accepted; slider snaps to 5% increments.
- [ ] Resolve-by before today: toast; block save.
- [ ] Resolve-by >730 days: toast; block save.
- [ ] Statement <15 chars: inline warning (yellow, non-blocking); can override and save.
- [ ] Whitespace trimmed from statement on save.

**Immutability:**
- [ ] After save, sealed Call cannot be edited in-place; re-entry creates new Call.
- [ ] Sealed values (statement, confidence, resolve-by, timestamp) persist after app relaunch.
- [ ] Timestamp matches save time, not display time.

**Notifications:**
- [ ] Notification prompt appears after 3rd sealed Call (not 1st or 2nd).
- [ ] Prompt appears only once; if declined, does not re-show on app launch.
- [ ] Settings > Notifications is the only path to re-enable.

**Social sharing:**
- [ ] Share button opens native share sheet (X/LinkedIn options).
- [ ] Payload includes statement, confidence, resolve-by date, "via Hindsight."

**Legacy compatibility:**
- [ ] Old Decision records still readable; display linked Calls (if any).
- [ ] Wizard loads without crash if legacy Decision selected (fallback only).
- [ ] New Calls do not create Decisions; standalone Call objects only.

**Accessibility:**
- [ ] VoiceOver: Statement field has label; Confidence described as "slider 51–99%, [current]%"; ±5% buttons labeled; Resolve-by labeled as date picker.
- [ ] Slider accessible via drag and ± buttons.
- [ ] Validation messages announced to VoiceOver.
- [ ] All interactive elements tappable (min 44x44pt hit area).

#### Technical Notes
- Store Call as immutable record (SwiftData model): statement, confidence, resolve_by, timestamp (UTC).
- Notification count: increment sealed-call counter; check >= 3 on save.
- Share URL: include app deep link (e.g., `hindsight://call/[id]`).
- Backward compatibility: preserve existing Decision model; add Call model with optional Decision reference.

#### Success Criteria (Product)
- Users can capture a Call in 3 taps + typing (statement only).
- No crash on store-open, no preselected-verdict bug, no deletion bug (known blockers addressed in engineering).
- Calls appear in call list, decision detail, and insights flows with correct immutable data.
- Social receipt sharing functions; platform timestamps recorded.
- Notification prompt appears on-cadence without re-prompting on decline.
