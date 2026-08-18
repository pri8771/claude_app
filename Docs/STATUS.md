# Project Status

## Lifecycle status

`verification_pending` — **1.0 (4) submitted for App Review on 2026-08-18** (App Store Connect
status "Waiting for Review"). Apple's review outcome is the remaining external gate; the candidate
is not `done` until it is approved and live.

## Submitted for App Review (2026-08-18)

Entered in App Store Connect on 2026-08-18 by the owner's assistant via the ASC web UI, owner
approved, per `Docs/APP_STORE_LISTING.md` (app ID `6796111127`, version 1.0, build `1.0 (4)`):

- Version 1.0 was submitted at about **13:33 local (America/New_York)**; ASC showed **"Waiting for
  Review"** and **"1 Item Submitted"** immediately afterwards.
- Build 4 was selectable and attached to the version, which establishes that App Store Connect
  processing of the 2026-08-10 upload completed. Release option: automatic on approval.
- Listing entered: name `Hindsight — Decision Journal`, subtitle "Measure your judgment", primary
  Productivity, secondary Lifestyle, content rights "none" (no third-party content), age rating
  computed **4+**, App Privacy **"Data Not Collected"** published, pricing **Free** in 175
  territories, availability all, privacy-policy URL set, promotional text / description /
  keywords / support + marketing URLs / copyright, review contact + review notes, sign-in not
  required.
- Screenshots uploaded: 5 iPhone 6.5" (`quality/store-assets/1.0-4/iphone-6.5-1284x2778/`, the
  1284×2778 derived set) and 5 iPad 13" (`ipad-13-2064x2752/`).
- Owner decision (2026-08-18): the physical-device pass and manual accessibility review were
  **not** run before submission; 1.0 shipped on simulator evidence. Those gates stay open in
  `Docs/RELEASE_CHECKLIST.md` and are recorded as consciously waived by the owner for the 1.0
  submission (`quality/waivers/1.0-4-device-and-accessibility-owner-waiver-2026-08-18.md`,
  `Docs/DECISIONS.md` DEC-011). They are not satisfied.

Dated record: `quality/evidence/app-store-submission-1.0-4-2026-08-18.md`.

## Current release candidate

**Hindsight 1.0 (4) — Adult Decision Observatory** is the current personal-release candidate.
It is a private, local SwiftData experience for adults improving their judgment over time.

The production information architecture is:

1. **Today** — records ready to resolve, upcoming records, one useful personal signal, and the
   fastest route to Capture.
2. **History** — searchable chronological evidence ledger with the original forecast and outcome.
3. **Capture** — a center action, not a persistent destination: statement, intentionally selected
   0–100 confidence, and future date are required; Why is optional.
4. **Insights** — deterministic, sample-safe calibration analysis; every claim exposes its
   denominator, window, and eligibility.
5. **Settings** — privacy, reminders, example data, export, appearance, recovery, and deletion.

There is no account, backend, telemetry, sharing, Circles, group, network, or public-performance
surface in this candidate. Social paths remain disabled and fail closed.

## Verified evidence

- The final `Scripts/personal_release_candidate_check.sh` run passed against the exact source used
  for this candidate: **127/127 tests passed, 0 failures, 0 skips**, on an iPhone 17 Pro simulator
  running iOS 26.4.1. The result bundle is
  `/private/tmp/hindsight-personal-release-20260810-build4-final/Logs/Test/Test-Hindsight-2026.08.10_13-07-48--0400.xcresult`.
  Privacy, appearance, manifest, test-registration, and unsigned Release checks passed.
- The exact build-4 simulator product installed and launched normally as
  `com.pchordia.hindsight`; `/private/tmp/hindsight-build4-final-launch.png` records the rendered
  Today surface.
- Responsive visual smoke passed in light and dark mode on iPhone 17 Pro, on the narrow iPhone 17e,
  and on iPad mini.
- A signed Debug build of build 3 was previously installed on the paired physical iPhone 16 Pro
  Max. The device is now unavailable, so no build-4 physical install or launch is claimed.
- The signed `1.0 (4)` archive succeeded at `/private/tmp/Hindsight-1.0-4.xcarchive`; the exported
  IPA is `/private/tmp/Hindsight-1.0-4-export/Hindsight.ipa` (3.1 MB; bundle
  `com.pchordia.hindsight`; minimum iOS 17; arm64). App Store Connect accepted the build-4 upload
  at **2026-08-10 17:15:06Z**; it is processing (app ID `6796111127`, delivery UUID
  `f572a99b-eb57-4cd6-8757-4e41db82310a`).

- 2026-08-18 regression check on branch `release/1.0-4-store-listing` (source `d0189bc`, docs and
  screenshot assets only on top): `Scripts/personal_release_candidate_check.sh` passed — 127/127
  tests, 0 failures, 0 skips, iPhone 17 Pro simulator, iOS 26.5; result bundle
  `/private/tmp/claude-501/-Users-pchordia-Documents/88daf776-92f3-4798-8f8f-b6b37484892b/scratchpad/rc-dd/Logs/Test/Test-Hindsight-2026.08.18_13-10-15--0400.xcresult`
  (session scratch; not durable). This is not build-4 evidence; it only shows the tree at
  `d0189bc` is green.

The authoritative dated record is
`quality/evidence/adult-decision-observatory-release-candidate-2026-08-10.md`.

## Resolved (2026-08-18): build 4 predates the TodayView crash

The 2026-08-14 note that "build 4 likely ships a fixed crash" was wrong. Established by `git diff`
on 2026-08-18:

- The build-4 release-candidate commit `f7935cd` ("Ship adult decision calibration release
  candidate", 2026-08-10 13:22 local; App Store Connect accepted the build-4 upload at 17:15:06Z
  the same day) contains the safe snapshot-once shape in `Hindsight/Views/TodayView.swift`:
  `ForEach(Array(upcomingDecisions.prefix(5))) { decision in` and
  `ForEach(Array(exampleDecisions.prefix(3))) { decision in`.
- The index-then-resubscript pattern (`ForEach(Array(...prefix(5)).indices, id: \.self) { index in
  let decision = Array(...prefix(5))[index]`) first appears in the 2026-08-11 WIP checkpoint
  `c66c690` ("checkpoint: preserve Hindsight WIP before factory enrollment"); see
  `git diff f7935cd c66c690 -- Hindsight/Views/TodayView.swift`.
- Commit `59938e2` (2026-08-14, branch `fix/todayview-forecast-crash`) restores the snapshot-once
  shape.

So the `EXC_BREAKPOINT` index-out-of-range trap tracked as `Docs/BUGS.md` HIND-B05 was introduced
in post-build-4 WIP and is contained in **no uploaded build**. Build 4 does not need to be
replaced on account of it. The fix still belongs in the next build's line: any 1.1 build must be
cut from a branch that contains `59938e2`. As of 2026-08-18, `59938e2` is contained in
`fix/todayview-forecast-crash`, `release/1.0-4-store-listing`, `app-factory/enroll`, and local
`factory/pilot-1.1` (verified with `git branch --contains 59938e2`); `origin/main` (`9500c47`)
contains neither the regression `c66c690` nor the build-4 commit `f7935cd` and is simply behind.

Owner decision (2026-08-14, reconfirmed 2026-08-18): ship 1.0 from build 4, free, no in-app
purchase. The App Store listing pack for that submission is `Docs/APP_STORE_LISTING.md`;
store screenshots are under `quality/store-assets/1.0-4/`.

Also on 2026-08-17 the App Factory's verified change `1b65f20` (DecisionDetailView due-prediction
`onDismiss` refresh) was fast-forwarded onto local branch `factory/pilot-1.1`; it is not part of
build 4 either.

## Verification pending

- Apple App Review outcome for the 1.0 (4) submission of 2026-08-18 (currently "Waiting for
  Review"), then the automatic release going live. TestFlight availability was never separately
  confirmed and is not claimed.
- Install and launch build 4 on a physical device, then complete the manual capture-to-resolution
  core loop and relaunch check. The previously paired iPhone 16 Pro Max is unavailable.
  **Waived by the owner for the 1.0 submission on 2026-08-18** (not run, not satisfied).
- Physical-device notification/deep-link, export/share, and delete/reset checks. **Waived by the
  owner for the 1.0 submission on 2026-08-18** (not run, not satisfied).
- Manual VoiceOver, notification-permission, largest Dynamic Type, contrast, and reduced-motion
  review. Automated responsive light/dark, narrow-phone, and iPad visual smoke is already green.
  VoiceOver is deferred per DEC-010; the rest was **waived by the owner for the 1.0 submission on
  2026-08-18** (not run, not satisfied).
- ~~Owner entry/approval in App Store Connect of the listing pack and screenshots~~ — done
  2026-08-18; see "Submitted for App Review (2026-08-18)" above.

## Deferred external actions

External prerequisites and approvals are maintained only in
`Docs/DEFERRED_EXTERNAL_ACTIONS.md`. They are not represented as complete here.

## Social v2 planning boundary

The Social v2 contracts and local foundation experiments remain planning work. They do not grant
this personal candidate remote data paths or social UI. Any future social release remains gated on
its separately documented authority, identity, hosted-integrity, privacy, safety, and operational
evidence.

## Historical context

Build 3 is superseded/historical, as are earlier Build 1 / Future Postcards documents and build
`1.0 (2)` upload records; none is release evidence for the current 1.0 (4) candidate. See the
dated evidence and completion reports for their original scope and environment.
