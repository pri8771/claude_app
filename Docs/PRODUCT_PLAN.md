# Hindsight Product Plan

Status: `proposed`  
Purpose: define the product direction before restructuring the existing app.

## Product thesis

Hindsight should become a private track record for a person's judgment, not a
long-form decision form.

The repeatable promise is:

> Make a call in seconds. Close the loop later. Learn where your confidence
> matches reality.

The current app asks users to do the work of a retrospective before they have
received any value. The redesigned product should make the smallest useful
record extremely fast, then invite deeper thinking only when it is useful.

The initial audience should be people who make frequent consequential calls and
care about improving their judgment: founders, operators, investors, product
leaders, and ambitious professionals. The experience can remain broadly
understandable, but launch messaging should be specific enough that a user
immediately recognizes the problem.

## Current product diagnosis

The problem is deeper than screen count:

- Minimum capture currently requires a title, two option titles, one prediction,
  four screens, and a summary screen before Save.
- The app mixes "help me think through an undecided choice" with "record the
  choice I already made." It requires alternatives but saves the record as
  already decided without asking what was chosen.
- Untouched defaults such as category, stakes, reversibility, 50% confidence,
  and a 30-day horizon can later look like intentional user assertions.
- The Clarity Score rewards form completion and calls sparse records "Sketchy."
  This discourages the exact quick-capture behavior the product needs.
- Review is another long form, and pending predictions currently default to
  Correct during resolution. A rushed review can therefore create false data.
- Due items open a long detail page instead of opening the fast resolution
  action directly.
- The current "prediction accuracy" is an event-occurrence average, not a
  measure of probabilistic forecast quality. Aggregate mean confidence versus
  aggregate occurrence can also hide opposite errors that cancel each other.
- Review rate currently includes active and future decisions in its denominator
  rather than only records that were actually due.

## Product principles

1. **Capture first, enrich later.** A useful call should take under 10 seconds
   after the user has typed or dictated the statement.
2. **Reward closed loops, not busywork.** The important behavior is resolving a
   call, not filling in every field or maintaining a logging streak.
3. **Show evidence, not personality judgments.** Every insight needs a sample
   count, an uncertainty state, and drill-through to the records behind it.
4. **Private by default, share by choice.** Social output is generated only
   after an explicit action and can be redacted before leaving the device.
5. **Progressive disclosure everywhere.** Alternatives, rationale, stakes,
   category, notes, and lessons are valuable enrichment, never capture gates.
6. **Preserve the receipt.** The original statement, confidence, timestamp, and
   resolution rule should be visibly immutable after a call is sealed.

## Core product model

Use a single user-facing object called a **Call**. A call can represent a
prediction, a choice, or an expectation attached to a decision.

Examples:

- "Shipping onboarding this week will improve activation."
- "I will still be glad I took the Northwind role in three months."
- "This project will finish before September."

The existing `Decision` and `Prediction` models can support an incremental
migration, but the UX should not force users to understand that hierarchy.

### Minimum useful capture contract

Required:

- A falsifiable statement: "What do you think will happen?"
- Confidence: a probability from 1–99%.
- Resolution date: "When will you know?"

Defaults:

- Remember the user's most common confidence and horizon choices.
- Offer one-tap horizons: tonight, one week, one month, three months, custom.
- Start with sensible confidence chips such as 55%, 65%, 75%, 85%, and 95%;
  keep a fully adjustable accessible control for other values.

Optional "Add context":

- Choice made or options considered.
- Reasoning / assumptions.
- Category and stakes.
- Reversibility.
- Success criteria.
- Private note.

### Target capture experience

One focused sheet:

1. Autofocus the statement field and support dictation.
2. Choose confidence with one tap.
3. Choose a resolution horizon with one tap.
4. Tap **Seal Call**.

If defaults are acceptable, the user types one sentence and taps once. Saving
must keep the sheet open and preserve the draft if persistence fails.

After save, show a lightweight receipt and two non-blocking choices:

- Done.
- Add why / options.

Do not request notification permission until the first successful call has been
saved and the reminder benefit is concrete.

## Review loop

The default resolution flow should also take seconds:

1. "Did it happen?" — Yes / Partly / No / Can't resolve.
2. Optional one-line note: "What did you miss?"
3. Save.

Longer reflection remains available as **Add a retrospective**, including
process quality, outcome quality, surprise, lesson, and whether the user would
repeat the choice.

Strict calibration should use binary Yes/No results. "Partly" should either be
shown separately or use a documented fractional score while being excluded
from claims that imply a binary hit rate. "Can't resolve" must never count as a
miss.

## Information architecture

### Today

- A dominant **Make a Call** action.
- Calls due for resolution, optimized for rapid one-by-one completion.
- One timely insight or learning-state card.
- Recent open calls.

### Calls

- Searchable history with Open, Due, Resolved, and Saved filters.
- Compact rows emphasizing statement, confidence, and resolution date.
- Tap through to the immutable receipt, context, and outcome.

### Insights

- A strong top-level calibration story rather than a stack of generic totals.
- Confidence bands, trends, blind spots, and drill-through.
- Clear learning states before enough data exists.

### Profile / Settings

- Privacy controls, reminder content, appearance, export, demo management, and
  deletion.
- Move low-frequency settings out of the primary product journey.

Three main tabs are sufficient: **Today**, **Calls**, and **Insights**. Settings
can live behind a profile button.

## Insights system

### 1. Confidence calibration

Group resolved binary calls into bands:

- 50–59%
- 60–69%
- 70–79%
- 80–89%
- 90–99%

For each band calculate:

- Number resolved.
- Mean stated probability.
- Observed success rate.
- Calibration gap: observed minus stated probability.
- An uncertainty interval.

Example card:

> **High confidence is your blind spot**  
> When you were 80–89% confident, the outcome happened 46% of the time
> (6 of 13). That is 37 points below your stated confidence.

The card drills into those 13 calls. Copy must say "early signal" when the
sample is limited and must not describe a stable personal trait prematurely.

### 2. Calibration curve

Show stated confidence on the horizontal axis and observed frequency on the
vertical axis. Include:

- A perfect-calibration diagonal.
- Actual band points sized by sample count.
- An uncertainty range.
- Plain-language explanation underneath.

### 3. Overall scoring

- **Calibration gap:** weighted average absolute difference between stated and
  observed rates.
- **Brier score:** mean squared probability error, translated into plain
  language and never shown without explanation.
- **Decisiveness:** how often the user moves meaningfully away from 50%.
- **Surprise rate:** misses on calls at or above 80% confidence.
- **Resolution rate:** resolvable calls closed on time.

### 4. Contextual patterns

Only when both comparison groups have enough data:

- Calibration by category.
- Calibration by time horizon.
- High-stakes versus low-stakes calls.
- Reversible versus irreversible decisions.
- Process quality versus outcome quality.
- Confidence and accuracy trend over time.

Every claim needs a sample count and drill-through. Demo calls must be visually
labelled and excluded from personal calculations.

### Sample rules

- Fewer than 5 relevant resolutions: learning state; no numeric conclusion.
- 5–9: show numbers as an **early signal**, with cautious copy.
- 10–19: show a directional insight.
- 20 or more: allow stronger trend language.
- Comparisons require at least 8 records in each cohort.

These thresholds are product defaults and should be validated with statistical
fixtures and user research before release.

## Social and viral strategy

The social object should be a **Receipt**, not a public diary or generic feed.

### MVP: shareable sealed-call cards

Generate a polished image locally containing only fields the user selects:

- The call.
- Confidence.
- Sealed timestamp.
- Resolution date.
- Optional category or pseudonym.
- Hindsight branding and an App Store/deep-link call to action.

Before sharing, provide visibility choices:

- Full statement.
- Redacted statement with category only.
- Calibration statistic only.

When the call resolves, generate an **Outcome Receipt** that places the original
confidence beside what happened. This produces a natural two-part loop:

`make a call → share the sealed receipt → resolve it → share the outcome receipt`

The artifact has user value—accountability and credibility—while each explicit
share introduces the product to another person. It works with the current
local-first/no-backend constraint.

### Strongest network loop: Blind Call & Reveal

A user locks a share-safe binary call and confidence before inviting one friend.
The friend responds independently before seeing the sender's answer, preventing
anchoring. When reality resolves the call, both see a side-by-side reveal and
can share the receipt or start another call.

The ideal invitation opens instantly on the web without an account or install
wall. That is a real network loop:

`lock → invite → friend answers → reveal → friend starts a call`

A static payload and app deep link can test a limited version locally. A
no-login web response, reliable cross-device state, expiration/revocation, and
notifications require a backend and a revised privacy architecture.

Only a separately authored and approved social prompt should leave the device;
never populate it automatically from private notes or decision titles.

### Later: private circles

Small invite-only groups could make sealed calls, reveal forecasts after a
deadline, and maintain private calibration leaderboards. This should be tested
only after the solo capture/review loop retains users.

Private circles require networked storage, identity, abuse controls, consent,
and a new privacy model. The repository currently sets `backendAllowed` to
`false`; that constraint must be explicitly changed before implementation.

### Social features to avoid initially

- A public feed of personal decisions.
- Global leaderboards without comparable question sets.
- Contact uploads.
- Automatic sharing.
- Anonymous aggregate claims before there is a trustworthy dataset.
- Engagement mechanics that reward making low-quality calls.

## Competitive reality

Fast private capture and a calibration curve are necessary but are not, by
themselves, a differentiated product. Current App Store products already
advertise:

- Local decision logging, confidence, outcome review, calibration curves, Brier
  scores, and domain breakdowns.
- One-tap offline forecast capture with confidence bands.
- Daily social predictions, browser play, friend challenges, groups,
  leaderboards, and shareable result cards.

Hindsight should therefore avoid positioning itself as merely another decision
journal or forecast tracker. Its potential wedge is the combination of:

1. The fastest private capture.
2. Evidence-backed personal confidence calibration.
3. A tasteful sealed-receipt and blind-reveal social language.
4. Deep optional reflection for decisions that deserve it.

The visual and verbal identity should emphasize honest self-knowledge rather
than generic productivity, gambling, trivia, or public prediction bravado.

## UI and interaction direction

The current dark visual system is coherent but card-heavy and visually similar
to many productivity dashboards. The redesign should feel like a crisp
instrument for judgment:

- Use fewer nested cards and more whitespace-led hierarchy.
- Reserve the red accent for the primary action, due work, and meaningful
  variance—not general decoration.
- Make the calibration visualization the visual signature of the product.
- Show denominators beside percentages: "6 of 13", never "46%" alone.
- Use restrained motion for sealing a call, revealing an outcome, and updating
  the calibration curve.
- Support system light/dark appearance rather than forcing dark mode.
- Make every custom control fully operable with VoiceOver, Switch Control,
  keyboard input, and large Dynamic Type.
- Design small-phone and keyboard-present layouts first.
- Replace the four-page onboarding with a short value screen followed directly
  by an interactive first call. Keep privacy visible without making it a page
  the user must advance through.

## Roadmap

### Phase 0 — Product contract

- Approve the Call definition and minimum fields.
- Decide how existing Decisions and Predictions migrate.
- Define binary, partial, and unresolvable outcome semantics.
- Choose the initial audience and launch positioning.
- Record the backend constraint decision for future social work.

### Phase 1 — Make the loop usable

- Add automated unit, persistence, and UI-smoke targets.
- Fix persistence error handling and demo-data identity.
- Replace the mandatory wizard with quick capture plus optional enrichment.
- Add rapid resolution.
- Preserve drafts across dismissal/interruption.
- Make capture and review accessible.

### Phase 2 — Deliver the reason to return

- Implement tested calibration bands and sample rules.
- Add the calibration curve, surprise rate, and drill-through.
- Surface one useful insight on Today.
- Reconcile reminders on launch and provide generic notification previews.

### Phase 3 — Build the distribution loop

- Add local sealed-call and outcome-receipt cards.
- Add redaction and preview controls.
- Add deep-link/app-install calls to action.
- Test friend challenges without accounts.

### Phase 4 — Validate networked social

- Measure whether users want shared calls or private groups.
- If evidence supports it, approve a backend/privacy architecture.
- Prototype private circles with explicit consent and tight visibility.

## Success metrics

Primary:

- Median time to seal a call.
- Calls resolved per weekly active user.
- Percentage of new users who seal a first call during the first session.
- Percentage who resolve at least one call within the first two weeks.

Targets to validate:

- First call reachable immediately after the opening value screen.
- Median post-typing capture interaction under 10 seconds.
- At least three calls and one resolution in a new user's first two weeks.

Growth:

- Percentage of resolved users who create a share card.
- Shares per sharing user.
- Recipient-to-install and recipient-to-first-call conversion once attribution
  can be implemented without weakening privacy.

Guardrails:

- Notification opt-out rate.
- Unresolved-call backlog.
- Draft-loss and persistence-failure rate.
- Percentage of insight cards with sufficient sample evidence.
- Privacy complaints or accidental oversharing reports.

## Decisions needed before implementation

1. Is the public product noun **Call**, **Prediction**, **Bet**, or **Decision**?
   "Call" is the current recommendation.
2. Is the first launch audience founders/operators/investors, or a broader
   personal-growth audience?
3. Are partial outcomes excluded from strict calibration or scored
   fractionally?
4. Should the first social release be limited to local share cards?
5. What evidence would justify changing the no-backend constraint?
