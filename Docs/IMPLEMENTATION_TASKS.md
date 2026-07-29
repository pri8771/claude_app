> ## ⚠️ SUPERSEDED — do not follow
>
> This is the 22-task Call/Receipt/Brier pivot plan. **The pivot was reverted on 2026-07-28**
> (`CHANGE_REQUEST_LOG.md` CR-000a). The code is archived on `archive/call-pivot-complete`.
> Current plans: `MVP_PLAN.md` and `POST_MVP_MASTER_PLAN.md`. Kept for reasoning only.

# Implementation Tasks — Call Ledger Pivot (v4 — final)

**STATUS: RATIFIED**
**Authors:** Claude (draft v2 incorporating Codex Round 1 review), Codex (ratification pending)
**Branch policy:** all work on `dev`; merge to `qa` only when the phase's tests pass; no broad release until beta gates in the converged plan.
**Source specs:** `Docs/pairs/PAIR_ENG.md`, `PAIR_PM.md`, `PAIR_QA.md`, `PAIR_GROWTH.md`; converged plan in `Docs/CODEX_CRITIQUE_INTERCHANGE.md`.

## Rules for implementing agents

- Each task is self-contained: files, change, acceptance. Read only the cited spec sections; do not scan the repo beyond the named files.
- A task is done only when its acceptance bullets pass (build + named tests). Passing code alone is insufficient where T22 requires evidence.
- Phases are sequential; tasks inside a phase are parallel-safe **only** where no `Depends:` line says otherwise.
- Ratified overrides of PAIR_PM.md: **confidence has NO default** (Save disabled until an explicit selection); notification permission uses the **soft-ask** contract in T10 (not "after 3rd seal" as the hard prompt).
- Test destination: never hardcode a device name. Resolve at run time: pick the first available iPhone from `xcrun simctl list devices available`, or use the scheme's default. 
- Commit per task on `dev` with message `[T<n>] <title>`.

---

## Phase 0 — Test infrastructure

### T1: Create HindsightTests target
- **Files:** `Hindsight.xcodeproj/project.pbxproj` (new synchronized group for `HindsightTests/`), new `HindsightTests/` with `Tests/Unit/Math/`, `Tests/Unit/Resolution/`, `Tests/Integration/`; `TestStore.swift` fixture helper (in-memory ModelContainer, schema mirroring `SampleData.previewContainer`, Hindsight/Managers/SampleData.swift:195).
- **Accept:** `xcodebuild test -scheme Hindsight` against a resolved available simulator runs the placeholder test green.

---

## Phase 1 — Bug fixes (launch blockers; Depends: T1)

### T2: Kill preselected-"Correct" verdict
- **Files:** `Hindsight/Views/OutcomeReviewView.swift` (seed :185, persist :214).
- **Change:** Pending predictions seed **no verdict entry** (nil); chips render unselected. On save, an ungraded prediction stays `.pending` — never coerced. Saving with ungraded predictions is allowed.
- **Accept:** Write + pass `testResolution_newCallHasNoPreselectedVerdict`, `testResolution_allowsOneTerminalChoice` (PAIR_QA 6–7 semantics applied to predictions for now). Manual: save review untouched → predictions remain Pending.

### T3: Demo-data identity — provenance only
- **Files:** `Hindsight/Managers/SampleData.swift` (:21, :165, :173).
- **Change:** `isDemoDecision` matches **stable demo UUIDs only**. Delete `legacyDecisionTitles` and every title-based path. **No heuristic cleanup of legacy records** — an orphaned old demo record is acceptable; deleting a real user record is not. (The `isDemo` provenance flag and demo-insert wiring arrive in T7, not here.)
- **Accept:** `testDemoCleanup_deletesOnlyExplicitDemoProvenance` (PAIR_QA 11): user decision titled identically to a sample survives removal.

### T4: Recoverable store open
- **Files:** `Hindsight/HindsightApp.swift` (:20–:27), new `Hindsight/Managers/StoreBootstrap.swift`.
- **Change:** Throwing bootstrapper replaces `fatalError`. On failure: store files untouched; recovery screen with Retry / Export store files via share sheet / Reset (destructive, double-confirm).
- **Accept:** `testStoreOpenFailureIsRecoverable` (PAIR_QA 9) via injected failing configuration; no crash path remains.

### T5: Persistence boundary — no silent saves
- **Depends:** T2, T3 (same files; do not parallelize).
- **Files:** all `try? context.save()` sites — `OutcomeReviewView.swift:222`, `NewDecisionWizard.swift:129`, `SettingsView.swift:326`, `DecisionDetailView.swift:292,:299,:307`, `SampleData.swift` save sites; new `Hindsight/Managers/Persisting.swift`.
- **Change:** Define an injectable `protocol Persisting { func save(_ context: ModelContext) throws }` with the production implementation and a test double. All save sites route through it. **On failure:** the screen stays open, the draft/state is preserved, no success haptic fires, no dismissal occurs, no notification is scheduled or cancelled, and a retryable non-blocking alert is shown. Success-side effects run only after a successful save.
- **Accept:** Unit tests with the failing double prove: wizard save failure keeps the sheet open with the draft intact and schedules nothing; review save failure keeps the form and cancels no reminders. Grep: zero `try? context.save()` in `Hindsight/`.

### T6: Cold-launch notification deep link
- **Files:** `Hindsight/Views/MainTabView.swift` (:45–:53).
- **Change:** Consume `tappedDecisionID` in the initial `.task` as well as `.onChange`; shared `route(to:)` helper.
- **Accept:** Terminated-app notification tap opens the target detail screen (manual + UI test where feasible).

---

## Phase 2 — Call model, write boundary, migration (Depends: Phase 1; strictly T7 → T8 → T9)

### T7: Complete additive Call schema (final — no follow-up migrations)
- **Files:** new `Hindsight/Models/Call.swift`; `Hindsight/Models/Decision.swift` (optional `calls` relationship); `Hindsight/Managers/SampleData.swift` (demo inserts set `isDemo = true`); `StoreBootstrap.swift` (register).
- **Change:** `@Model final class Call` with the FULL field set now: `id: UUID`, `statement`, `confidence: Int` (**stored range 0–100** to hold legacy data faithfully; new capture restricted to 51–99 at the UI/service layer), `resolveBy`, `capturedAt`, `sealedAt?`, `resolution?` (`happened, didNotHappen, partly, cantResolve`), `resolutionAt?`, `learningNote?`, provenance (`source: user|migrated|demo`), `legacySourceID?`, void linkage (`voidedAt?`, `voidReason?`, `replacementID?`), receipt fields (`sealPostURL?`, `sealPostConfirmedAt?`, `revealPostURL?`, `revealPostConfirmedAt?`, `platform?`), `migrationAuditNote?`. Also add `isDemo: Bool = false` to **Decision** (backs T3's provenance flag). Acquisition cohort is NOT a Call field — it is a single global value (see T19). Nothing existing renamed or removed.
- **Accept:** Build passes; existing store relaunch test (PAIR_QA 14) green; schema review checklist in PR description lists every field above; test: new demo inserts have `isDemo == true`, pre-existing real records default to `false`.

### T8: Seal & resolution write boundary
- **Depends:** T7.
- **Files:** new `Hindsight/Managers/CallStore.swift`; `Call.swift`.
- **Change:** Enforcement via **access control + validated transitions on the model itself**: Call's sealed properties have `private(set)` backing state, and Call exposes validated transition methods beside that state — `seal(...)`, `resolve(...)` (nil→value exactly once), `void(reason:replacement:)`, and idempotent `recordSealReceipt(url:platform:at:)` / `recordRevealReceipt(url:at:)` (repeat calls with the same URL are no-ops; conflicting URLs rejected). `CallStore` orchestrates these transitions (fetch, invariants, persistence via T5's `Persisting`) — it never writes fields directly. **Deleting an entire Call remains possible** (user data ownership). `partly`/`cantResolve` are terminal non-scoring states — no follow-up question (converged plan §4: Partly never scores; it feeds coaching only).
- **Accept:** `testCallMetadata_isImmutableAfterSave` (compile-level: no external setter exists; runtime: service rejects second resolution); delete path test; void chain test; receipt-transition tests: same-URL repeat is a no-op, conflicting URL rejected, **reveal confirmation before a terminal resolution rejected**.

### T9: Prediction→Call migration
- **Depends:** T7, T8.
- **Files:** new `Hindsight/Managers/CallMigration.swift`; invoked from `StoreBootstrap` after successful open.
- **Change:** Migrate **Predictions only** — each `Prediction` → one `Call` (`statement`=title, `confidence`=probabilityPercent **unchanged, 0–100 preserved**, `resolveBy`=dueDate, resolution mapped from status, `source=migrated`, `legacySourceID`=prediction UUID, linked to owning Decision). **Decisions without predictions remain Decisions — no fabricated Calls.** Backup contract: backup runs **before the live container opens** (bootstrapper order: locate store → file-coordinated copy of `.sqlite`+`-wal`+`-shm` while no container holds it → open → migrate); validation (counts + required fields) before stamping the migration version; on failure discard context, restore the set atomically, retry next launch; idempotent via version flag; backup retained until next successful launch.
- **Accept:** `testMigration_preservesDecisionsCallsRelationshipsAndResolutions` (PAIR_QA 10) + interruption fixture + double-run idempotency + a legacy 30%-confidence prediction arrives as 30, not 51.

---

## Phase 3 — Capture, resolve, surfaces (Depends: Phase 2)

### T10: One-sheet Call capture
- **Depends:** T8.
- **Files:** new `Hindsight/Views/NewCallSheet.swift`; "+" entry points in `TodayView.swift`, `AllDecisionsView.swift`.
- **Change:** PAIR_PM.md contract with ratified overrides: statement 10–280 chars (trim; <15 chars non-blocking "make it testable" hint); confidence chips 55/65/75/85/95 + fine-tune 51–99, **no default, Save disabled until chosen**; resolveBy chips 2d/1w/1m/custom (default +30d). Save → `CallStore.seal` → **persisted seal confirmation view** (sealed values + timestamp; no share UI — the Receipt share entry point arrives in T18). **Permission contract (ratified):** after the FIRST successful seal, show an in-app soft-ask card with the actual resolve date ("Remind me Aug 26"); only tapping "Enable reminders" triggers the OS prompt; "Not now" does not consume OS authorization; soft-ask may reappear once after the 3rd seal and always lives in Settings.
- **Accept:** PM QA "Core flow"/"Validation"/"Immutability" boxes; UI tests 15–16; soft-ask unit test (OS prompt not invoked on "Not now").

### T11: Resolve card stack
- **Depends:** T8.
- **Files:** new `Hindsight/Views/ResolveStackView.swift`; `NotificationManager.swift` (per-Call scheduling, deep link into stack).
- **Change:** Due-call stack; four verdict buttons, nothing preselected; one tap commits + auto-advance; optional post-verdict learning line. `Partly`/`Can't-resolve` commit as-is (non-scoring) with a one-line coaching note; **no forced binary follow-up**. Reminders keyed by stable Call UUID; cancel idempotent.
- **Accept:** PAIR_QA 12, 13, 18.

### T12: Call product surfaces
- **Depends:** T7.
- **Files:** `TodayView.swift`, `AllDecisionsView.swift`, new `Hindsight/Views/CallDetailView.swift`.
- **Change (specified — do not re-decide):** History surface gets a `Calls | Decisions` segmented control, **defaulting to Calls**. Today shows actionable Calls (due/overdue) first, legacy Decisions in a separate section below. Search applies to the active segment only. Call detail route shows sealed fields, resolution state, void chain, receipt links. Empty/loading states included.
- **Accept:** UI test 17 semantics extended to Calls; a sealed Call is reachable and readable end-to-end without touching Decision UI.

### T13: Wizard sunset + onboarding contract
- **Depends:** T10.
- **Files:** `MainTabView.swift`, entry CTAs, `Hindsight/Views/Onboarding/*`.
- **Change:** All primary "+"/CTA paths open `NewCallSheet`. Wizard reachable only from legacy Decision detail. **Onboarding replaced** per converged contract: short value screen → straight into first Call capture (not a retargeted carousel); replay-onboarding in Settings still works.
- **Accept:** UI test 19; no primary path reaches the 4-step wizard; first-launch flow ends with the capture sheet open.

### T14: Data ownership includes Calls
- **Depends:** T7.
- **Files:** `Hindsight/Managers/ExportManager.swift`, `SettingsView.swift` (clear-all, demo removal).
- **Change:** JSON and PDF exports include Calls (all fields incl. resolution, void chain, receipt URLs); clear-all deletes Calls; demo removal covers demo-flagged Calls; relaunch persistence covers Calls.
- **Accept:** Export fixture test asserts exact serialization: a sealed+resolved Call with a void chain and receipt URLs produces JSON whose decoded fields equal the source values field-by-field (statement, confidence, resolveBy, capturedAt, sealedAt, resolution, resolutionAt, voidReason, replacementID, sealPostURL, revealPostURL). Import is out of scope. PDF export test: rendered PDF for a fixture containing a representative Call succeeds and its text extraction contains the Call's statement, confidence, resolve-by date, and verdict. Clear-all leaves zero Call rows.

### T15: Draft preservation + notification privacy
- **Depends:** T10.
- **Files:** `NewCallSheet.swift`, `NotificationManager.swift`.
- **Change:** Interrupted capture (backgrounding, accidental dismiss) preserves the draft and offers restore on next open; explicit Cancel with non-empty statement asks once. Notification bodies are **content-free by default** ("A call is ready to resolve") with an opt-in "show statement in reminders" toggle in Settings.
- **Accept:** Draft-restore unit test; default-scheduled notification contains no statement text.

---

## Phase 4 — Honest insights (Depends: Phase 2; parallel with Phase 3)

### T16: Scoring engine + gates (exact fixtures)
- **Depends:** T7.
- **Files:** new `Hindsight/Managers/Scoring.swift`; `InsightsView.swift`; prune `Statistics.swift`.
- **Change:** Brier over scored calls only (`happened`/`didNotHappen`); `partly`/`cantResolve`/pending/voided excluded. **Bins (inclusive):** 51–65, 66–85, 86–99. Gates: Brier n≥10; **neutral per-bin facts** (counts, mean confidence, observed rate) at bin n≥10; **directional "you tend to…" text for a bin only at bin n≥30 AND its 95% Wilson score interval for the observed outcome rate lies wholly above or wholly below the bin's mean stated confidence.** Overall directional claim requires ≥2 bins meeting that rule with the same direction. Below gates: raw counts + "resolve N more" copy. Delete invalid hit-rate and all sub-threshold pattern claims.
- **Golden fixtures (normative):**
  - Brier: outcomes [Yes, No, Yes] at confidences [0.80, 0.60, 0.51] → mean((0.8−1)², (0.6−0)², (0.51−1)²) = **0.2133666667** (±1e-9).
  - Bins: 10 calls at [55×5, 60×5] with 6 Yes → bin 51–65 shows mean confidence 57.5%, observed 60%; 10 at [70×5, 80×5] with 7 Yes → 75% vs 70%; 10 at [90×5, 95×5] with 8 Yes → 92.5% vs 80%.
  - Gating: n=29 scored → no directional claim. Bin with n=30, mean stated confidence 90%, 18 observed Yes (60%; Wilson 95% ≈ [42.3%, 75.4%], wholly below 90%) → bin claim "overconfident" permitted. Bin with n=30, mean stated 75%, 21 observed Yes (70%; Wilson 95% ≈ [52.1%, 83.3%], **crosses** 75%) → **no claim** despite n=30. Overall claim only when ≥2 qualifying bins agree in direction.
- **Accept:** PAIR_QA 1–5 implemented against these exact numbers.

### T17: Integrity panel + lesson resurfacing
- **Depends:** T16, T11.
- **Files:** `InsightsView.swift`, `ResolveStackView.swift`.
- **Change:** Panel (n≥5 due): % resolved ≤72h, cantResolve rate, partly rate, void rate. Per-call reveal shows stated confidence vs outcome; resurfaces `mainLesson`/learning notes from the linked Decision/Call when present.
- **Accept:** Unit test per rate; reveal shows lesson for a fixture that has one.

---

## Phase 5 — Receipts & instrumentation (Depends: T8's transition tests green + T10, T11, T12; runs in PARALLEL with Phase 4 — no dependency on T16/T17)

### T18: Timestamped Receipt cards + share flow
- **Depends:** T8, T10, T11, **T12** (edits Call detail).
- **Files:** new `Hindsight/Views/ReceiptCardView.swift`, `Hindsight/Managers/ReceiptRenderer.swift`.
- **Change:** PAIR_GROWTH.md spec: seal card, reveal card, dignified miss templates; 4-tap flow with post-share "Did you publish it?" confirm/skip; persistence via T8's idempotent `recordSealReceipt`/`recordRevealReceipt` transitions. **This task adds the share entry points:** a "Share receipt" affordance on the post-seal confirmation view (extending T10's screen) and a share action on Call detail (T12's screen). **Honesty constraint:** URL entry is user attestation — validate syntax only; UI copy never claims verification that the post exists ("your link, your receipt").
- **Accept:** Both card states render at share quality; URL syntax validation tests; no copy implies cryptographic proof or link verification.

### T19: Beta instrumentation (local, content-free)
- **Depends:** T7 (source/horizon/void fields), T18 (receipt counters).
- **Files:** new `Hindsight/Managers/BetaSnapshot.swift`; Settings row "Export beta snapshot".
- **Change:** Local-only snapshot export (JSON via share sheet), **content-free**: counts and rates only — activated (≥1 sealed call), **`eligibleCallCount`** (a precisely defined proxy, NOT "meaningful calls": `source == user` AND horizon 24h–30d at seal AND not voided; the snapshot documents that this proxy cannot certify semantic quality or detect duplicates), due/resolved counts, resolution-discipline rate, seal/reveal URL confirmation counts, cohort code, and every denominator. No statements, no notes. Cohort assignment happens **outside the app** (TestFlight group → user enters a cohort code once at first launch, stored as a single global value in UserDefaults via `AppStorageKeys`; snapshots read that global — not a per-Call field).
- **Accept:** Snapshot fixture contains zero user text; all rates ship with denominators; `eligibleCallCount` rule unit-tested (voided/migrated/out-of-horizon calls excluded); global cohort code set once and present in every snapshot.

---

## Phase 6 — Hardening & evidence (Depends: all)

### T20: Complete PAIR_QA.md suite
- **Change:** Implement all 19 named tests not already written; UI smoke 15–19 in `HindsightUITests`.
- **Accept:** Full suite green on a resolved available simulator.

### T21: Accessibility pass
- **Files:** `NewCallSheet.swift`, `ResolveStackView.swift`, `HindsightComponents.swift` (HStarRating), toolbar buttons.
- **Change:** VoiceOver labels/values/traits everywhere interactive; `.adjustable` on confidence/rating; 44pt targets; validation messages announced.
- **Accept:** Accessibility Inspector audit of capture→resolve→insights shows no unlabeled interactive elements.

### T22: Factory evidence (cross-cutting — NOT a Phase 6 task)
- **Scope:** T22 has no dependency line; it is a standing obligation. **Each phase's merge to `qa` gates on that phase's own evidence update** — a phase is not complete until its entry exists.
- **Files:** `quality/feature-contracts/`, `quality/completion-reports/`, `quality/evidence/`, `Docs/STATUS.md`, `Docs/BUGS.md`.
- **Change:** At each phase boundary: write/update the feature contract for what shipped, a completion report naming exactly which checks ran and which did not, and evidence links (test output, screenshots). HIND-B01/B02 statuses updated when addressed. `code_complete` vs `done` honored.
- **Accept:** No phase merges to `qa` without its contract + completion report + evidence entry; STATUS.md "Verified/Verification pending" reflects reality at every phase boundary.

---

## Resolution of Codex Round 1 items
- Open item 1 (permission): adopted verbatim → T10.
- Open item 2 (no-default confidence): ratified → T10.
- Open item 3 (instrumentation): adopted → T19.
- T3 heuristic cleanup: deleted (provenance/UUID only).
- T5: injectable protocol + failure-behavior acceptance → adopted.
- T7 complete-schema-now, T8 ordering, no-clamp migration, Predictions-only, closed-store backup: adopted → T7/T8/T9.
- Assertions→access control; Call deletion preserved: adopted → T8.
- Forced binary follow-up removed: adopted → T11.
- Exact bins + golden fixtures + claim-gating test: adopted → T16.
- Receipts attestation framing + parallelization: adopted → T18/Phase 5 gating.
- Missing tasks 1–5: added as T12, T14, T15, T13 (onboarding), T22.
- Hardcoded simulator destination: replaced with resolved-at-runtime rule.
