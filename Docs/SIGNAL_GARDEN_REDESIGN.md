# Hindsight — Signal Garden production redesign contract

**Status:** approved design direction; implementation pending
**Design north star:** `Docs/design/signal-garden-concept-v1.png`
**Product scope:** private, personal-first decision calibration
**Implementation boundary:** presentation and interaction reset; preserve existing local data,
truthful analytics, draft recovery, atomic persistence, sample isolation, and fail-closed social
behavior

## 1. Product outcome

Hindsight should feel like a living instrument for understanding personal judgment: bright,
curious, visual, and rewarding to revisit. It must not feel like a beige journal, enterprise
dashboard, prediction market, casino, children’s game, or public scorecard.

The core promise is:

> Record what you believe before the outcome is known. Return later. See whether your confidence
> matches reality—and where your judgment is becoming sharper.

The redesign is successful when a new person can understand that promise within five seconds,
record a valid forecast in one focused screen, and see why accumulating honest resolutions will
produce personally meaningful Insights.

“Signal Garden” is an internal visual metaphor, not a required user-facing product name. Signals
appear as dots, arcs, bands, small blooms, and connected observations. The interface may feel alive;
it must not use literal cartoon flowers, mascots, collectible plants, or gardening copy.

## 2. Audience and jobs to be done

### Primary audience

Curious adults approximately 25–50 who make recurring uncertain calls and want to improve how they
think: founders, operators, managers, researchers, investors, clinicians, attorneys, creatives,
and reflective knowledge workers. They are comfortable with percentages but should not need to
understand forecasting jargon or statistics before receiving value.

### Secondary audience

- Quantified-self and personal-growth users who want evidence rather than motivational streaks.
- People making everyday personal forecasts about habits, work, relationships, plans, and goals.
- Teams or social users in the future, but only after the personal habit is independently valuable.

### Functional jobs

1. **Capture:** “When I notice an uncertain belief, let me record it before I know the answer.”
2. **Commit:** “Let me state confidence precisely without the app choosing a value for me.”
3. **Return:** “Bring the record back when the evidence should exist.”
4. **Resolve:** “Let me record what happened without rewriting my original belief or being shamed.”
5. **Learn:** “Show whether my stated confidence matches outcomes, with enough context to trust it.”
6. **Spot patterns:** “Help me find where, when, and under what conditions my judgment differs.”
7. **Control data:** “Keep this personal, recover my unfinished work, and let me export or erase it.”

### Emotional jobs

- Replace anxiety about being wrong with curiosity about evidence.
- Make honest resolution feel satisfying even when the event did not happen.
- Create a sense of progress from better records and better calibration, not points or streaks.
- Make private analytical data feel beautiful enough that people want to return.
- Earn trust by showing denominators, exclusions, uncertainty, and local-only behavior plainly.

## 3. North-star interpretation

### Keep from the concept image

- Luminous lilac-white backgrounds instead of paper/beige.
- Saturated violet as the recognizable Hindsight action color.
- A multicolor 0–100 confidence instrument with a large numeric readout.
- Circular icon containers and one visually distinctive center Capture action.
- Deep indigo “night garden” surfaces for the most important calibration stories.
- Bright aqua, coral, lime, and amber accents used as functional signal colors.
- Spacious cards, soft depth, friendly charts, and restrained moments of celebration.
- The five-part shell: Today, History, center Capture, Insights, Settings.

### Change from the concept image

- Remove the flame/streak counter. Daily streaks reward app opening, not honest forecasting.
- Do not use handwriting or script for functional text. A wordmark may be decorative only.
- Replace “Nice calibration!” and “You’re right 43% of the time” with evidence-first language that
  always includes eligibility and sample size.
- Do not celebrate only “correct” outcomes. Celebrate completion of an honest review.
- Use abstract constellations, signal dots, arcs, and aurora light—not juvenile character art.
- Avoid rainbow decoration on every surface. Color should establish hierarchy and meaning.
- Preserve adult information density: playful hero moments, calm lists, exact numbers.

## 4. Design principles

1. **Insight is the reward.** The most delightful surface is a truthful personal finding, not a
   badge, streak, or animation.
2. **One belief, one screen.** Quick Capture never becomes a wizard. Required input is statement,
   intentional confidence, and future date; Why is optional.
3. **Color has a job.** Violet means action/selection; aqua means reference/evidence; lime means
   event happened; coral means event did not happen or needs attention; amber means caution/sample.
4. **Truth before praise.** Every analytical claim exposes denominator, date window, eligibility,
   and exclusions. Sparse data gets encouragement to collect evidence, not a conclusion.
5. **Resolve without shame.** “Happened,” “didn’t happen,” and “couldn’t judge” describe the event.
   The product does not label the person right, wrong, smart, or bad.
6. **Personal first.** No empty social tab, synthetic activity, leaderboard, or account prompt.
7. **Progressive depth.** The first view answers “what matters now?”; detail and methodology remain
   one tap away.
8. **Delight follows truth.** Persistence succeeds before bloom, haptic, dismissal, notification,
   or success copy.
9. **Accessible by construction.** Text, shape, icon, and order carry every meaning without color.
10. **Native and fast.** Use SwiftUI, SF Symbols, and system fonts; introduce no third-party runtime
    dependency for presentation.

## 5. Visual token specification

All colors are semantic tokens. Never place raw hex values in feature views. Test actual rendered
combinations; the hex values are starting specifications, not a substitute for contrast evidence.

### Light appearance

| Token | Hex | Role |
|---|---|---|
| `canvas` | `#F8F7FF` | Main lilac-white app background |
| `canvasGlow` | `#F0EBFF` | Sparse top/hero radial glow; never behind long text |
| `surface` | `#FFFFFF` | Cards, sheets, tab bar |
| `surfaceTinted` | `#F2F0FF` | Selected rows, secondary callouts |
| `surfaceStrong` | `#E9E5FF` | Pressed/selected controls |
| `ink` | `#17152F` | Primary text and dark icons |
| `inkSecondary` | `#625E79` | Supporting copy |
| `inkTertiary` | `#817D96` | Noncritical metadata only |
| `border` | `#DED9F0` | Card and field boundaries |
| `borderStrong` | `#AAA1CF` | Focus, selected outline, chart axes |
| `violet` | `#5B3FF2` | Primary actions, selected navigation |
| `violetPressed` | `#4427D8` | Pressed primary action |
| `violetSoft` | `#E8E2FF` | Violet chip/card background |
| `aqua` | `#20AAA9` | Evidence/reference data |
| `aquaSoft` | `#DDF7F5` | Evidence card background |
| `lime` | `#65A92E` | Happened/positive event outcome |
| `limeSoft` | `#EAF7DC` | Happened outcome background |
| `coral` | `#E84F62` | Didn’t-happen outcome, overdue attention |
| `coralSoft` | `#FFE5E9` | Coral background |
| `amber` | `#B97900` | Sample, caution, insufficient evidence |
| `amberSoft` | `#FFF2CF` | Caution/sample background |
| `night` | `#111B58` | Calibration hero and report surfaces |
| `nightElevated` | `#1A286E` | Nested night card/plot |
| `onNight` | `#FAFAFF` | Primary text on night surfaces |
| `onNightMuted` | `#C9D1FF` | Secondary text/grid on night surfaces |
| `destructive` | `#C9364D` | Irreversible action only |

### Dark appearance

| Token | Hex | Role |
|---|---|---|
| `canvas` | `#090B18` | Main background |
| `canvasGlow` | `#17133A` | Sparse violet ambient glow |
| `surface` | `#15182A` | Cards, sheets, tab bar |
| `surfaceTinted` | `#202443` | Selected rows and callouts |
| `surfaceStrong` | `#2B3056` | Pressed/selected controls |
| `ink` | `#F7F6FF` | Primary text |
| `inkSecondary` | `#C2BED6` | Supporting copy |
| `inkTertiary` | `#9A96B0` | Noncritical metadata |
| `border` | `#343856` | Card and field boundaries |
| `borderStrong` | `#7770A5` | Focus and selected outline |
| `violet` | `#907AFF` | Primary actions and navigation |
| `violetPressed` | `#AA9AFF` | Pressed action |
| `violetSoft` | `#2C245B` | Violet chip/card background |
| `aqua` | `#55D8D4` | Evidence/reference data |
| `aquaSoft` | `#153D40` | Evidence background |
| `lime` | `#A1DA61` | Happened outcome |
| `limeSoft` | `#273D20` | Happened background |
| `coral` | `#FF7B88` | Didn’t-happen/attention |
| `coralSoft` | `#4B232E` | Coral background |
| `amber` | `#FFC759` | Sample/caution |
| `amberSoft` | `#463617` | Caution/sample background |
| `night` | `#0D1444` | Calibration hero |
| `nightElevated` | `#17215C` | Nested plot |
| `onNight` | `#FFFFFF` | Primary text on night |
| `onNightMuted` | `#CBD2FF` | Secondary text/grid on night |
| `destructive` | `#FF7183` | Irreversible action only |

### Increased-contrast appearance

- Light: `canvas #FFFFFF`, `surface #FFFFFF`, `ink #070611`, `inkSecondary #302C46`,
  `border #51497A`, `violet #3618CE`, `aqua #006F70`, `lime #376F0A`, `coral #A81731`,
  `amber #795000`, `night #050D42`.
- Dark: `canvas #000000`, `surface #0B0B12`, `ink #FFFFFF`, `inkSecondary #E9E6F5`,
  `border #AAA3D0`, `violet #B5A8FF`, `aqua #7FF4EF`, `lime #C1F783`, `coral #FF9AA5`,
  `amber #FFE087`, `night #00072E`.
- Increase 1-point boundaries to 2 points, eliminate translucent text, and remove decorative
  gradients behind labels. Do not change semantic meaning.

### Confidence spectrum

Use a single shared gradient only for confidence instruments and calibration legends:

`0% #6545F4 → 25% #437CEF → 50% #28BFC1 → 75% #8FCB42 → 100% #F26B68`.

This spectrum represents stated probability, not good/bad or correct/incorrect. Always pair it
with a numeric percentage, endpoint labels, and accessible value. Never use it as body-text color.

## 6. Typography

Use Apple system fonts only. SF Pro provides adult clarity; SF Rounded is reserved for joyful
hero numbers and the Capture action. All tokens map to Dynamic Type text styles.

| Token | Nominal style | Usage |
|---|---|---|
| `display` | 40/44 bold, rounded | Onboarding promise; never more than three lines |
| `heroStat` | 48/52 heavy, rounded, monospaced digits | Confidence and one primary insight |
| `title1` | 32/38 bold | Screen titles |
| `title2` | 24/30 semibold | Section and card titles |
| `headline` | 17/22 semibold | Buttons, row titles |
| `body` | 17/24 regular | Main prose and authored statement |
| `callout` | 15/20 regular | Explanations |
| `label` | 13/18 semibold | Chips and chart legends |
| `caption` | 12/16 regular | Dates and secondary metadata |

- Use monospaced digits for percentages, dates, denominators, Brier scores, and comparisons.
- Forecast text uses SF Pro Text, not serif or handwriting; the person’s words are important but
  should not make the app resemble stationery.
- A custom wordmark may use a lively italic form only as a decorative asset. Expose “Hindsight” as
  its accessibility label and never use the wordmark for a control or heading.
- Critical content must wrap at every Dynamic Type size. No `minimumScaleFactor` on forecast text,
  buttons, or analytical claims.

## 7. Layout, shape, and depth

### Spacing

Use a 4-point grid: `2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64`.

- Compact horizontal gutter: 20 points.
- Regular-width gutter: 32 points.
- Readable content maximum: 720 points; analytics plot maximum: 820 points.
- Card internal padding: 16 compact, 20 regular.
- Section gap: 32; related-control gap: 12; label-to-field gap: 8.
- Minimum target: 44×44; primary actions: at least 52 points high.

### Radius

- `radiusXS 8`: small tags and chart tooltips.
- `radiusS 12`: compact chips and fields.
- `radiusM 16`: rows and standard cards.
- `radiusL 24`: hero cards and sheets.
- `radiusXL 32`: onboarding and completion hero.
- `pill 999`: segmented filters, confidence value, primary capsule actions.

### Elevation

- Level 0: canvas; no shadow.
- Level 1: list/card; 1-point border plus `0 2 10 / 6% black` in light mode.
- Level 2: hero/sheet; `0 8 28 / 10% black` and a faint violet ambient halo.
- Level 3: center Capture button only; `0 8 22 / 20% violet`.
- Dark mode uses borders and tonal separation; black shadows must not create muddy halos.
- Never stack more than two raised surfaces or add hard offset shadows.

## 8. Motion and haptics

### Timing

- Micro state change: 120–160 ms ease-out.
- Navigation/content transition: 220–260 ms ease-in-out.
- Emphasis/bloom: 360–520 ms spring, damping 0.82; play once.
- No looping ambient animation, pulsing CTA, or automatic carousel.

### Approved motion

- Tab selection: icon rises 2 points and circular highlight fades in.
- Capture: button compresses to 0.96, sheet scales from 0.98 while fading.
- Confidence: thumb follows continuously; numeric value cross-fades without bouncing layout.
- Successful save: a small ring expands behind the lock/check only after persistence commits.
- Honest resolution: 8–14 signal dots bloom once for every completed review, regardless of outcome.
- Insight hero: line/points draw once when first visible; subsequent visits show stable data.
- Reduce Motion replaces translation, spring, particles, and chart drawing with cross-fades/static
  final states under 150 ms.

### Haptics

- Selection feedback at confidence 0, 25, 50, 75, and 100; light ticks every 10 points at most.
- Light impact on selecting an outcome or date chip.
- Success haptic only after an authoritative save/delete/export preparation succeeds.
- Warning haptic for a destructive confirmation, not ordinary “didn’t happen” outcomes.
- Respect the app haptic preference and system Reduce Motion; haptics are never the sole feedback.

## 9. Navigation contract

Use five positions in a native bottom tab bar:

1. **Today** — house/sun signal icon.
2. **History** — clock/history icon.
3. **Capture** — raised 58-point circular plus; an action, not a retained destination.
4. **Insights** — chart/signal bars icon.
5. **Settings** — gear icon.

- Active content tabs use violet icon/text plus a 32-point soft circular backing. Inactive tabs use
  `inkSecondary`; every icon retains a visible text label.
- The center Capture action uses a violet-to-blue radial fill, white plus, 48-point visible circle,
  and 58-point hit region. Selecting it presents Capture without changing the remembered tab.
- Tab bar uses `surface` at 94–98% opacity with a top border. Respect Reduce Transparency by using
  an opaque surface.
- Today remains the target of cold launch and local-notification deep links before presenting the
  referenced record.
- No Circles or social placeholder appears in the personal release.

## 10. Screen-by-screen production UX

### 10.1 Onboarding

**Goal:** communicate value before asking for effort; reach the first valid Capture in at most two
intentional taps.

**Structure:** two horizontally paged screens, both vertically scrollable at accessibility sizes.
A visible Skip action leads to an empty Today. Do not request notification permission here.

**Page 1 — “Know how your confidence behaves.”**

- Wordmark/mark, then one 2–3 line display promise.
- A dark-night example card: “At 80%+ confidence, outcomes happened 43% of the time” plus
  “Illustration · 7 of 16 resolved forecasts.” It is explicitly labeled as an example.
- A compact visual loop: Record → Wait → Resolve → Learn.
- Primary CTA: **See how it works**. Secondary text action: **Skip**.

**Page 2 — “Start with one belief.”**

- Three concise rows: say what will happen, choose 0–100%, choose when to check.
- Privacy capsule: “No account. Stored on this device. Export or erase anytime.”
- Primary CTA: **Record my first belief** → completes onboarding and immediately opens Capture.
- Secondary CTA: **Explore with examples** → inserts explicit samples transactionally, completes
  onboarding, and opens Today with an “Examples are separate” banner.
- Tertiary action: **Start empty**.

**Example removal:** Today and Settings show a persistent, nonblocking sample chip while examples
exist: “Examples · excluded from your Insights” with **Remove**. Removal is confirmed, targets only
explicit sample IDs, and never deletes matching personal text.

### 10.2 Today

**Goal:** answer “what deserves attention now?” and offer Capture immediately.

**Top area**

- Compact Hindsight wordmark or “Today,” current date, and no streak/flame counter.
- One hero signal, chosen by deterministic priority:
  1. Due forecasts exist → “Ready to review” with count and **Resolve now**.
  2. No due items and at least 10 eligible forecasts → strongest truthful current calibration
     insight with denominator and date window.
  3. Five to nine eligible forecasts → early observed-rate signal labeled “Early evidence.”
  4. One to four eligible forecasts → circular progress “3 of 5 outcomes recorded.”
  5. Zero eligible forecasts → “Start your evidence trail” with **New belief**.
- Never show improvement unless two comparable windows satisfy their sample thresholds.

**Content order**

1. Due now: coral edge, explicit **Resolve** button, oldest due first.
2. Upcoming: next three by review date, **See all** when more exist.
3. Recently resolved: latest two, muted outcome chip, one tap to detail.
4. Example records: collapsed and visually separated; absent from all personal counts.

**Forecast card**

- Leading 36-point signal icon; statement up to four lines; confidence pill; review date/status.
- Due state uses coral label and clock icon; upcoming uses aqua; resolved uses lime/coral plus text.
- Whole card opens detail. The visible Resolve action is separate and at least 44 points.
- Swipe actions may supplement but never replace visible controls.

### 10.3 Capture

**Goal:** save a valid, falsifiable forecast in under ten seconds without hidden defaults.

**Presentation:** single full-height sheet on compact iPhone, centered form sheet on iPad. Close at
top left, “New belief” title, and **Save** at top right plus a full-width bottom action when the
keyboard is dismissed. Do not show a fake multi-step progress bar.

**Field order**

1. **What do you think will happen?** Multiline field, focused on entry, 200-character counter
   shown only after 160 characters. Placeholder gives one neutral example.
2. **How sure are you?** Large `—%` until intentional input. The visible neutral thumb may sit at
   50 but remains hollow and is not a stored answer. First drag/tap/VoiceOver adjustment commits an
   explicit value. Show exact 0–100, endpoint labels, and plain-language probability descriptor.
3. **When can this be checked?** Chips: Tomorrow, 1 Week, 1 Month, Custom. Nothing is selected by
   default. Custom expands the native date picker inline. Past/today values are invalid.
4. **Why? (optional)** Collapsed by default. Expands to a 300-character field without moving Save
   beyond reach; copy says “Evidence, intuition, or context for your future self.”

**Commit behavior**

- Save remains visually disabled until statement, intentional confidence, and future date exist.
- Field-local errors appear after attempted save and move accessibility focus to the first error.
- Save is one idempotent local transaction. Disable repeated taps while pending.
- On failure, preserve every field in a durable draft, remain open, explain what happened, and
  offer **Try again** and **Keep editing**. Run no bloom, haptic, reminder, or dismissal.
- On success, show a 360 ms lock-ring bloom, haptic once, schedule an eligible local reminder, clear
  the draft, and dismiss. Offer a nonblocking toast: “Belief saved for [date].”
- Dismissal with content asks Keep Draft / Discard / Keep Editing. Empty dismissal closes directly.

### 10.4 Resolution

**Goal:** capture what happened faithfully and make honest review satisfying rather than punitive.

**Entry:** due card, due-stack CTA, detail, or notification deep link.

**Structure**

- Locked original card at top: statement, original confidence, Why when present, recorded date,
  review date. A lock icon and “Original · unchanged” make immutability explicit.
- Prompt: **What happened?** with three equal-height choices and nothing preselected:
  - Happened — lime, check icon.
  - Didn’t happen — coral, xmark icon.
  - Couldn’t judge — neutral violet/slate, question icon.
- Optional “What did you learn?” disclosure contains reflection, surprise, lesson, process rating,
  outcome rating, and “Would you make the same decision?” fields already supported by the model.
  Optional ratings must retain a true unset state.
- Sticky primary action: **Save review**. For a stack, follow with **Review next** after commit.

**Completion**

- After persistence commits, show “Review recorded” and a brief signal bloom for all three outcomes.
- Never say “You were right” solely from event outcome. Show factual copy: “You gave this a 60%
  chance. The event happened.”
- Happened and didn’t-happen binary records become eligible only when the original review date has
  arrived. Couldn’t-judge remains visibly excluded from calibration.
- Draft, retry, duplicate protection, immutable original fields, and notification reconciliation
  remain mandatory.

### 10.5 History

**Goal:** provide a trustworthy before/after evidence ledger that is pleasant to browse.

- Header: “History” and count of resolved personal records.
- Search field searches statement, Why, and outcome/reflection text.
- Horizontal filter chips: All, Happened, Didn’t happen, Couldn’t judge; add category only if actual
  category data exists. Filters never mix samples into personal results.
- Group by month with sticky section headers on long lists.
- Cards show outcome label/icon, original confidence, statement, and check date. A narrow semantic
  signal strip supplies color but the outcome remains written.
- Detail uses a vertical Before → After timeline:
  - Before: locked statement, confidence, Why, recorded and review dates.
  - After: event outcome, reflection, ratings, and reviewed date.
  - Insight link: “How this affects Insights” explains included/excluded status.
- Search/no-match preserves filters and offers **Clear search**; it never substitutes samples.

### 10.6 Insights

**Goal:** make personal analytics the product’s emotional and intellectual payoff.

**Top navigation:** segmented control with **Calibration**, **Patterns**, and **Trends**. Calibration
is the default. A window menu supports All time, 12 months, 90 days, and 30 days; unavailable
windows remain visible but explain the required sample rather than silently changing scope.

#### Calibration tab

1. **Night-garden hero story**
   - Prefer the most actionable eligible claim, not the most flattering one.
   - Example: “At 80%+ confidence, outcomes happened 43% of the time.”
   - Immediately show “6 of 14 due, resolved personal forecasts · Jan–Aug 2026.”
   - Include a compact reliability plot: actual outcome rate on y-axis, stated confidence on x-axis,
     perfect-calibration diagonal, solid actual line, shaped data points.
   - If no band qualifies, use overall early-evidence or progress state instead.
2. **Core instruments**
   - Eligible forecasts.
   - Mean stated confidence.
   - Observed outcome rate.
   - Signed calibration gap in percentage points.
   - Brier score with “lower is better” and a plain-language explainer.
3. **Confidence bands**
   - Fixed, nonoverlapping bands: 0–19, 20–39, 40–59, 60–79, 80–100.
   - Each band displays n, mean confidence, observed rate, and signed gap when `n ≥ 10`.
   - Sparse bands remain visible as “Need X more” so absence cannot be mistaken for zero.
4. **Interpretation card**
   - Overconfident: mean confidence exceeds observed rate; state signed evidence, never identity.
   - Underconfident: observed rate exceeds mean confidence.
   - Near calibrated: absolute gap within the engine’s declared tolerance.

#### Patterns tab

Show comparison cards only when every compared cohort meets the engine-owned minimum (target
`n ≥ 5` per cohort; keep the threshold in one analytics policy, not view code):

- Category calibration: where confidence and outcomes align or diverge.
- Horizon: short, medium, and long review windows.
- Why vs no Why: compare calibration/Brier only; do not claim causation.
- High-confidence misses: share of eligible 80%+ forecasts whose event did not happen.
- Uncertainty zone: what happened in 40–59% forecasts.
- Resolution discipline: due count, overdue count, and median time from due to review. Label this as
  record-keeping behavior, not forecasting accuracy.

Every card includes headline, one-sentence interpretation, n/window, and **See evidence** leading to
the exact History subset. Never show “best/worst category” without qualified samples.

#### Trends tab

- Rolling observed rate vs mean confidence, using the same window boundaries and visible n.
- Rolling Brier score with a lower-is-better legend.
- Confidence distribution: how often the person uses each band; it is descriptive, not a grade.
- “Changed since last period” appears only when both nonoverlapping periods meet `n ≥ 10` and use
  identical eligibility. Otherwise say “Need comparable periods.”
- Monthly/quarterly “Your Hindsight report” is an in-app story stack derived locally:
  - Most-used confidence band.
  - Boldest eligible forecast.
  - Largest calibrated surprise.
  - Category/horizon signal when qualified.
  - One next experiment, such as “Write Why on five forecasts and compare.”
  Reports contain no streaks, global comparisons, ranking, AI diagnosis, or unsupported advice.

#### Sample-safe analytics states

- `n = 0`: “Your signal starts after outcomes arrive,” loop explainer, **Record a belief**.
- `n = 1–4`: progress ring toward five; list eligibility and exclusions, no percentage headline.
- `n = 5–9`: overall values labeled **Early evidence**; no directional band or cohort claim.
- `n ≥ 10`: enable each independently qualified band; do not imply all bands qualify.
- Sample, pending, cancelled, partial, couldn’t-judge, invalid-confidence, and not-yet-due records
  are excluded. Show excluded counts by reason in **How this is calculated**.
- Example data never powers onboarding, Today, reports, cards, charts, trends, or comparisons that
  look personal. Onboarding illustration is hard-coded and labeled, not inserted analytics data.

#### Chart accessibility

- Every chart has a complete spoken summary and an adjacent **View as list** representation.
- Use point shapes, line styles, labels, and ordering in addition to color.
- Axis labels, denominator, date window, eligibility, and lower/higher-is-better direction are
  exposed to VoiceOver.

### 10.7 Settings

**Goal:** make trust and control easy to verify without turning Settings into a legal document.

Use a bright, flat grouped list with circular colored icons; reserve cards for privacy status and
destructive confirmations.

1. **Privacy status hero:** lock icon, “Stored on this device,” and “No account · No Hindsight
   cloud · No tracking.” Link to learn more.
2. **Reminders:** authorization status, review-reminder toggle, explanation, and Open iOS Settings
   when denied. Toggling must reconcile eligible personal reminders and exclude samples.
3. **Appearance:** System / Light / Dark; preview swatches use real tokens. Haptics toggle follows.
4. **Example data:** load, current sample count, remove, and explicit exclusion explanation.
5. **Your data:** Export JSON, Export PDF, recovery/draft controls, and local data explanation.
6. **Help:** How Hindsight works, How Insights are calculated, privacy draft/public policy link,
   support contact when configured, version/build.
7. **Delete data:** separated by space and border. Confirm exact record/draft/reminder impact;
   preserve data on failure and offer retry.

No account, friends, Circles, cloud-sync, or “coming soon” rows appear in this release.

## 11. State contract

| Surface | Empty | Loading | Error / recovery |
|---|---|---|---|
| Onboarding | Not applicable | Sample insertion shows inline progress | Failure adds nothing, preserves existing data, and offers Retry / Start empty |
| Today | Explain first belief and show Capture | Use stable skeletons only if query exceeds 200 ms | Keep last safe content when possible; inline Retry; never show zero as successful load |
| Capture | Blank durable draft with explicit unset controls | Save button shows Saving and disables duplicate taps | Preserve draft; field-local validation or retryable persistence banner |
| Resolution | No due item routes back with explanation | Save Review shows Saving | Preserve choices/notes; no terminal UI until commit |
| History | Truthful no-resolved state | Row skeletons matching final geometry | Inline retry; separate no-match with Clear search |
| Insights | Eligibility/progress state, not empty chart | Stable hero/tiles skeleton; no fake values | Explain calculation failure and Retry; never substitute sample or cached invented metrics |
| Settings | Sections remain visible | Row-level progress for export/sample/delete | Operation-specific message, unchanged data, safe retry |

- Offline is a normal fully functional state for the personal release; do not show an offline error.
- Cancellation and backgrounding preserve recoverable user work.
- Empty, error, and permission states use the same colorful system without illustrations that
  trivialize lost data or failed saves.

## 12. Accessibility and responsive behavior

- Meet WCAG 2.2 AA contrast targets: 4.5:1 for normal text, 3:1 for large text and meaningful
  graphical controls. Record measured evidence for final token pairings.
- Support every Dynamic Type size through AX5. Stack horizontal layouts before truncating; charts
  may become accessible lists, and sticky actions must remain reachable above the keyboard.
- Provide logical VoiceOver order, concise labels, values, hints, selected state, headings, and
  focus movement after validation or modal presentation.
- Confidence is a proper adjustable control. It announces explicit/unset state, exact percent, and
  descriptor; first adjustment intentionally selects a value.
- Touch targets are at least 44×44 with 8 points between adjacent destructive/primary actions.
- Support Differentiate Without Color, Increase Contrast, Reduce Motion, Reduce Transparency,
  button shapes, Bold Text, and Voice Control names.
- Do not encode happened/didn’t/couldn’t, due status, confidence, sample status, or chart series by
  color alone. Pair with labels, icons, shapes, or line patterns.
- Use semantic leading/trailing layout for RTL readiness. Dates and percentages use locale-aware
  formatting; authored forecast text preserves natural alignment.
- On iPad, center readable content rather than stretching cards edge to edge. Use a two-column
  Insights layout only when each column remains at least 320 points.
- Validate smallest supported iPhone portrait, large iPhone, iPad mini, keyboard-visible Capture,
  long localized text, light/dark/high contrast, and all state variants in simulator evidence.
- Physical-device verification is explicitly user-deferred and is not an implementation exit gate
  for this redesign workstream unless the user later reauthorizes it.

## 13. Non-goals

- Accounts, backend, cloud sync, telemetry, remote config, or third-party SDKs.
- Friends, Circles, shared lists, messaging, iMessage, public events, feeds, or leaderboards.
- Prediction-market mechanics, betting, money, odds trading, global score, or competitive ranking.
- Points, coins, streak flames, daily guilt, collectible plants, levels, or “perfect week” rewards.
- AI-generated advice, personality diagnosis, certainty claims, or medical/financial guidance.
- Editing locked statement, original confidence, Why, creation time, or review date after save.
- Changing analytics formulas to fit a visual story, or allowing samples to produce personal claims.
- A custom font, custom chart engine, or design dependency when native SwiftUI can satisfy the spec.
- A literal garden skin. “Signal Garden” defines energy and visual language, not novelty copy.
- Social placeholders or inactive tabs. Future social work must pass its separate identity, safety,
  privacy, moderation, and hosted-integrity gates.

## 14. Implementation sequence

Each phase must leave the app buildable and preserve existing user data. A lower-capability agent
should implement one phase at a time, read the named contract/tests first, and record evidence
before changing lifecycle status.

### Phase SG0 — Baseline and executable contract

1. Add/update the feature contract to reference this document and enumerate the new visual/state
   acceptance tests without changing persistence semantics.
2. Capture current simulator baselines for every entry screen and record existing test results.
3. Inventory raw colors, one-off radii, custom shadows, and obsolete Future Postcard components.
4. Confirm no model migration is needed; if any view proposes a new stored value, stop and write a
   separate migration contract.

**Exit:** contract validated, tests registered, current baseline reproducible; no production UI
changed.

### Phase SG1 — Tokens and primitives

1. Replace the beige/editorial theme values with semantic Signal Garden light/dark/high-contrast
   tokens while keeping compatibility aliases until all callers migrate.
2. Implement reusable card, hero, chip, badge, outcome choice, confidence slider, FAB, skeleton,
   inline error, and chart-legend primitives.
3. Add component previews for light, dark, high contrast, AX5, long text, enabled/disabled/loading,
   and Reduce Motion.
4. Add token tests for prohibited raw colors and verify representative contrast pairs.

**Exit:** primitives compile independently; no feature owns raw palette values.

### Phase SG2 — Shell and onboarding

1. Implement the five-position tab shell and raised action-only Capture behavior.
2. Preserve selected content tab, deep-link routing, and sheet idempotency.
3. Build two-page onboarding, example insertion error state, skip, start empty, and immediate first
   Capture path.
4. Verify no permission prompt, fake personal metric, account, or social surface appears.

**Exit:** a fresh install reaches Capture in at most two taps; sample and empty paths are truthful.

### Phase SG3 — Capture

1. Rebuild Quick Capture as the specified one-screen sheet using the existing durable draft.
2. Preserve explicit unset confidence and date states, optional Why, boundary values, keyboard
   behavior, save idempotency, retry, discard, and notification side-effect ordering.
3. Keep the detailed legacy decision flow reachable only as optional post-save enrichment or a
   clearly secondary Settings/help route; it must not compete with quick Capture.
4. Add focused unit/UI tests for 0/1/50/99/100, custom date, blank Why, draft relaunch, duplicate
   taps, and failed persistence.

**Exit:** the primary valid capture path is one screen and passes the data-integrity suite.

### Phase SG4 — Today and History

1. Implement deterministic hero priority and truthful early/empty states.
2. Redesign due/upcoming/recent cards without changing selector/sample rules.
3. Rebuild History filters, search, month grouping, outcome labels, and before/after detail.
4. Ensure each Insight/deep-link subset resolves to the same eligible personal records.

**Exit:** counts match repositories, samples remain separate, and no hero claim appears without its
threshold/window.

### Phase SG5 — Resolution

1. Implement locked-original hero, three event outcomes, optional reflection disclosure, and sticky
   save action.
2. Preserve nullable ratings, draft recovery, atomic terminal write, duplicate protection, fast
   resolution coherence, and due-date eligibility.
3. Add factual post-commit copy and outcome-neutral signal bloom.
4. Test due stack, notification route, all outcomes, retry, relaunch, and immutable source fields.

**Exit:** honest completion is delightful for every outcome and never changes the locked forecast.

### Phase SG6 — Insights

1. Keep one analytics policy as the source of band/cohort/window thresholds and eligibility.
2. Build Calibration hero, core instruments, accessible reliability plot, band cards, and method
   sheet from existing deterministic statistics.
3. Add Patterns, Trends, and report stories only for calculations covered by unit tests.
4. Implement every n=0, n=1–4, n=5–9, qualified, partially qualified, and excluded-record state.
5. Add list equivalents and full VoiceOver summaries for every chart.

**Exit:** fixture-based tests prove each displayed number, story selection, denominator, exclusion,
and low-sample state; samples never affect output.

### Phase SG7 — Settings, accessibility, and polish

1. Apply grouped Signal Garden styling without changing export/delete/reminder authority.
2. Complete appearance, reminder permission, examples, export, recovery, help, and destructive
   states.
3. Run simulator matrices for supported form factors, appearances, accessibility settings,
   keyboards, long text, and state/error fixtures.
4. Remove obsolete beige/postcard styling only after all callers and tests migrate.
5. Update screenshots, product docs, privacy wording if behavior changed, and completion evidence.

**Exit:** all automated and simulator evidence is dated; remaining user-owned release actions stay
`verification_pending`. Do not require or perform physical-device testing without new user consent.

## 15. Acceptance criteria

### Product and navigation

- [ ] A first-time user can state the product value after viewing the first onboarding page.
- [ ] First valid Capture opens within two taps from onboarding and one tap from every main tab.
- [ ] Capture is an action, not a blank retained tab; previous content tab remains selected.
- [ ] No account, social placeholder, streak, score, or market language is visible.

### Visual quality

- [ ] No beige/paper/postcard treatment remains on primary screens.
- [ ] Light, dark, and increased-contrast token sets are complete and semantic.
- [ ] The confidence spectrum appears only on probability/calibration controls.
- [ ] Today, Capture, Insights, and Resolution visibly reflect the north star while History and
      Settings remain calmer members of the same system.
- [ ] Raw feature-view colors, arbitrary shadows, and one-off radii fail lint/test review.

### Capture and resolution integrity

- [ ] Statement, intentional confidence, and future date are required; Why is optional.
- [ ] 0, 1, 50, 99, and 100 persist and announce exactly; neutral thumb is not implicit input.
- [ ] A valid quick forecast can be saved from one screen with no mandatory enrichment.
- [ ] Failed/interrupted Capture and Resolution preserve recoverable drafts and run no premature
      success side effect.
- [ ] Duplicate taps/retries create at most one forecast or one outcome.
- [ ] Locked original fields remain visually and behaviorally immutable.
- [ ] Happened, didn’t happen, and couldn’t judge are unselected initially and described without
      person-level right/wrong judgment.

### Analytics

- [ ] Every claim includes n, window, eligibility, and a method/exclusion route.
- [ ] Overall, band, cohort, trend, and comparison thresholds come from one tested policy.
- [ ] The 80%+ story can say “outcomes happened 43% of the time” only when actual eligible records
      calculate that result and the denominator is shown.
- [ ] Sample, pending, cancelled, couldn’t-judge, invalid, partial, and not-yet-due records cannot
      affect personal analytics or report stories.
- [ ] Brier is labeled lower-is-better and is never called accuracy/hit rate.
- [ ] Early/sparse data produces progress or “not enough evidence,” never a trait claim.
- [ ] Every chart provides nonvisual summary and list/table equivalent.

### Data, states, and accessibility

- [ ] Existing SwiftData records open without migration loss or silent upload.
- [ ] Samples remain explicitly identified and excluded from counts, Insights, reminders,
      notifications, exports, and relationships.
- [ ] Loading, empty, no-match, permission-denied, validation, persistence, export, deletion, and
      analytics-error states have verified UI and recovery.
- [ ] Dynamic Type AX5, VoiceOver, Increase Contrast, Reduce Motion, Reduce Transparency, Bold
      Text, long text, keyboard presence, and smallest supported simulator retain all actions.
- [ ] All meaningful text/control contrast is measured and meets the declared target; every target
      is at least 44×44.
- [ ] Haptics and bloom occur only after confirmed authoritative success and have accessible static
      equivalents.

### Verification status

- [ ] Unit, integration, and UI-smoke suites pass against the exact final source.
- [ ] Responsive simulator visual evidence covers light, dark, high contrast, smallest iPhone,
      large iPhone, and iPad mini.
- [ ] Privacy, manifest, sample-isolation, persistence/relaunch, export/deletion, and Release build
      checks pass.
- [ ] Physical-device testing remains recorded as user-deferred and is neither performed nor
      represented as complete.
- [ ] Lifecycle remains `verification_pending` until every applicable, authorized gate has dated
      evidence.
