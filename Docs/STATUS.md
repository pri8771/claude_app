# Project Status

## Lifecycle status

`mvp_development`

## Current objective

Reduce first-decision friction while making the long-term value immediately
understandable through removable demo decisions, useful reviews, and sample-aware
Insights.

## Verified

- The simulator app builds successfully.
- Onboarding, Today, first decision entry, tabs, and Settings launch.
- Demo decisions can be loaded alongside real data and removed independently;
  the updated build succeeded on 2026-07-23.
- **Phase 1 (code_complete):** 59/59 unit tests pass on iPhone 17 Pro simulator (2026-07-27):
  - T1-fix: Test target converted to app-hosted (commit f3a0557)
  - T2: Kill preselected-Correct verdict (commit 2ad34e6)
  - T3: Demo-data identity by UUID only, title matching deleted (commit ee56907)
  - T4: Recoverable store open with Retry/Export/Reset options (commits fbd34ac, f50fb3b, df70dfc)
  - T5: Persistence boundary—no silent saves, success effects gated (commit 5c366eb)
  - T6: Cold-launch notification deep link consumed in .task (commit 6126f24)
  - Evidence: quality/feature-contracts/phase1-trust-fixes.json, quality/completion-reports/phase1-trust-fixes.json, quality/evidence/phase1-test-run.md

## Verification pending

- Physical-device notification QA (logic reviewed, device test deferred).
- UI smoke tests (HindsightUITests 15–19 exist but not part of phase 1 gate).
- VoiceOver audit (phase 6 T21).
- Cold-launch deep-link manual test on device (logic reviewed, not device-tested).
- Approved quick-capture field contract and implementation (phase 2 T7).
- Complete review/reminder/export/delete and relaunch QA (phase 2–3).
- Insights correctness, sample-size behavior, drill-through, and visual polish (phase 4).
- Small-phone, keyboard, Dynamic Type layout testing.

## Blockers

None remaining for phase 1 merge to `qa`.

## Next action

Phase 2 (Call schema): begin with T7 (Complete additive Call schema, register in
StoreBootstrap, demo inserts set `isDemo = true`).
