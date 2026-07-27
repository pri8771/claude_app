# Pair Task: Test target & test plan

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
Produce: the XCTest target structure and the prioritized test list — Brier/bin math golden values, resolution state machine (no preselection), migration preservation, demo-data removal safety, notification schedule/cancel, relaunch persistence, and the 5 highest-value UI smoke tests. Deliverable = concrete test names with given/when/then one-liners.

## Claude Worker (Round 1)

**XCTest Target Structure:**
Create single `HindsightTests` target (no separate UI target; smoke tests co-located). Structure:
- `Tests/Unit/` — math, state machine, data
- `Tests/Integration/` — store, migrations, notifications
- `Tests/Smoke/` — UI interactions

**Prioritized Test List (19 critical):**

*Math & Insights (5):*
1. `test_brier_score_2outcome_golden` — Given n=2 calls with known outcomes, when computed, then Brier = 0.0
2. `test_brier_score_imperfect_golden` — Given n=12 mixed outcomes, when computed, then Brier ≈ 0.182
3. `test_calibration_bin_assignment` — Given 51-99% confidence calls, when binned (0-40%, 40-60%, 60-100%), then count distribution matches golden vector
4. `test_calibration_min_threshold_enforced` — Given n<10 total or n<10 per bin, when insights requested, then calibration omitted
5. `test_directional_claim_n30_threshold` — Given n=29 calls, when directional insights requested, then nil; n=30 returns claim

*Resolution State Machine (4):*
6. `test_preselection_verdict_ignored` — Given Call saved with UI-preselected "Correct", when state persisted, then verdict = nil (unresolved)
7. `test_resolution_yields_never_scored` — Given resolved Yes/No/Partly, when Brier/insights computed, then all included; Can't-resolve excluded
8. `test_state_transition_guard_reresolution` — Given Call already resolved Yes, when user attempts resolve No, then transition denied (read-only after seal)
9. `test_metadata_sealed_on_save` — Given Call saved, when editable fields accessed post-seal, then immutable exception raised

*Data Preservation (2):*
10. `test_migration_legacy_decision_container_preserved` — Given v1 SwiftData with nested Decision, when v2 schema applied, then Call extracted and Decision retained (no deletion)
11. `test_demo_data_removal_noop_on_empty` — Given empty store, when demo-cleanup triggered, then no exception; n=5 demo items deleted, user items untouched

*Notifications & Relaunch (3):*
12. `test_notification_schedule_cancel_idempotent` — Given scheduled notification, when cancellation called twice, then no error
13. `test_relaunch_restores_call_list` — Given 8 saved Calls, when app killed and relaunched, then all 8 displayed (no loss)
14. `test_notification_resolve_by_date_fires` — Given Call with resolve-by = tomorrow, when notification fired, then foreground/background both handled

*UI Smoke (5):*
15. `smoke_capture_sheet_flow_complete` — Given home screen, when tap capture, fill statement, set confidence 75%, tap save, then Call appears in list
16. `smoke_call_detail_load_no_crash` — Given 10 Calls in list, when tap each, then detail loads without fatalError
17. `smoke_resolution_sheet_state_updates` — Given unresolved Call open, when select Yes/No/Partly, then resolution card updates
18. `smoke_settings_accessibility_labels_present` — Given Settings screen, when VoiceOver enabled, then all toggles/buttons labeled
19. `smoke_onboarding_final_cta_navigates` — Given first launch, when tap "Start calling", then dismiss to home (not stuck)

## Codex Worker (Round 1)

**XCTest target structure:** use two targets: `HindsightTests` (unit + persistence/integration; `@testable import Hindsight`) and `HindsightUITests` (launch arguments, isolated store, accessibility-driven smoke). Keep test-support factories in the unit target or an app-owned internal test seam; do not co-locate UI tests with unit tests because UI lifecycle and runner permissions differ.

**Priority 0 — correctness / data safety**
1. `testBrierScore_goldenMixedOutcomes` — Given fixed confidences and Yes/No results, when scoring, then mean squared error equals the documented exact golden value.
2. `testBrierScore_excludesPartlyAndCantResolve` — Given Yes, No, Partly, and Can't-resolve calls, when scoring, then only scored Yes/No calls contribute (Partly is diagnostic-only; Can't-resolve tracked/excluded).
3. `testCalibration_threeBins_goldenRates` — Given 10 eligible calls in each defined confidence bin, when calibration is calculated, then each bin's count, mean confidence, and observed Yes rate equal golden values.
4. `testResolution_newCallHasNoPreselectedVerdict` — Given a newly saved sealed Call, when resolution opens, then no verdict is selected and Call remains unresolved.
5. `testResolution_allowsOneTerminalChoice` — Given an unresolved Call, when Yes/No/Partly/Can't-resolve is chosen, then its terminal resolution persists and a second choice is rejected.
6. `testMigration_preservesDecisionsAndCalls` — Given a fixture of pre-pivot Decisions and their Calls, when migrated, then all user records/relationships and resolution data remain with no duplicate or deleted records.
7. `testDemoCleanup_deletesOnlyExplicitDemoIdentity` — Given demo and user calls with identical titles/statements, when cleanup runs, then only records carrying explicit demo provenance are removed.
8. `testStoreOpenFailureIsRecoverable` — Given store initialization fails, when launched, then an actionable recoverable state is presented rather than a fatal crash.

**Priority 1 — lifecycle / reminders**
9. `testReminder_scheduleUsesStableCallIdentifier` — Given a saved Call with resolve-by date, when scheduled, then one request uses its stable ID and correct trigger.
10. `testReminder_cancelRemovesPendingRequest_idempotently` — Given a scheduled or absent request, when cancelled twice, then no request remains and no error occurs.
11. `testPersistence_relaunchRetainsSealedCallAndResolution` — Given a saved/resolved Call, when its store is reopened, then immutable capture fields and resolution match exactly.

**Five UI smokes:** `testCapture_threeTapSaveShowsCall`; `testCapture_requiresStatementConfidenceAndDate`; `testDetail_openDoesNotCrash`; `testResolve_startsUnselectedThenPersistsYes`; `testOnboardingCTA_reachesHome` — each launches with a clean store and asserts visible accessible identifiers.

## Claude Worker (Round 2)

Codex's two-target split (HindsightTests + HindsightUITests) is correct: UI lifecycle and permissions differ fundamentally from unit tests, and co-location hides that. Accept it. Also, Codex's naming (`testBrierScore_*` vs `test_brier_score_*`) is more consistent with XCTest convention and reads better in IDE jump-to-test.

**Adoptions from Codex:**
1. Two targets with clear responsibility: unit/integration in HindsightTests (via `@testable import`), UI smokes in HindsightUITests (launch args, isolated store).
2. Priority 0 (correctness/data safety) + Priority 1 (lifecycle/reminders). Clearer than my monolithic 19-item list.
3. Test naming: `testSubject_action_expectation` style.
4. **Critical add**: Codex includes `testStoreOpenFailureIsRecoverable` — a known launch blocker. Must keep.

**Gaps in Codex that Claude clarifies:**
1. Brier/calibration have multiple golden-value tests. Codex `testBrierScore_goldenMixedOutcomes` + `testBrierScore_excludesPartlyAndCantResolve` cover scope, but Claude's `test_brier_score_imperfect_golden` with n=12 and exact ≈ 0.182 is a concrete assertion. **Keep both; they're not duplicative** — one tests the Yes/No filter logic, the other tests the math against a fixture.
2. Calibration: Codex's `testCalibration_threeBins_goldenRates` is solid, but it needs an explicit test for "n<10 per bin → omitted" (Claude's `test_calibration_min_threshold_enforced`). Codex doesn't state the threshold guard. **Add it as Priority 0**.
3. Directional claims (n≥30): neither fully explicit. Codex doesn't list it; Claude does. **Add as Priority 0**.
4. Five UI smokes: Codex names five concretely. Claude lists five with more verbose given/when/then. Codex's list is tighter; adopt it.

**Merged Priority 0 (Correctness, 9 tests):**
1. testBrierScore_goldenMixedOutcomes
2. testBrierScore_excludesPartlyAndCantResolve
3. testBrierScore_imperfectN12_appx0p182
4. testCalibration_threeBins_goldenRates
5. testCalibration_minThreshold_n10BinEnforced
6. testDirectionalInsight_n30Threshold
7. testResolution_newCallHasNoPreselectedVerdict
8. testResolution_allowsOneTerminalChoice
9. testStoreOpenFailureIsRecoverable

**Merged Priority 1 (Lifecycle, 6 tests):**
10. testMigration_preservesDecisionsAndCalls
11. testDemoCleanup_deletesOnlyExplicitDemoIdentity
12. testReminder_scheduleUsesStableCallIdentifier
13. testReminder_cancelRemovesPendingRequest_idempotently
14. testPersistence_relaunchRetainsSealedCallAndResolution
15. testCallMetadata_sealedOnSave

**UI Smokes (5 tests, HindsightUITests target):**
16. testCapture_threeTapSaveShowsCall
17. testCapture_requiresStatementConfidenceAndDate
18. testDetail_openDoesNotCrash
19. testResolve_startsUnselectedThenPersistsYes
20. testOnboardingCTA_reachesHome

**Structure:** HindsightTests (`Tests/Unit/Math`, `Tests/Unit/Resolution`, `Tests/Integration/`); HindsightUITests (no subdirs, flat list with launch args). **Deliverable: test names + one-liner given/when/then in next round.**

## Codex Worker (Round 2)

Claude's merge is sound: two targets, recoverable store-open coverage, explicit calibration and n=30 gates, and provenance-based demo deletion are all required. Two revisions are needed before finalizing.

1. Do not encode an unsubstantiated Brier golden value such as “≈0.182.” A golden test must state its fixture and exact expected result; otherwise it can bless an incorrect convention. Use `testBrierScore_goldenFixture_exactMeanSquaredError` — Given outcomes `[Yes, No, Yes]` and confidences `[0.80, 0.60, 0.51]`, when Brier is calculated as mean `(p-y)^2`, then it is exactly `(0.04 + 0.36 + 0.2401) / 3 = 0.2133666667` (with a tight floating-point accuracy).
2. “Partly never scored” must be unambiguous. Rename the filter test to `testBrierScore_excludesPartlyAndCantResolve` — Given one Yes, one No, one Partly, and one Can't-resolve, when Brier and diagnostic counts are computed, then only Yes/No enter Brier, Partly increments diagnostic-only count, and Can't-resolve increments excluded count.

**Revised prioritized specification:**

- P0 math/insights: `testBrierScore_goldenFixture_exactMeanSquaredError`; `testBrierScore_excludesPartlyAndCantResolve`; `testCalibration_threeBins_goldenRates` — Given 10 eligible calls per agreed bin, when calculated, then counts/mean confidence/Yes rate equal fixture values; `testCalibration_omitsBinBelowTen`; `testDirectionalInsight_requiresThirtyScoredCalls`.
- P0 state/data safety: `testResolution_newCallHasNoPreselectedVerdict`; `testResolution_allowsOneTerminalChoice`; `testCallMetadata_isImmutableAfterSave`; `testStoreOpenFailureIsRecoverable`; `testMigration_preservesDecisionsCallsRelationshipsAndResolutions`; `testDemoCleanup_deletesOnlyExplicitDemoProvenance` (including identical user/demo text).
- P1 lifecycle: `testReminder_scheduleUsesStableCallIdentifier`; `testReminder_cancelIsIdempotent`; `testPersistence_relaunchRetainsSealedCallAndResolution`.
- `HindsightUITests` (clean isolated store; accessibility IDs): `testCapture_threeTapSaveShowsCall`; `testCapture_requiresStatementConfidenceAndDate`; `testDetail_openDoesNotCrash`; `testResolve_startsUnselectedThenPersistsYes`; `testOnboardingCTA_reachesHome`.

For every listed test, final text should retain the Given/When/Then wording above and make notification assertions inspect pending requests rather than attempting to fire system notifications.

## Claude Worker (Round 3)

**Converged acceptance of Codex Round 2 refinements:**

Codex's two critiques are both essential:

1. **Golden-value rigor**: The "≈0.182" placeholder in my Round 2 was imprecise and risks blessing an incorrect constant. Codex's format — Given explicit fixture `[Yes, No, Yes]` with confidences `[0.80, 0.60, 0.51]`, Then exact MSE `0.2133666667` — grounds the test in reproducible math. Accept and adopt this for Brier test.

2. **Partly/Can't-resolve clarity**: Renaming to `testBrierScore_excludesPartlyAndCantResolve` with Given/When/Then explicitly stating count increments (diagnostic vs. excluded) removes ambiguity. Accept this rename and wording.

**Final structure convergence:**

- **Two targets**: HindsightTests (unit + integration via `@testable import`); HindsightUITests (isolated store, accessibility launch args).
- **Test organization**: HindsightTests organized into `Tests/Unit/Math`, `Tests/Unit/Resolution`, `Tests/Integration/`; HindsightUITests flat.
- **Naming**: `testSubject_action_expectation` (camelCase, readable in IDE).
- **Test count**: 19 tests total (5 P0 math/insights + 6 P0 state/data + 3 P1 lifecycle + 5 UI smokes).
- **Notification assertions**: Inspect pending UNUserNotificationCenter requests, never attempt to fire system notifications.

**Codex's revised specification is final.** All three sections (P0 math, P0 state/data, P1 lifecycle) and five UI smokes are correct as written in Codex Round 2, lines 131–134. No further changes.

## CONVERGED SPEC

**Target Structure:**
- `HindsightTests`: `Tests/Unit/Math/`, `Tests/Unit/Resolution/`, `Tests/Integration/`
- `HindsightUITests`: flat, no subdirs

**Priority 0 — Math & Insights (5 tests, HindsightTests)**

1. `testBrierScore_goldenFixture_exactMeanSquaredError` — Given outcomes `[Yes, No, Yes]` with confidences `[0.80, 0.60, 0.51]`, when Brier score is calculated as mean `(p-y)^2`, then result is exactly `0.2133666667` (7 decimals, tight float tolerance).

2. `testBrierScore_excludesPartlyAndCantResolve` — Given one Yes, one No, one Partly, one Can't-resolve with valid confidences, when Brier and diagnostic counts are computed, then only Yes/No enter Brier numerator, Partly increments diagnostic-only count, Can't-resolve increments excluded count.

3. `testCalibration_threeBins_goldenRates` — Given 10 calls in [51-60%], 10 in [61-80%], 10 in [81-99%] confidence bins with known Yes outcomes, when calibration is calculated, then each bin's count, mean confidence, and observed Yes rate match golden fixture (exact values TBD per implementation).

4. `testCalibration_omitsBinBelowTen` — Given 8 calls in [61-80%] bin and 12 in [81-99%], when insights requested, then [61-80%] bin omitted from calibration output.

5. `testDirectionalInsight_requiresThirtyScoredCalls` — Given n=29 scored calls, when directional insights requested, then nil; n=30 scored calls, then directional claim returned.

**Priority 0 — State & Data Safety (6 tests, HindsightTests)**

6. `testResolution_newCallHasNoPreselectedVerdict` — Given newly sealed Call in unresolved state, when resolution sheet opens, then no verdict option is pre-selected.

7. `testResolution_allowsOneTerminalChoice` — Given unresolved Call, when user selects Yes, then resolution persists; attempting second choice (No) is rejected.

8. `testCallMetadata_isImmutableAfterSave` — Given sealed Call, when editable fields accessed post-seal, then immutable exception raised.

9. `testStoreOpenFailureIsRecoverable` — Given SwiftData store initialization fails, when app relaunches, then recoverable UI state presented (no fatal crash).

10. `testMigration_preservesDecisionsCallsRelationshipsAndResolutions` — Given v1 fixture with Decisions and nested Calls with resolutions, when v2 schema applied, then all records, relationships, and resolution state survive (no duplicates, no deletion).

11. `testDemoCleanup_deletesOnlyExplicitDemoProvenance` — Given demo Call "Forecast sales" and user Call "Forecast sales" with identical text, when cleanup runs, then only record marked with demo flag is removed.

**Priority 1 — Lifecycle & Reminders (3 tests, HindsightTests)**

12. `testReminder_scheduleUsesStableCallIdentifier` — Given Call with resolve-by date saved, when reminder scheduled, then UNUserNotificationCenter contains request with stable Call UUID as trigger identifier.

13. `testReminder_cancelIsIdempotent` — Given scheduled or absent notification, when cancelled twice, then no error occurs and no pending request remains.

14. `testPersistence_relaunchRetainsSealedCallAndResolution` — Given sealed unresolved Call, when store reopened, then capture fields and resolution state match exactly.

**UI Smoke Tests (5 tests, HindsightUITests)**

15. `testCapture_threeTapSaveShowsCall` — Given home screen, when tap capture, enter statement, tap confidence, tap save, then Call appears in list with accessibility id visible.

16. `testCapture_requiresStatementConfidenceAndDate` — Given capture sheet, when attempt save without statement, then save disabled; all three fields required.

17. `testDetail_openDoesNotCrash` — Given 10 calls in list, when tap each in sequence, then detail loads without fatalError and is accessibility labeled.

18. `testResolve_startsUnselectedThenPersistsYes` — Given unresolved Call detail open, when select Yes resolution, then card updates; relaunch app and reopen same Call, resolution persists.

19. `testOnboardingCTA_reachesHome` — Given first-launch state, when tap "Start calling" CTA, then dismiss onboarding and land on home screen (not stuck).
