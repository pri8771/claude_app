# Hindsight — Adult Decision Observatory Product Contract

**Release candidate:** `1.0 (4)`
**Lifecycle:** `verification_pending`
**Owner:** Codex production execution
**Supersedes visually:** Future Postcards v3 presentation language
**Preserves behaviorally:** the accepted private capture → wait → resolve → learn loop and all data-safety contracts

## Product promise

Hindsight records what a person believed before the outcome was known, then shows whether their
confidence matches reality. It is a private instrument for improving judgment—not a prediction
market, diary skin, habit game, or public performance feed.

The primary question every release must answer is:

> When I say I am X% confident, what actually happens—and where is my judgment becoming sharper?

## Initial audience

Thoughtful adults roughly 28–50 who make recurring consequential calls: founders, operators,
researchers, investors, physicians, attorneys, creatives, and serious knowledge workers. The UI
assumes competence, respects emotional sensitivity, and explains statistical limits without
talking down to the person.

## Production information architecture

1. **Today** — records ready to resolve, upcoming records, one useful personal signal, and the
   fastest route to capture.
2. **History** — a searchable chronological evidence ledger containing the original forecast and
   later outcome.
3. **Capture** — a center action, not a persistent destination. Required: statement, intentional
   0–100 confidence, future date. Optional: Why. Save is one local transaction.
4. **Insights** — confidence calibration is the first and dominant analysis; reflection/process
   measures remain secondary and are never presented as forecast accuracy.
5. **Settings** — privacy, reminders, example data, export, appearance, recovery, and deletion.

Every account, network, and social surface remains hidden or truthfully unavailable while the
Social v2 authority, identity, hosted integrity, privacy, and operational gates are incomplete.

## Visual system

The selected direction is **Editorial Observatory with Quiet Instrument analytics**.

- Warm-neutral light mode and graphite dark mode use semantic dynamic colors.
- Authored forecast text may use a restrained editorial serif; controls and data use SF Pro.
- Tabular numerals are mandatory for confidence, dates, denominators, and comparisons.
- Hierarchy comes from type, alignment, whitespace, and fine rules—not stacked rounded cards.
- Oxblood identifies consequential attention; steel identifies interaction/reference; forest
  identifies outcomes meeting or exceeding expectation. Color is never the only carrier.
- Surfaces use small radii, no decorative gradients, no hard offset shadows, no stamps, envelopes,
  handwriting, tilted labels, confetti, streak-game badges, or motivational hero copy.
- Dynamic Type, VoiceOver, Increase Contrast, Reduce Motion, keyboard presence, long text, and the
  smallest supported iPhone are first-class layouts.

## Core interaction contract

### Capture

- The sheet focuses the statement immediately.
- Confidence has no stored default; a visible neutral thumb must not count as selection.
- Why is collapsed/optional by default and never blocks saving.
- Date presets and a custom date are available on the same screen.
- After typing, capture requires at most two meaningful decisions: confidence and date. Lock is the
  explicit commit action.
- Interruption, dismissal, persistence failure, and relaunch retain the draft unless the person
  explicitly discards it.
- Duplicate taps and retries create at most one record. No haptic, reminder, dismissal, or success
  state occurs before persistence succeeds.
- Detailed confidence is explicit when selected, and an optional rating is distinguished from an
  absent rating; neither is inferred from a neutral control state.

### Resolution

- Resolution asks whether the forecasted event **happened**, **did not happen**, or **could not be
  judged**. It never labels a low-probability event that did not happen as an “incorrect call.”
- Nothing is preselected. Optional reflection remains recoverable after failure.
- Original statement, confidence, Why, creation time, and review date are visually and
  behaviorally immutable.
- Fast resolution commits a coherent terminal result, while notes remain durable through retry and
  interruption.

### Analytics

- Strict calibration uses real, due, terminal binary forecasts only: happened = 1 and did not
  happen = 0. Pending, sample, partial/ambiguous, cancelled, and unresolvable records are excluded
  and their exclusion counts remain visible.
- Due-date eligibility is evaluated consistently with the local calendar/time-zone boundary.
- Every statistic includes its denominator, window, and eligibility rule.
- Confidence bands have deterministic boundaries and ordering. Sparse bands show “not enough
  resolved forecasts,” not a trait claim.
- The engine reports observed rate, mean stated confidence, signed calibration gap, and Brier
  score. Lower Brier is better; it is never called hit rate.
- Category, horizon, and with/without-Why comparisons require sufficient samples in both cohorts.
- Copy describes evidence: “In 13 resolved 80%+ forecasts…” rather than identity judgments such as
  “You are bad at forecasting.”

## Data and trust boundary

- SwiftData remains authoritative for personal records in this release.
- Stable explicit sample identity is filtered at the selector layer, not merely hidden in views.
- Samples never affect personal counts, analytics, reminders, notifications, exports, or social
  relationships.
- Reminder scheduling is sample-safe; deletion and new-decision retries are transaction-safe and
  do not make a success claim before the authoritative local write succeeds.
- Clear-all and recovery reset must clear SwiftData, durable drafts, and local notifications only
  after the relevant operation succeeds.
- Export is versioned, uses stable IDs, and reflects the actual data set disclosed to the person.
- No prediction text, Why, reflection, identity, or analytics content is sent remotely in the
  personal release.

## Release exit

The personal release is eligible for promotion only when automated unit/integration/UI smoke,
file-backed persistence/relaunch, Release build, sample isolation, export/deletion, accessibility,
notification/device, and App Store disclosure evidence exist. `code_complete` is not `done`.
