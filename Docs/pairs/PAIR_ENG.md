# Pair Task: Migration & integrity engineering plan

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
Produce the engineering plan: (1) fix preselected-Correct verdict bug, (2) fix demo-data title-matching deletion, (3) replace fatalError store-open with recovery path, (4) Decision->Call migration preserving all user data (schema sketch, ordered steps, rollback), (5) seal-immutability enforcement. Deliverable = ordered task list with risk notes per item.

## Claude Worker (Round 1)

**Ordered task list with risk notes:**

**Phase 1: Bug Fixes (Foundation)**
1. **Fix preselected-"Correct" verdict bug** — Investigate why verdict renders preselected post-save. Risk: May expose broader state-persistence issue. Est. 1–2 hrs. Verify: Unit test for verdict-state isolation.

2. **Fix demo-data title-matching deletion** — Trace why demo entries delete on title-substring collision instead of ID match. Risk: Indicates shallow copy or reference issue. Est. 1–2 hrs. Verify: Test demo + user calls with overlapping titles.

3. **Replace fatalError store-open with recovery** — Wrap `@Query`/`ModelContext` init in try-catch, surface recovery UI (reset/restore backup). Risk: Corrupted stores may need manual iCloud reset. Est. 3–4 hrs. Pre-step: add backup-on-launch.

**Phase 2: Data Migration (Critical Path)**
4. **Decision→Call schema** — Sketch: Call(statement, confidence 51–99, resolveBy, sealed, captureTime, timestamp, receiptUrl); Decision(title, calls[], metadata) for backward compat. SwiftData lacks migrations; use predicate-based batch update. Est. 4–6 hrs. Rollback: Retain pre-mutation .sqlite snapshot, restore via iCloud or manual import.

5. **Migration sequence** — (i) Add Call table, scaffold Decision.calls. (ii) Write mapper: Decision→Call(s), preserve resolution. (iii) Validate on prod snapshot. (iv) Dry-run on 3+ test devices. (v) Deploy feature-flagged; users opt-in or auto-migrate first-launch. (vi) Log per-device success/failure to diagnostic store. Est. 8–10 hrs. Post-migration validation: count checks, data-integrity assertions to catch silent failures.

**Phase 3: Immutability Enforcement**
6. **Seal enforcement** — Add sealed: Bool to Call. Post-save, lock sealed=true; block edits via UI + SwiftData read-only guard. Audit-log any direct sealed-field writes. Est. 2–3 hrs.

**Risk roll-up:** Migration is single point of failure (no in-flight rollback). Mitigations: (a) snapshot before migration, (b) staged rollout (beta→prod), (c) one-click manual restore in Settings. Total estimate: 20–26 hrs eng + 8–10 hrs QA.

## Codex Worker (Round 1)

**Ordered engineering plan (local-only):**

1. **Add a regression test target before behavior changes.** Cover persisted-model creation and selection state. Risk: the app currently has no test target, so every migration fix otherwise relies on manual testing; make this the enabling task.

2. **Remove the preselected “Correct” verdict.** Model the resolution draft as an explicit optional value (`nil` until the user taps Yes/No/Partly/Can’t-resolve); initialize a fresh draft whenever the resolve sheet appears, and persist only on confirmation. Never derive an initial verdict from a default enum case. Add tests for reopening a Call and for canceling the sheet. Risk: changing an existing non-optional stored enum can accidentally reinterpret legacy values; map legacy missing/unknown values to unresolved, not Yes.

3. **Fix demo deletion to use stable identity.** Give every demo fixture and user Call a persistent identifier; remove by that identifier (or SwiftData object identity), never title/predicate substring. Scope demo cleanup to an explicit demo marker/source flag. Test identical and overlapping titles. Risk: broad cleanup predicates can delete real local Calls.

4. **Make store opening recoverable.** Encapsulate `ModelContainer` construction in a throwing bootstrapper. On failure, preserve the failing store files, present a recovery screen with: retry, export/copy diagnostic and store backup where possible, and explicit destructive reset after confirmation. Do not silently reset. Risk: a corrupt store may be unreadable, so backup must be best-effort and reset clearly data-lossing.

5. **Introduce additive schema first.** `Call`: UUID, statement, confidence (validated 51...99), resolveBy, capturedAt, sealedAt?, resolution?, legacySourceID?, optional `decision` relationship. Keep `Decision` and its metadata/relationships; add optional `calls`. Avoid deleting/renaming existing persisted fields in the same release. Risk: SwiftData migration compatibility is schema-sensitive.

6. **Run an idempotent Decision→Call migration at bootstrap.** Snapshot the persistent store before mutation; enumerate Decisions in a single context, map each legacy prediction/decision payload to one or more Calls, preserve dates/confidence/resolution/notes and relationships, tag `legacySourceID`, save, then validate counts and required fields. Store a local migration version only after validation. Risk: ambiguous legacy fields require an explicit conservative mapping table; retain originals.

7. **Rollback and release.** If validation/save fails, discard the unsaved context and restore the pre-migration snapshot before reopening; retain snapshot until the next successful launch. Test fixture migrations, interruption, repeat launch/idempotency, and downgrade behavior. Release beta-first.

8. **Enforce sealing at the write boundary.** A Call becomes sealed only through one capture command that validates fields and sets `sealedAt`. Edit/delete and model-update paths reject changes to integrity fields when sealed; UI disabling is only defense-in-depth. Resolution is separately mutable once, with no alteration of the sealed statement/confidence/date. Risk: SwiftData has no intrinsic immutable-field constraint; all mutation paths must route through the domain service.

## Claude Worker (Round 2)

**Merged plan with critique:**

Codex's reordering is correct: **test infrastructure first is the enabling dependency**, not a side task. Resequence:

1. **Add regression-test target** (Codex #1) — before any behavior changes, test persisted model creation/state isolation. Risk: blocks progress on bugs but unblocks confidence on everything after. Est. 2 hrs.

2–4. **Fix three bugs** — same scope (verdict, demo deletion, store recovery). These are unblocked by tests and remain lower-risk in isolation. Tests from (1) verify fixes. Est. 6 hrs total.

5. **Schema sketch** (Codex #5 framing): Call(UUID, statement, confidence 51–99, resolveBy, capturedAt, sealedAt?, resolution?, legacySourceID?), Decision(title, calls[]). Codex's explicit `legacySourceID` tagging is stronger than Claude's implicit tracking. Est. 2 hrs design.

6–7. **Migration + rollback** (Codex #6–7 merged): Single idempotent bootstrap migrator with snapshot/restore. Codex's emphasis on conservative legacy mapping and validation-then-save beats phased rollout — simpler, fewer failure modes. Use diagnostic store only for post-release observation. Est. 8 hrs.

8. **Sealing at write boundary** (Codex #8) — stronger than Claude's UI-only defense. Route all mutations through domain service.

**Tension resolved:** Claude's beta/staged rollout was defensive but adds complexity. Codex's snapshot-restore + validation is simpler and covers the same failure case. Ship once, validate thoroughly, rollback prepared.

**Merged estimate:** 20 hrs eng + 6 hrs QA (test target upfront saves retesting). **Total: 9 tasks, no reordering after this.**

Risk consolidation: (a) SwiftData schema immutability — lock Call fields at write boundary; (b) legacy ambiguity — explicit map + validate before commit; (c) rollback path tested on every launch until next successful migration. No silent failures.

## Codex Worker (Round 2)

Claude’s merge correctly promotes tests and adopts write-boundary sealing. I would revise three points before treating it as executable:

1. **Keep the nine tasks explicit.** “2–4” and “6–7” obscure ordering and acceptance criteria. The implementation backlog should separately name verdict-state correction, identity-based demo cleanup, recoverable container bootstrap, additive schema, migrator, rollback/release validation, and sealing.

2. **Do not promise rollback by restoring a live SQLite snapshot in-process.** SwiftData/Core Data stores can include WAL/SHM sidecars and open file handles; copying only `.sqlite` is unsafe. Before container initialization, make a coordinated backup of the complete store set to an app-managed backup directory. On migration failure, terminate the attempted bootstrap, restore the complete set before a new container attempt, and show recovery UI if that fails. The original store is retained until the migrated store survives a subsequent successful launch.

3. **Define irreversible resolution semantics.** The brief says Calls are sealed immutable on save, while resolution must occur later. Therefore seal only capture/integrity fields (`statement`, `confidence`, `resolveBy`, `capturedAt`, provenance); allow setting `resolution` from nil exactly once through a dedicated command. Whether a correction path exists must be an explicit product decision, never an editable UI escape hatch.

Revised acceptance gates: tests prove a fresh nil verdict draft and cancel behavior; demo cleanup cannot affect a non-demo Call with the same title; bootstrap failure exposes retry/diagnostics/confirmed reset without silent loss; migration is idempotent, preserves every Decision and relationship, validates source-to-Call mappings before version marking, and survives interruption/relaunch; sealed-field writes are rejected outside the capture command. Beta-first remains worthwhile despite local-only scope: it exercises real historic stores before broad release.

## Claude Worker (Round 3)

**Converged final plan:**

Codex's three revisions are adopted entirely. All nine tasks remain explicit and ordered; store backup/restore uses coordinated persistence of complete store set (all files + sidecars), not .sqlite-only; resolution semantics are locked to write-boundary enforcement.

**Nine-task execution order:**
1. **Regression-test target** — foundation enabling all fixes. 2 hrs.
2. **Fix preselected-"Correct" verdict** — nil-until-user-confirms draft model + tests for cancel. 2 hrs.
3. **Fix demo-deletion identity** — persistent ID per demo/user Call, never predicate cleanup. 2 hrs.
4. **Recoverable store open** — try-catch ModelContainer, preserve store files, recovery UI with retry/diagnostics/confirmed reset. 3 hrs.
5. **Additive schema: Call** — UUID, statement, confidence (51–99), resolveBy, capturedAt, sealedAt?, resolution?, legacySourceID?. 2 hrs.
6. **Decision→Call migration** — idempotent bootstrap migrator: snapshot complete store set, enumerate Decisions, map to Calls, preserve all dates/confidence/resolution, validate before marking version, restore on failure. 6 hrs.
7. **Rollback & release** — test fixture migrations, interruption/relaunch, downgrade; beta-first. 2 hrs.
8. **Seal enforcement** — `sealedAt` set only by capture command; statement/confidence/resolveBy/capturedAt immutable when sealed. Resolution: nil→value exactly once, no edit. All mutations route through domain service. 2 hrs.
9. *(Acceptance validation)* — end-to-end on real historic stores; confirm no silent failures, counts match, all relationships preserved.

**Store backup/restore correction:** Before container init, coordinated backup of entire store set (`.sqlite`, `.sqlite-wal`, `.sqlite-shm`) to app-managed backup dir. On migration failure, restore complete set atomically before retrying container. Keep original until next successful launch.

**Resolution semantics lock:** Seal only capture fields (statement, confidence, resolveBy, capturedAt, provenance). Allow `resolution` from nil exactly once via dedicated command. No edit path.

**Total: 21 hrs eng + 6 hrs QA.** No reordering after this. Blocking items: test target (unblocks all 8 following tasks), store-backup coordination (precedes Step 6), resolution-semantics product sign-off (before Step 8 coding).

## CONVERGED SPEC

**Hindsight Migration & Integrity Engineering — Complete Deliverable**

### Nine Executable Tasks

**Phase 0: Test Infrastructure (Unblocking dependency)**

1. **Add regression-test target**
   - Create XCTest target with persistence layer fixtures.
   - Cover: fresh Call creation, verdict state isolation (nil→user-set→persisted), Decision→Call save paths.
   - Test cancel behavior on resolve sheet.
   - Acceptance: All bug-fix tests pass; enables confidence on Steps 2–4.
   - Est. 2 hrs. Risk: Must cover both user and demo Calls.

**Phase 1: Bug Fixes**

2. **Fix preselected-"Correct" verdict**
   - Model resolution as explicit optional; initialize nil when resolve sheet appears.
   - Persist only on user confirmation (Yes/No/Partly/Can't-resolve).
   - Never derive initial verdict from enum default.
   - Map legacy unknown/missing values to unresolved (not Yes) on open.
   - Tests: Reopen Call shows nil draft; cancel sheet preserves previous resolution; confirm saves exactly once.
   - Est. 2 hrs. Risk: Legacy enum reinterpretation; conservative mapping required.

3. **Fix demo-deletion identity**
   - Assign persistent UUID identifier to every demo fixture and user Call.
   - Remove by identifier (or SwiftData object identity), never by title predicate.
   - Scope demo cleanup to explicit demo-source flag on Call.
   - Tests: Identical and overlapping titles do not trigger unintended deletion; demo cleanup leaves non-demo Calls.
   - Est. 2 hrs. Risk: Broad cleanup predicates can delete real Calls.

4. **Make store opening recoverable**
   - Encapsulate `ModelContainer` construction in throwing bootstrapper.
   - On failure, preserve store files, present recovery UI: retry, export diagnostics/backup, explicit destructive reset (requires confirmation).
   - Do not silently reset or corrupt data.
   - Est. 3 hrs. Risk: Corrupt store may be unreadable; backup is best-effort.

**Phase 2: Schema & Migration**

5. **Introduce additive Call schema**
   - Add Call table: UUID (primary), statement (String), confidence (Int 51–99), resolveBy (Date), capturedAt (Date), sealedAt? (Date), resolution? (enum), legacySourceID? (String).
   - Keep Decision and all existing metadata/relationships; add optional Decision.calls.
   - Do not delete or rename persisted fields.
   - Est. 2 hrs. Risk: Schema sensitivity in SwiftData.

6. **Run idempotent Decision→Call migration at bootstrap**
   - Before mutation, coordinated backup of complete store set (`.sqlite` + `.sqlite-wal` + `.sqlite-shm`) to app-managed backup dir.
   - Single-context enumeration of all Decisions.
   - Conservative mapping: each legacy prediction/decision→one-or-more Calls, preserve dates/confidence/resolution/notes/relationships.
   - Tag legacySourceID for audit.
   - Validate counts and required fields before marking migration version.
   - If validation fails, discard context, restore complete store set from backup, retry on next launch.
   - Keep backup until next successful launch.
   - Est. 6 hrs. Risk: Ambiguous legacy fields require explicit mapping table; retain originals.

7. **Test rollback & release**
   - Test: fixture migrations, interruption mid-migration, repeat launch (idempotency), downgrade scenario.
   - Release beta-first (exercises real historic stores before broad release).
   - Est. 2 hrs.

**Phase 3: Immutability**

8. **Enforce sealing at write boundary**
   - Calls sealed only via one capture command that validates fields and sets sealedAt.
   - Sealed fields (statement, confidence, resolveBy, capturedAt, provenance) are read-only after seal.
   - Resolution: mutable from nil exactly once via dedicated command; no further edits.
   - Edit/delete/model-update paths reject mutation of sealed fields.
   - Route all mutations through domain service; UI disabling is defense-in-depth only.
   - SwiftData has no intrinsic immutability; all paths must be guarded.
   - Est. 2 hrs.

**Phase 4: Validation**

9. **End-to-end acceptance on real historic stores**
   - Migrate 3+ test devices with live data (pre-migration snapshots verified).
   - Confirm no silent failures; counts match source→target; all relationships preserved.
   - Verify verdict nil-on-open, demo cleanup scopes correctly, sealed fields reject mutation, resolution sets exactly once.
   - Beta participants report no data loss or corruption.

### Risk Register

| Risk | Mitigation |
|------|-----------|
| SwiftData schema immutability—Lock Call fields at write boundary only. Conservative legacy mapping; validate before commit. | Explicit sealed=true enforcement; unit tests cover all mutation paths. Mapping table documented and audited. |
| Store corruption or unreadable state on migration. | Coordinated backup of complete store set. On failure, restore atomically before retry. Retain until next success. |
| Silent failure in migration (partial conversion, dropped relationships). | Validate counts and required fields before version mark. Diagnostic logging to local store. |
| Resolution semantics escape hatch (editable after set). | No edit path. Domain service enforces nil→value once only. No UI override. |
| Beta testers encounter data loss on real stores. | Beta-first release. Real-world store coverage before broad launch. One-click manual restore in Settings. |

### Acceptance Gates

- [ ] Regression tests pass (test target created, verdict/demo/store-recovery covered).
- [ ] Three bugs fixed and verified via Step 1 tests.
- [ ] Store backup/restore does not lose data on interruption or failure.
- [ ] Migration idempotent and preserves 100% of source Decisions and relationships.
- [ ] Sealed fields reject all edit/delete attempts outside capture command.
- [ ] Resolution sets exactly once; no secondary edit path.
- [ ] Beta participants report zero data loss over 1-week observation window.
- [ ] Downgrade tested (rollback to pre-Call Decision-only schema).

### Estimate & Timeline

- **Engineering: 21 hrs** (2+2+2+3+2+6+2+2 = 21).
- **QA: 6 hrs** (fixture/device migrations, end-to-end, regression verification).
- **Total: 27 hrs** (assume 3–4 days with async QA).
- **Blocking prerequisites:** Test target (Step 1 before all others), store-backup coordination (before Step 6), resolution-semantics product approval (before Step 8).
- **Release gate:** Beta-first, no broad launch until all acceptance gates pass.
