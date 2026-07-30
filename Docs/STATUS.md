# Project Status

## Direction update — Social v2 planning

- The product owner approved a move from a local-only decision journal to a networked social
  prediction platform with personal, private-group, and later public modes.
- The implementation-ready program is documented in
  `Docs/SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md`: 41 parent tasks plus detailed subtasks,
  dependencies, acceptance criteria, verification evidence, safety, privacy, accessibility,
  rollout, and rollback requirements.
- Repository authority now permits a backend while retaining explicit per-domain privacy and
  migration consent. No backend provider or third-party runtime dependency is approved; F0.3 is
  the selection gate.
- Social v2 implementation has **not started**. Existing Build 1 remains the current local release
  candidate and its distribution blockers below remain real.

## Lifecycle status

`verification_pending`

## Current objective

Complete distribution signing, physical-device accessibility QA, and App Store
metadata for the Build 1 TestFlight release candidate.

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
- **Build 1 MVP is code-complete (2026-07-29):**
  - Quick Capture is the primary Today action; statement, one-tap explicit confidence, review
    horizon, and Save are contained in one sheet.
  - The detailed four-step wizard remains available as the secondary **Add detail** path.
  - Today opens a fast due-prediction resolution stack directly.
  - Insights includes a sample-aware 80%+ confidence card using resolved predictions only.
  - Review, empty, error, and insight copy was reframed to be factual and non-shaming.
  - Notification content is generic and does not expose journal text on the lock screen.
  - Pending prediction reminders survive an early full review and reminder rescheduling.
- **Automated release verification revalidated (2026-07-30):**
  - 73/73 tests passed on a dedicated iPhone 17 Pro simulator, iOS 26.5; no failures or
    skips.
  - Quick Capture, largest-accessibility-text Quick Capture, and the retained detailed-wizard
    UI smoke tests passed.
  - Unsigned generic-iOS Release build succeeded.
  - Final archive code signature, designated requirement, privacy manifest, version `1.0`,
    build `1`, bundle ID, and encryption declaration validated.
- **Apple release identity created (2026-07-29):**
  - App ID: `com.pchordia.hindsight`, team `796XH483R4`.
  - App Store Connect record: **Hindsight — Decision Journal**, Apple ID `6796111127`,
    SKU `hindsight-ios-20260729`.
  - App Store icon matrix is complete and every PNG is opaque.
- The development-signed Release archive installed successfully on the paired iPhone 16 Pro Max.

## Verification pending

- Launch and complete the physical-device smoke pass after the paired iPhone is unlocked.
- Manual VoiceOver and largest Dynamic Type pass on Quick Capture, Today resolution, and Insights.
- Physical-device notification delivery and cold-launch deep-link test.
- JSON/PDF export, clear-all, and relaunch pass on the release candidate.
- Distribution-signed IPA export and upload; the current archive is development-signed.
- App Store privacy answers and hosted privacy-policy/support URLs.

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

- **T2/T6 (distribution export)** — `xcodebuild -exportArchive` reports `No Accounts` and
  `No profiles for 'com.pchordia.hindsight' were found`. Add the `796XH483R4` account in Xcode
  Settings > Accounts or create/install an Apple Distribution certificate and App Store profile.
- **T4 (privacy answers)** — the App Store record exists, but the browser session must be
  re-authenticated before the “Data Not Collected” answers can be saved.
- **T5/T7 (public contact)** — a public support email is required before publishing the privacy
  policy or inviting external testers.
- **Physical QA** — the build is installed on the paired iPhone 16 Pro Max, but iOS rejected the
  launch while the phone was locked.
- Jira issue creation is blocked by an inherited field configuration (CR-002): it requires
  `Actual`, `Delay Cause`, Components, Fix versions, and other fields at creation. A dedicated
  HIND configuration exists, but Jira’s admin UI did not persist the requirement changes on
  2026-07-29. The complete 18-item Build 1/TestFlight backlog is documented in
  `JIRA_BACKLOG_M1_TESTFLIGHT.md`; do not bypass the block by fabricating lifecycle data.

## Next action

Unlock the paired iPhone for the device smoke pass, provide the public support email, and add the
`796XH483R4` Apple account in Xcode. Then export/upload the existing verified archive, complete
App Store privacy answers, and invite internal testers.
