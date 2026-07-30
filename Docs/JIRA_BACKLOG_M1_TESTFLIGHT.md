# HIND backlog — Build 1 and TestFlight

**Prepared:** 2026-07-29
**Authoritative source:** `MVP_PLAN.md` Baseline M1.0; estimates are immutable.
**Intended Jira structure:** two Epics and 18 child work items, all initially `To Do`.
**Jira mapping status:** creation is held until HIND’s field configuration stops requiring
life-cycle fields (`Actual`, `Delay Cause`, etc.) at creation. Do not work around this by
inventing data. Every ticket below is ready to paste into Jira unchanged.

## Common implementation rules

- App is local-first SwiftUI + SwiftData; add no backend or third-party dependency.
- Preserve the existing `Decision` / `Prediction` schema unless a ticket explicitly authorizes a
  migration. Build 1 should require **no schema change**.
- Never mark a task done without the exact verification evidence listed in its ticket.
- Keep preview/sample fixtures out of production data. Do not silently save when persistence
  fails; use the existing recovery/persistence boundary.
- Implement in small, reviewable commits. Update `Docs/PLAN_TRACKING.md` only after completion:
  add `Actual`, any required `Cause`, and evidence.

---

# Epic: Build 1 — Quick Capture MVP

**Goal:** a stranger can record a prediction in under ten seconds and resolve one without
instruction. The product metric is the fraction of testers who resolve at least one prediction
within 14 days—not installs or captures.

**In scope:** M1.1–M1.10 below. **Not in scope:** voice, App Groups, widgets, Siri, backend,
social features, analytics services, or a model migration.

## M1.1 — Implement Quick Capture sheet

- **Type / label / estimate / risk:** Task · `ENG` · 3 ideal days · MED.
- **User story:** As a person with a fleeting prediction, I can save its statement, my confidence,
  and when to revisit it in one focused sheet.
- **Why:** the four-step `NewDecisionWizard` makes the core habit too costly; this is the
  highest-leverage retention change.
- **Implementation:** add a dedicated SwiftUI sheet (for example under `Views/QuickCapture/`) and
  a small observable draft. Require a non-blank statement; accept an explicit confidence value;
  choose a review date through M1.3’s date picker. On Save, create one `Decision` and one pending
  `Prediction` through `ModelContext`, using existing model fields and the existing persistence
  error/recovery conventions. Set a deliberate, documented minimal decision context rather than
  altering `Decision` or `Prediction` schema. Dismiss only after a confirmed successful save.
- **Dependencies / non-scope:** no schema migration; M1.3 supplies the date chips. Do not delete
  or refactor the wizard in this task.
- **Edge cases:** whitespace-only statement; date in the past; save failure; duplicate taps;
  keyboard covering Save; cancel must leave no persistent records.
- **Acceptance / verification:**
  - [ ] Blank or whitespace-only statement cannot save and has an accessible explanation.
  - [ ] A valid save creates exactly one Decision with exactly one pending Prediction and the
    selected due date/confidence.
  - [ ] Cancel and failed persistence create no orphaned record; retry is possible.
  - [ ] The normal flow needs statement → confidence → review date → save, with no wizard pages.
  - [ ] Add focused unit/integration tests and manual simulator evidence; attach build/test output.

## M1.2 — Add a prominent Quick Capture entry point on Today

- **Type / label / estimate / risk:** Task · `ENG` · 1 day · LOW.
- **User story:** As a returning user on Today, I can start quick capture from the obvious primary
  action, while detailed entry remains available when I need it.
- **Why:** a fast sheet is irrelevant if the home screen still routes users into a long wizard.
- **Implementation:** modify `Hindsight/Views/TodayView.swift`: make the floating add button and
  empty-state primary action present Quick Capture; expose the existing `NewDecisionWizard` as a
  secondary “Add detail” action with clear, non-competitive placement. Preserve Today navigation,
  refresh, haptics, and existing decisions display.
- **Dependencies / non-scope:** depends on M1.1. Do not redesign all Today sections.
- **Acceptance / verification:**
  - [ ] Empty and populated Today states both launch Quick Capture from their primary CTA.
  - [ ] The detailed wizard remains reachable and still saves a full decision.
  - [ ] Sheet state resets after Save and Cancel; no presentation collision occurs.
  - [ ] Add a UI smoke assertion for the primary path and run the affected suite.

## M1.3 — Add short-horizon review-date chips

- **Type / label / estimate / risk:** Task · `ENG` · 1 day · LOW.
- **User story:** As a user making an everyday prediction, I can choose a near review time without
  operating a calendar.
- **Why:** early payoff requires predictions to become due soon; long defaults hide the loop.
- **Implementation:** in the M1.1 sheet, provide mutually exclusive, accessible chips ordered:
  Tomorrow, This Week, This Month, Six Months, Custom. Compute dates with `Calendar` using the
  user’s current locale/time zone; Custom opens a date picker. Display the resolved calendar date
  so the selection is auditable.
- **Dependencies / non-scope:** M1.1. Do not change notification scheduling policy here.
- **Edge cases:** daylight-saving transitions; end of month/year; “this week” after its natural
  end; date picker disallowing past dates.
- **Acceptance / verification:**
  - [ ] Each chip maps deterministically to a future due date and persists that date.
  - [ ] Short options appear before Custom and one selection is visually/accessibly selected.
  - [ ] Custom cannot save a past date.
  - [ ] Unit-test date calculations with fixed calendars/dates, including month/year boundaries.

## M1.4 — Add first-session short-horizon nudge

- **Type / label / estimate / risk:** Task · `DESIGN` · 1 day · MED.
- **User story:** As a new user, I receive a gentle suggestion to make one prediction I can revisit
  soon, without being blocked or lectured.
- **Why:** the first closed loop is the retention lever; a nudge should shorten time-to-value.
- **Implementation:** add a one-time, dismissible contextual hint in Quick Capture or the first
  Today state, persisted with a named key in `AppStorageKeys`. Copy should recommend a short
  horizon and explain the payoff in one sentence. It must not preselect a confidence or a date.
- **Dependencies / non-scope:** M1.1/M1.3; no new onboarding flow or remote configuration.
- **Acceptance / verification:**
  - [ ] It appears only before the user’s first successful quick capture (or one documented
    equivalent trigger) and never blocks entry.
  - [ ] Dismissal is remembered across relaunch; accessibility exposes it in logical order.
  - [ ] Copy is supportive, not a score or warning; it does not imply user data was recorded.
  - [ ] Verify fresh-install, dismissal, relaunch, and VoiceOver narration manually.

## M1.5 — Reframe clarity score as an invitation

- **Type / label / estimate / risk:** Task · `DESIGN` · 1 day · MED.
- **User story:** As a user who captured a lightweight thought, I understand that extra detail is
  optional rather than being told my entry is “Sketchy.”
- **Why:** quick captures use less wizard detail and currently receive a low clarity score; shame
  would discourage the exact behavior the MVP needs.
- **Implementation:** audit score labels/copy in `Managers/ClarityScore.swift`, decision cards,
  detail, and wizard surfaces. Replace judgmental wording with an optional invitation to add
  context. Preserve the underlying score calculation and avoid presenting a falsely improved
  numerical score.
- **Dependencies / non-scope:** none; coordinate visual wording with M1.1. No scoring-model
  change, no hidden default fields.
- **Acceptance / verification:**
  - [ ] No quick-capture success surface calls the entry sketchy, poor, or incomplete.
  - [ ] Any score shown has neutral meaning plus an optional, reversible path to add detail.
  - [ ] Existing clarity-score unit tests retain their intended numerical expectations; update only
    copy assertions/fixtures where needed.
  - [ ] Review dark mode, Dynamic Type, and VoiceOver wording.

## M1.6 — Build the fast resolve ritual card stack

- **Type / label / estimate / risk:** Task · `ENG` · 3 days · MED.
- **User story:** As a user with due predictions, I can rapidly mark what happened and whether the
  prediction was correct, one card at a time.
- **Why:** resolution—not capture—is the product’s payoff and primary 14-day activation metric.
- **Implementation:** use the archived pivot only as behavioral reference, not as a blind merge.
  Add a dedicated due-prediction stack reached from Today’s Needs Review area. Use
  `Prediction.status`, `actualResult`, existing `PredictionStatus`, `OutcomeReviewView` semantics,
  and `ModelContext` save/error patterns. Each card must present statement, recorded confidence,
  due date, an optional result note, and explicit verdict actions. Advance only after a successful
  save; expose an obvious exit/defer route.
- **Dependencies / non-scope:** depends on M1.1 data and existing resolution semantics. Do not
  introduce partial/uncertain outcomes unless the existing enum already supports them coherently.
- **Edge cases:** zero due items; multiple predictions per Decision; already-resolved items;
  duplicate taps; persistence error; reopened sheet after partial progress.
- **Acceptance / verification:**
  - [ ] Due pending predictions are discoverable from Today and resolve without opening the full
    retrospective form.
  - [ ] A resolution persists exactly once, removes/updates the card, and updates review state.
  - [ ] Failed saves keep the card and user-entered note available with retry/cancel behavior.
  - [ ] Empty, one-card, and multi-card states are useful and accessible.
  - [ ] Add unit/integration coverage for persistence/state transitions and UI smoke evidence.

## M1.7 — Surface sample-aware overconfidence insight

- **Type / label / estimate / risk:** Task · `ENG` · 2 days · LOW.
- **User story:** As a user with resolved predictions, I can see when my stated confidence exceeds
  my hit rate, in plain language grounded in my own sample.
- **Why:** “you say 90%, you are right 70%” is a memorable payoff that makes reviewing valuable.
- **Implementation:** extend `Hindsight/Managers/Statistics.swift` with a named, deterministic
  calibration/overconfidence result: resolved-prediction count, average stated confidence, hit
  rate using existing status scoring, signed gap, and a minimum-sample gate. Render it in
  `Views/Insights/InsightsView.swift` as a dedicated card with neutral copy. Reuse, reconcile, or
  replace the existing heuristic in `Statistics.patterns` so one contradictory message is never
  shown.
- **Dependencies / non-scope:** depends on resolved predictions (M1.6 improves supply). No Brier
  score, social benchmarking, or claims of statistical certainty.
- **Acceptance / verification:**
  - [ ] Below the documented threshold, show an honest “keep resolving” state—not a percentage
    claim.
  - [ ] Above threshold, values are computed only from resolved predictions; pending items never
    affect numerator or denominator.
  - [ ] Over-, under-, and well-calibrated paths use factual, non-shaming wording.
  - [ ] Add deterministic statistics tests for all three paths, partial verdict behavior if
    supported, and zero-sample behavior.

## M1.8 — Apply gentle reveal copy across review and Insights

- **Type / label / estimate / risk:** Task · `DESIGN` · 1 day · MED.
- **User story:** As someone learning I was wrong, I feel invited to reflect rather than punished.
- **Why:** users will avoid the review loop if it feels like a grading system.
- **Implementation:** inventory copy in `OutcomeReviewView`, the M1.6 stack, Today’s Needs Review,
  `InsightsView`, and `Statistics.patterns`. Establish a small approved vocabulary for due,
  resolved, accurate, and inaccurate outcomes. Preserve clarity: never euphemize a result so much
  that analytics becomes misleading.
- **Dependencies / non-scope:** M1.6/M1.7. This is a copy/interaction pass, not a new design
  system.
- **Acceptance / verification:**
  - [ ] Due/reveal/error/empty states use the approved tone consistently.
  - [ ] No outcome path celebrates or shames an incorrect prediction; success feedback means save
    success, never “you were right.”
  - [ ] Copy remains concise at largest supported Dynamic Type and is intelligible in VoiceOver.
  - [ ] Document the final strings/locations in the PR description and obtain product review.

## M1.9 — Add MVP automated test coverage

- **Type / label / estimate / risk:** Task · `QA` · 3 days · MED.
- **User story:** As a maintainer, I can change capture, resolution, and insight code without
  silently breaking the core loop or corrupting records.
- **Why:** the MVP touches persistence, statistics, and high-frequency UI; regressions would erase
  trust before TestFlight.
- **Implementation:** extend the existing app-hosted unit test target under `HindsightTests` and
  `HindsightUITests` as appropriate. Cover Quick Capture validation/persistence, date chips,
  resolve-stack state changes/failure behavior, and exact overconfidence calculation/sample gate.
  Use in-memory SwiftData containers and deterministic dates; never depend on SampleData in
  production assertions.
- **Dependencies / non-scope:** M1.1–M1.7 implemented. Do not replace the whole test architecture.
- **Acceptance / verification:**
  - [ ] Test names map one-to-one to the M1 acceptance criteria above.
  - [ ] Unit, integration, and UI-smoke suites pass on the documented simulator destination.
  - [ ] Include regression tests for duplicate save/resolution attempts and failed persistence.
  - [ ] Record the exact command, destination, test count, and result in completion evidence.

## M1.10 — Complete manual VoiceOver pass on new MVP surfaces

- **Type / label / estimate / risk:** Task · `QA` · 2 days · MED.
- **User story:** As a VoiceOver user, I can capture and resolve a prediction without unexplained
  controls, lost focus, or inaccessible outcome feedback.
- **Why:** accessibility is a release requirement and the new sheet/stack are gesture-dense.
- **Implementation:** test on-device or simulator VoiceOver for Today entry, Quick Capture,
  short-horizon chips, validation errors, resolve stack, save/retry/cancel, and Insights card.
  Fix accessibility labels, traits, grouping, focus order, and announcements found during audit.
- **Dependencies / non-scope:** M1.1–M1.8 and M1.9 smoke coverage. No unrelated accessibility
  redesign.
- **Acceptance / verification:**
  - [ ] Every actionable control has a unique, meaningful label and state/value when applicable.
  - [ ] Focus order follows visual/task order; sheet presentation/dismissal returns focus sensibly.
  - [ ] Validation and persistence failures are announced; color is never the only status signal.
  - [ ] Attach a route-by-route audit checklist, device/OS, findings, fixes, and remaining risks.

---

# Epic: TestFlight Release Track

**Goal:** deliver Build 1 first to internal testers, then external testers after policy/review.
Internal testing is the fast path; external testing requires Beta App Review and a public privacy
policy URL.

## T1 — Register the bundle ID and create the App Store Connect record

- **Type / label / estimate / risk:** Task · `OPS` · 0.5 day · LOW.
- **User story:** As the release owner, I have a correctly identified app record to which builds can
  be uploaded and testers invited.
- **Why:** this unblocks distribution signing, labels, testers, and every TestFlight upload.
- **Implementation:** using the paid Apple Developer/App Store Connect account, verify bundle ID
  `com.pchordia.hindsight`, create the app record with iOS platform, correct SKU, primary
  language/category, and current version/build convention. Record team, bundle ID, app Apple ID,
  SKU, and owners in release evidence; never place credentials in the repo.
- **Dependencies / non-scope:** account access; blocks T2/T4/T6/T7. No store listing launch.
- **Acceptance / verification:**
  - [ ] Bundle ID and App Store Connect record exist and match Xcode exactly.
  - [ ] A release owner can open the record and Xcode signing has the correct team selected.
  - [ ] Document non-secret identifiers/screenshots in release evidence.

## T2 — Create distribution signing and provisioning

- **Type / label / estimate / risk:** Task · `OPS` · 0.5 day · MED.
- **User story:** As a release owner, I can archive a distributable build rather than a temporary
  developer-signed device build.
- **Why:** current phone installation expires and cannot become TestFlight distribution.
- **Implementation:** create or verify an Apple Distribution certificate and App Store/TestFlight
  provisioning profile for the Hindsight bundle ID/team. Configure Xcode’s Release signing without
  committing certificates, profiles, account IDs, or secrets.
- **Dependencies / non-scope:** T1. Do not rotate unrelated certificates.
- **Acceptance / verification:**
  - [ ] Archive signing resolves to Apple Distribution for the correct team/bundle ID.
  - [ ] A Release archive validates without signing errors.
  - [ ] Store only non-secret verification artifacts and renewal owner/date.

## T3 — Audit Release configuration

- **Type / label / estimate / risk:** Task · `ENG` · 1 day · MED.
- **User story:** As a tester, I receive a production-like build that cannot activate test-only
  behavior or ship debugging state.
- **Why:** a successful Debug build is not evidence that the distributable app is safe.
- **Implementation:** audit project build settings, schemes, `Info.plist` values, privacy manifest,
  app icons/launch screen, logging, SampleData/demo entry points, and UI-test launch arguments.
  Specifically prove `-uiTestReset` and any test-only flags are inert in Release. Set/verify version
  1.0 and an incremented build number under the team’s convention.
- **Dependencies / non-scope:** can run before T1; T6 consumes output. No feature work.
- **Acceptance / verification:**
  - [ ] Release archive builds with warnings/errors reviewed and no debug/test reset path active.
  - [ ] Version/build values match the intended upload and are documented.
  - [ ] Privacy manifest and app icon/launch behavior are included in the archive.
  - [ ] Attach archive validation and a short release-config checklist.

## T4 — Complete App Store privacy nutrition labels

- **Type / label / estimate / risk:** Task · `LEGAL` · 0.5 day · MED.
- **User story:** As an App Store user, I receive an accurate disclosure of what Hindsight collects
  and how it is used.
- **Why:** labels are required before upload and false disclosures are a compliance risk.
- **Implementation:** audit the shipped target only: SwiftData is local, notifications are local,
  and no analytics/backend/third-party SDK should be claimed unless present. Reconcile labels with
  `Hindsight/PrivacyInfo.xcprivacy`, actual dependencies, and T5’s policy; enter labels in App
  Store Connect and record the decision.
- **Dependencies / non-scope:** T1; re-audit if new SDKs are added. This is not legal advice.
- **Acceptance / verification:**
  - [ ] Every disclosure has a code/dependency basis and policy wording aligns.
  - [ ] No unimplemented collection or tracking is declared; no real collection is omitted.
  - [ ] Capture review evidence/date/owner without exporting account secrets.

## T5 — Write and host a public privacy policy

- **Type / label / estimate / risk:** Task · `LEGAL` · 1 day · MED.
- **User story:** As an external tester, I can read a stable, public explanation of Hindsight’s data
  handling before installing the app.
- **Why:** external TestFlight requires a public policy URL; local-first claims must be precise.
- **Implementation:** write concise policy covering data stored on device, notifications,
  export/delete behavior, demo data, no current backend/analytics, contact method, effective date,
  and update process. Host at a durable public HTTPS URL controlled by the team and link it in App
  Store Connect. Have qualified counsel/owner approve it.
- **Dependencies / non-scope:** none, blocks T8. Do not represent future social/voice behavior as
  shipped behavior.
- **Acceptance / verification:**
  - [ ] URL is public, HTTPS, mobile-readable, and not a temporary local/document-preview link.
  - [ ] Content matches the released binary and nutrition labels.
  - [ ] Legal/product owner sign-off and published URL are recorded.

## T6 — Produce first archive, upload, and invite internal testers

- **Type / label / estimate / risk:** Task · `OPS` · 1 day · HIGH.
- **User story:** As an internal tester, I receive the Build 1 TestFlight build on my device.
- **Why:** the first upload validates the real distribution pipeline before voice or external review.
- **Implementation:** after T2–T4 and M1 release gate, archive Release in Xcode, validate, upload
  to App Store Connect, wait for processing, add the internal tester group, add release notes, and
  install on at least one physical device. Follow Apple’s errors rather than mutating configuration
  blindly; increment build only for a new archive.
- **Dependencies / non-scope:** T2/T3/T4 plus M1 acceptance. External testing is T8.
- **Acceptance / verification:**
  - [ ] App Store Connect shows a processed build with correct version/build.
  - [ ] At least one internal tester receives, installs, launches, captures, and resolves a test
    prediction on a physical device.
  - [ ] Record archive time, build number, processing/upload result, device/OS, and blocking errors
    if any.

## T7 — Prepare TestFlight description and feedback route

- **Type / label / estimate / risk:** Task · `MKT` · 0.5 day · LOW.
- **User story:** As a tester, I know what to try, what is unfinished, and how to report useful
  feedback.
- **Why:** vague beta invitations produce vague feedback and obscure the core activation question.
- **Implementation:** draft TestFlight “What to Test,” beta description, known limitations, privacy
  expectation, and a monitored feedback email/route. Center the script on capture-under-ten-
  seconds and resolve-within-14-days; do not promise voice, social, cloud sync, or production
  support.
- **Dependencies / non-scope:** T1/T6. No public marketing campaign.
- **Acceptance / verification:**
  - [ ] Copy names the target user behavior, feedback route, known limitations, and build version.
  - [ ] Feedback destination is owned/monitored and has a response expectation.
  - [ ] Product/ops review confirms claims match Build 1.

## T8 — Submit Build 1 for external TestFlight review

- **Type / label / estimate / risk:** Task · `OPS` · 0.5 day · MED.
- **User story:** As an invited external tester, I can receive the beta after Apple’s review.
- **Why:** external feedback broadens validation after the internal pipeline is boring.
- **Implementation:** after a stable internal build, T5 policy URL, T6 processing, and T7 copy,
complete export-compliance/beta metadata truthfully, select the correct build, submit for Beta App
Review, monitor status, and record any rejection verbatim with a CR if scope changes.
- **Dependencies / non-scope:** T5/T6/T7. Do not submit a build with unresolved release blockers.
- **Acceptance / verification:**
  - [ ] Submission metadata, privacy URL, contact, and test instructions are complete and accurate.
  - [ ] Review status and timestamps are recorded; any rejection has an owner and documented next
    action.
  - [ ] On approval, an external tester can redeem/install the selected build; no public App Store
    release occurs in this task.

---

## Jira field values to use when configuration is repaired

| Task ID | Parent Epic | Label | Baseline / Current Est | Risk |
|---|---|---:|---:|---|
| M1.1–M1.10 | Build 1 — Quick Capture MVP | as listed | 3, 1, 1, 1, 1, 3, 2, 1, 3, 2 | MED, LOW, LOW, MED, MED, MED, LOW, MED, MED, MED |
| T1–T8 | TestFlight Release Track | as listed | 0.5, 0.5, 1, 0.5, 1, 1, 0.5, 0.5 | LOW, MED, MED, MED, MED, HIGH, LOW, MED |

Set `Task ID`, `Baseline Est`, `Current Est`, `Risk`, `Labels`, description, and parent epic.
Leave `Actual` and `Delay Cause` empty until completion. All issues begin `To Do`.
