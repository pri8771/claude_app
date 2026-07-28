# Plan: Siri, Widgets, and Voice Capture

**Status:** Draft for review — not ratified, not started
**Target architecture:** Decision / Prediction / OutcomeReview (post-revert, `dev` @ 6edc85f)
**Date:** 2026-07-28

---

## The one fact that shapes everything

Widgets and Siri intents **run in separate processes** from the app. They cannot read the
app's SwiftData store as it exists today, because it lives in the app's private container.

Everything below therefore depends on one prerequisite: moving the store into an **App Group**
shared container. This is a data migration on real user data and carries the same risk profile
as any store move — it must be backup-first and reversible.

There is no way to build a data-driven widget or a "log a decision with Siri" intent without it.
(A launch-only widget that just deep-links into the app is the sole exception, and it is not
worth shipping alone.)

---

## Phase A — App Group + shared store (prerequisite, no visible feature)

**Goal:** app, widget, and intents all read/write one store.

1. Add App Group capability (`group.com.hindsight.pchordia.app`) to the app target.
2. Change `StoreBootstrap` to resolve the store URL from the App Group container instead of
   Application Support — SwiftData supports this via `ModelConfiguration(groupContainer:)`.
3. **Migration:** on first launch after the change, if a store exists at the old path and none
   exists in the group container, copy it across, validate the row counts match, and only then
   switch over. Keep the old file untouched until validated. This mirrors the backup-first
   pattern already proven in the Call migration work (recoverable, idempotent, verifiable).
4. Add a regression test that the migration is idempotent and preserves every Decision,
   Prediction, and OutcomeReview.

**Risk:** medium-high (touches real user data). **Mitigation:** backup-first, validate-then-swap.
**User-visible outcome:** none. This is pure plumbing.

**⚠️ Account check needed:** App Groups and extension provisioning generally require a paid
Apple Developer Program membership. Current builds are dev-signed with a personal team. Confirm
membership status before committing to this phase — it gates all three features.

---

## Phase B — Widgets (WidgetKit)

Do this first among the visible features: widgets are **read-only**, so they cannot corrupt data,
and they prove the shared store works before anything writes through it.

**Widgets worth building, in value order:**

| Widget | Sizes | Content |
|---|---|---|
| **Due for review** | small, medium, Lock Screen rectangular | Count of decisions past `dueDate`, plus the next one's title. Taps deep-link straight to that decision's review. |
| **Review rate** | small, Lock Screen circular | The `Statistics.reviewRate` number — the honest "are you actually closing the loop" metric. |
| **Quick capture** | small, Lock Screen | Single button → deep-links into the wizard. Cheap, high daily utility. |

**Implementation notes:**
- New Widget Extension target; shares the models + `Statistics` via a shared framework or by
  adding the files to both targets.
- Timeline policy: refresh at the next `dueDate` boundary rather than on a fixed interval —
  a review-due widget that lags by hours is worse than useless.
- App calls `WidgetCenter.shared.reloadAllTimelines()` after any save that changes due counts.
- Widgets must render correctly with **zero decisions** (new user) — design the empty state.

**Risk:** low. **Effort:** moderate — the extension target and timeline logic are the bulk.

---

## Phase C — Siri via App Intents

Use the modern **App Intents** framework (iOS 16+), not legacy SiriKit. It gives Siri, Shortcuts,
Spotlight, and the Action button from one implementation.

**Intents to expose:**

1. **`LogDecisionIntent`** — *"Log a decision in Hindsight"*
   Captures title (and optionally category/stakes) and creates a **draft** decision.
2. **`ReviewDueDecisionsIntent`** — *"What decisions do I need to review?"*
   Read-only; speaks the count and the next title back.
3. **`OpenDecisionIntent`** — deep link by title, for Shortcuts automation.

**Honest design constraint:** the capture flow is a 4-step wizard (basic info → options →
predictions → review date). That does **not** compress into a voice turn — asking someone to
dictate weighted options and probability percentages to Siri is a bad experience.

So the intent should capture the *title and notes only*, save it as an incomplete draft, and
surface it in-app as "finish this decision." Voice is the **inbox**, not the whole wizard. A
decision captured at a red light gets completed properly later, which is also better for
decision quality.

Expose zero-setup phrases through `AppShortcutsProvider` so no Shortcuts setup is required.

**Risk:** medium — it writes to the store from another process. **Effort:** moderate.

---

## Phase D — Voice capture

Two genuinely different things are bundled under "voice." Separating them matters:

**D1 — Dictation into text fields (nearly free)**
The system keyboard's mic button already dictates into any `TextField`. Cost is essentially
zero: confirm the wizard's fields don't fight it and that dictation works in the notes field.
Ship this immediately — it may satisfy most of the actual need.

**D2 — Record-and-transcribe capture (real work)**
Speak a decision freely, transcribe it, pre-fill the wizard.

**The critical constraint:** the app's core promise is 100% on-device, no backend, no tracking.
`SFSpeechRecognizer` defaults to **server-based** recognition — audio leaves the device. That
would silently break the central privacy claim. On-device recognition must be forced
(`requiresOnDeviceRecognition = true`), and the app should refuse to transcribe rather than fall
back to the network if on-device is unavailable on that device/locale.

*(iOS 26 introduced a newer on-device speech API — worth verifying current best practice against
Apple's documentation before implementing, rather than assuming `SFSpeechRecognizer` is still the
right entry point.)*

Also required: `NSMicrophoneUsageDescription` and `NSSpeechRecognitionUsageDescription`, with
copy that states plainly that audio never leaves the device.

**Open product question:** is transcribed free speech parsed into structured fields (title vs.
notes vs. options), or dumped into notes for the user to organise? Parsing is where this gets
expensive and error-prone. Recommend: dump into notes first, ship it, see if parsing is even
wanted.

**Risk:** high (privacy-sensitive + permissions + accuracy). **Effort:** highest of the four.

---

## Recommended sequence

```
A (App Group)  →  B (Widgets)  →  C (Siri intents)  →  D1 (dictation)  →  D2 (transcription)
```

D1 can jump the queue at any time — it is independent of the App Group work.

**Suggested first step:** confirm the Apple Developer Program status, then do Phase A + the
"Due for review" widget as a single vertical slice. That proves the whole shared-store
architecture end-to-end with the lowest-risk feature attached, and delivers something useful
on the Home Screen.

## Open questions for the user

1. Paid Apple Developer Program membership — active? (Gates A, B, C.)
2. Is "voice" primarily *dictation* (D1, cheap) or *speak-a-whole-decision* (D2, expensive)?
3. Which widget matters most day to day — due-for-review, review rate, or quick capture?
4. Should a Siri-captured decision be a draft to finish later (recommended), or should Siri try
   to walk the full wizard by voice?
