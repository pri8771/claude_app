# Product Brainstorm: Friction, Fun, and the MVP

**Status:** Thinking document — ideas, arguments, and one recommendation. Not ratified.
**Date:** 2026-07-28

---

## The frame: the payoff is too far away

Judge every idea against one question — *does this shorten the feedback loop?*

A decision journal asks for work now and pays out in six months. That is the worst possible
reward structure for habit formation. It is why apps in this category die: not because capture is
hard, but because nothing happens after capture for half a year.

Capture friction and delayed payoff are the same problem wearing two hats. Fixing capture alone
produces a well-designed app that people still stop opening.

---

## Thread 1: Short-horizon predictions

**The argument.** Encourage predictions that resolve in days, not just months. *"Will I actually
go to the gym tomorrow?" "Will she text back today?" "Will I regret this class by midterms?"*

Why this is the highest-leverage idea available:

- **It creates a reason to open the app this week.** Long-horizon predictions cannot do that.
- **Calibration needs volume.** A Brier score is meaningless at n=3. Someone making only
  six-month calls needs *years* to learn anything. Short-horizon calls generate the data density
  that makes the insight engine work at all.
- **It teaches the skill fast.** Being wrong about tomorrow, repeatedly, is how you learn what
  your 90% actually means. That lesson then transfers to the decisions that matter.
- **It is nearly free to build.** Date presets, ordering, and a nudge. No new model.

**The risk.** It could trivialize the app — "will I go to the gym" is not a *decision*, and a
journal full of them starts to feel like a to-do list. The serious use case gets diluted.

**Resolution.** Separate them in language and surface, not in data. Calibration is calibration —
the scoring engine treats them identically. But the UI can distinguish *"decisions"* (weighty,
reflective, deserve the wizard) from *"quick calls"* (practice reps, one line, gone in seconds).
Same `Prediction` model, differentiated by horizon. The insight screen can then say something
genuinely useful: *"you're well calibrated day-to-day but overconfident about anything past three
months"* — which is true of almost everyone and is a real finding.

**Verdict: build it. Cheapest fix to the deepest problem.**

---

## Thread 2: Prediction duels

**The argument.** You and a friend both call it, both locked before either sees the other, both
revealed when it resolves.

Why it is strong:

- **It makes the feedback loop social and immediate.** You have a reason to talk about it today,
  not in six months.
- **Native to the demographic.** College friends already argue about who called it.
- **It is the growth mechanism.** Inviting a friend is inherent to the feature, not bolted on.
- **It reframes the app from homework to play.**

Why it is expensive:

- **It requires a backend, identity, and a rendezvous point.** Two people must reach the same
  record. That is the first genuine infrastructure this app has needed.
- **Cold start is two-sided.** The feature is worthless until your friend also has the app.
- **Competitive scoring invites gaming.** If duels are ranked, people pick safe predictions —
  the same failure mode as leaderboards.

**The cheap version.** Asynchronous and link-based: you seal a prediction and share a link, your
friend opens it and records their own call, both are revealed at resolution. This needs only a
tiny key-value store scoped to duels — *nothing else ever syncs*. The privacy promise becomes
"your journal stays on your device; only duels you explicitly start leave it," which is honest
and defensible.

Much of the sharing surface already exists: the Timestamped Receipt card renderer, seal/reveal
flow, and honest attestation framing are on `archive/call-pivot-complete`, built and tested.

**Verdict: strong, but not first.** Social multiplies retention for an app people already use.
It cannot manufacture retention for one they don't. Build it once solo retention is proven.

---

## Reducing friction

- **Partial capture is a first-class state.** Whatever the user says becomes an entry. Missing
  fields get filled opportunistically. **But: an unset confidence is honest; a defaulted 50% is a
  lie.** Store nil, mark incomplete, ask later — never fabricate the number the app exists to
  measure.
- **Notification with inline reply.** iOS supports text input on notifications — answer without
  opening the app.
- **"Ask me again in six months" is the right verb.** Better than "set a review date," which is
  admin. Build the app's vocabulary around it.
- **Natural timelines.** "Before finals," "when my lease is up," "by spring break." The
  demographic does not think in months.
- **Templates.** "Will I get this internship," "should I text them back," "will I like this
  major." One tap plus a confidence.
- **Batch voice.** "I've got three things" in one walk to class.
- **Ambient prompting.** Sunday evening: *"anything you're deciding this week?"* Inverts who
  initiates, which removes the hardest step — remembering the app exists.

---

## Gamification — and the trap

**The trap: if you reward being right, people only log safe predictions, and the data becomes
worthless.** Streaks on *capture* fail the same way, producing junk entries to protect a number.

Reward the honest behaviours instead:

- **Streaks on resolution, not capture.** Closing the loop is the virtuous act.
- **Badges for changing your mind**, for admitting a miss, for logging something you're only 55%
  sure about.
- **Calibration as the score** — one number that improves when confidence matches reality,
  whether you are optimistic or pessimistic.

**The fun stat:** *"You say 90%. You're right 70% of the time."* Everyone is overconfident,
nobody knows by how much, and finding out is delicious. Split by domain and it gets better —
*"well calibrated about school, catastrophically overconfident about relationships"* is a
screenshot that gets sent to a group chat unprompted.

**Year in Review.** Wrapped for your own judgment: what you believed in January, what actually
happened, best call, worst miss. Annual, shareable, and the natural viral moment.

---

## Sensitivities

**The relationship use case is emotionally loaded.** A notification six months later reading
*"you were 90% confident about [name]"* can land like a gut punch. That is also precisely why it
is the killer use case. The copy must be gentle and curious, never gloating. Get this wrong and
people delete the app on the exact day it mattered most.

**The clarity score currently punishes fast capture.** A voice-captured decision (title + one
prediction + date, no options, no notes) scores **33 → "Sketchy."** If the fast path is labelled
sloppy, the fast path feels bad. Either hide the score for quick captures, or reframe it as an
invitation ("add the alternatives you considered to strengthen this") rather than a grade.

---

## MVP recommendation

**Name the bet:** *capture in under ten seconds, get feedback within days.*

The riskiest assumption is not "can we build voice capture" — we can. It is **"will anyone use a
prediction journal habitually?"** The MVP must test that, which means it needs both halves: fast
capture *and* a fast first payoff.

### In scope

1. **Quick Capture** — one sheet: statement, confidence, "ask me again when." Writes a `Decision`
   plus one `Prediction` using the **existing model, no schema change** (verified: all views
   handle empty options/predictions safely). The wizard survives as the *deepen-it-later* path,
   not the front door.
2. **Voice into Quick Capture** — on-device transcription and parsing, with a confirmation screen.
   Never save a parse silently; the user sees and corrects it.
3. **Short-horizon defaults** — "tomorrow / this week / this month / 6 months," short options
   first, and a nudge toward at least one short call in the first session.
4. **Fast resolve ritual** — a card stack for everything due. This is the payoff moment; it should
   feel good and take seconds. (A working implementation exists on the archive branch.)
5. **The overconfidence stat** — "you say 90%, you're right 70%." Appears early, gets more
   interesting with volume.
6. **Clarity score reframe** — invitation, not grade.

### Out of scope

- Duels and all social (multiplier, not foundation — build after solo retention is proven)
- Email and any external data source
- Year in Review (needs a year of data)
- Badges and streaks (add once the loop works; premature gamification decorates a broken loop)

### Sequencing

**Step 1 — in-app voice capture.** Big mic button on Today. Proves the whole
record → transcribe → parse → confirm pipeline where it is observable and testable. This is a
build milestone, not a shippable product.

**Step 2 — hands-free.** App Group, Siri App Intent, widget/Control Center/Action Button entry.
This is what delivers the actual thesis: AirPods in, walking to class, app never opens.

Step 1 first because building Siri first means debugging speech routing and language parsing
simultaneously, with the most invisible failure mode in the stack.

### Success metric

Not captures. **Resolutions.** Specifically: *what fraction of users resolve at least one
prediction within 14 days of installing?* Capture measures curiosity; resolution measures whether
the loop actually closed. If that number is low, no amount of gamification or social will save it
— and it is far better to learn that from an MVP than after building a backend.
