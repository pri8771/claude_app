# Plan: Voice-First Capture (Siri, Widgets, Natural Language)

**Status:** Draft for review — not ratified, not started
**Target architecture:** Decision / Prediction / OutcomeReview (post-revert, `dev`)
**Date:** 2026-07-28

---

## The reframing

The original framing treated voice as a *convenience* on top of the wizard. That was wrong.

The actual problem: **capture costs too many taps for anyone to use this habitually.** A decision
journal only works if capture is nearly free at the moment of thinking. A 4-step wizard is a
reflection tool, not a capture tool — and reflection-grade friction at capture time means the
journal stays empty.

So voice is not a feature. Voice is *the* capture path, and the wizard becomes what you use to
deepen an entry later.

**Target utterance:**

> "Hey Siri, I'm thinking of quitting my job, I think it will make me happy, remind me in 6 months"

**Target decomposition:**

| Field | Value | Source |
|---|---|---|
| `Decision.title` | "Quitting my job" | parsed |
| `Prediction.title` | "It will make me happy" | parsed |
| `Decision.dueDate` | now + 6 months | parsed |
| `Decision.category` | `.career` | inferred |
| `Decision.stakesLevel` | `.high` | inferred |
| `Prediction.probabilityPercent` | **⚠️ unstated** | see below |

This maps cleanly onto the existing model. No schema change is required for the core case.

---

## The one thing the utterance does not contain

`probabilityPercent` is load-bearing — calibration is the entire point of the app. "I think it
will make me happy" carries no number.

Three options, and only one is acceptable:

- ❌ **Default to 50% (or anything).** Fabricating a confidence number silently poisons the
  calibration data the app exists to produce. Never do this.
- ❌ **Leave it unset and hope the user fills it in later.** They won't. That is the friction we
  are removing.
- ✅ **One Siri follow-up turn.** *"How confident are you that it'll make you happy?"* Accept
  either a number ("seventy percent") or a qualitative answer ("pretty confident") mapped to a
  band. One extra turn is a fair price; a fake number is not.

**Design rule:** the app may infer category and stakes (cosmetic, correctable). It must never
infer confidence (load-bearing, corrupting).

---

## How the parsing actually works

This is the critical technical decision.

**Recommended: Apple's on-device Foundation Models framework (iOS 26).** It exposes the
on-device LLM to apps with structured/guided generation — you define a result type and the model
fills it. That is precisely this problem, and it runs entirely on-device: no network, no backend,
no change to the privacy promise.

- Pair it with `NSDataDetector` to independently parse and validate the date phrase ("in 6
  months"), since date handling is where LLM output most often needs a deterministic check.
- **Device requirement:** the on-device model needs Apple Intelligence-capable hardware.
  Your iPhone 16 Pro Max qualifies; older devices do not. A graceful fallback is required —
  likely "transcribe into the notes field, open the wizard pre-filled."

*⚠️ Verification needed before implementation: the Foundation Models framework post-dates my
training data. I know the capability exists and that this is its intended use case, but I should
confirm the current API surface, availability checks, and structured-output syntax against
Apple's documentation rather than writing it from memory.*

**Explicitly rejected: any cloud LLM.** The app's core claim is that nothing leaves the device.
Sending decision text — some of the most private content a person has — to a server would break
that promise. Not a tradeoff worth making.

**Also insufficient on its own: App Intents parameter resolution.** It handles structured phrases
matching a defined shape; it will not reliably decompose free-form speech like the target
utterance. Useful as the *entry point*, not as the parser.

---

## The widget microphone button — a platform constraint

**Widgets cannot record audio.** Microphone access is not available to widget extensions. A
widget button can only run an App Intent or launch the app.

So the mic button works like this: tap → app launches directly into recording state → speak →
parse → confirm. Still a one-tap capture, but the app does come to the foreground. There is no
way around this, and any plan promising in-widget recording is wrong.

Worth considering alongside the widget:

- **Control Center control (iOS 18+)** — arguably a better home for "start capture" than a
  Home Screen widget; reachable from anywhere.
- **Action Button** (Pro devices) — one physical press to capture. Strong fit for this app.
- **Lock Screen widget** — capture without unlocking.

---

## Two capture paths, and which to build first

| Path | Pro | Con |
|---|---|---|
| **Siri** ("Hey Siri, I'm thinking of…") | Hands-free, app never opens | Depends on Siri routing the phrase correctly; hardest to debug; failure is invisible to you |
| **Mic button** (widget / Control / Action Button) | One tap, full control over recording and confirmation UI, testable | Requires app foreground |

**Recommendation: build the mic-button path first.** It exercises the same recording →
transcription → parsing → confirmation pipeline, but you control every step and can actually
test it. Once parsing is proven, wrapping it in an App Intent for Siri is comparatively small.

Building Siri first means debugging speech routing and NL parsing simultaneously, with the
hardest-to-observe failure mode.

---

## Phasing

**Phase A — App Group + shared store** *(prerequisite, no visible feature)*
Widgets and intents run in separate processes and cannot read the app's current private store.
Move it to an App Group container, backup-first, validate-then-swap, with an idempotency test.
✅ Unblocked — paid developer account confirmed.

**Phase B — Voice capture in-app** *(the core bet)*
Record → on-device transcribe → parse to a draft Decision + Prediction → **confirmation screen**
(never save silently; the user must see and correct the parse) → one follow-up for confidence.

**Phase C — Entry points**
Mic button as a widget, Control Center control, and Action Button target. Plus the read-only
"due for review" widget, which is cheap once Phase A exists.

**Phase D — Siri App Intent**
Wrap the proven Phase B pipeline in an App Intent with `AppShortcutsProvider` phrases.

**Phase E — Dictation polish** *(can jump the queue anytime)*
The keyboard mic already dictates into any text field. Nearly free; verify it works well in the
wizard's notes field. May satisfy part of the need immediately.

---

## Future: parsing decisions out of email

Recorded as a real idea, with a hard platform constraint stated up front.

**iOS gives third-party apps no read access to Mail.** There is no API for scanning the user's
inbox on-device. The options are:

- ❌ **Gmail/IMAP integration** — means credentials, network calls, and someone's entire inbox
  flowing through the app. Categorically incompatible with the privacy promise.
- ✅ **Share Sheet extension** — the user shares a specific email (or any text) into Hindsight,
  which parses it into a draft decision using the same Phase B pipeline. User-initiated,
  scoped to one item, nothing leaves the device.
- ✅ **Proactive prompting from data already in the app** — "you decided this 6 months ago and
  never reviewed it" is a strong nudge that needs no new data source at all.

**Recommendation:** the Share Sheet version captures most of the value at a fraction of the cost
and risk, and reuses Phase B entirely. The inbox-scanning version should stay off the table
unless the privacy positioning changes deliberately.

---

## Open questions

1. Confidence follow-up: accept qualitative answers ("pretty confident") mapped to bands, or
   require a number?
2. Confirmation screen after parsing — full edit, or accept/reject with edit-in-app-later?
3. Fallback behaviour on non-Apple-Intelligence devices: transcribe-to-notes, or hide voice
   capture entirely?
4. Should voice capture create a *complete* decision, or an explicitly-marked draft that the
   wizard later deepens?
