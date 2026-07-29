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

## Direction change — 2026-07-28

The Call / Timestamped Receipt / Brier-calibration pivot (T7–T22) was **reverted**. The product is
the original Decision journal with its original Insights analytics. See `CHANGE_REQUEST_LOG.md`
CR-000a. All pivot work is preserved on branch `archive/call-pivot-complete` and is recoverable.

Phase 1 trust fixes (T2–T6) were **kept** — they fixed crashes and data-loss bugs in the original
app and are unrelated to the pivot.

One production bug was reintroduced by the revert and fixed again: `bootResult` assigned inside
`App.init()` never reached `body`, hanging the app on a black screen with a spinner
(commit 25d6971).

## Blockers

- **T1 (App Store Connect record)** — needs the paid developer account; blocks the whole
  TestFlight release track (T2, T4, T6, T7).
- **Dev-signed build on device expires ~2026-08-03.** Re-sign before then or the app stops
  launching.
- Jira issue creation is blocked by an inherited field configuration (CR-002). **Deferred by
  decision on 2026-07-29** — the repo is the source of truth; Jira gets populated later.

## Next action

**M1.1 — Quick Capture sheet.** See `MVP_PLAN.md` (Baseline M1.0) for the full breakdown and
`PLAN_TRACKING.md` for live status.

Ready to start with no blockers: M1.1, M1.5, M1.6, M1.7, T3, T5.
