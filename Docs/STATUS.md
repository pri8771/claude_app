# Project Status

## Lifecycle status

`verification_pending`

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

The authoritative dated record is
`quality/evidence/adult-decision-observatory-release-candidate-2026-08-10.md`.

## Verification pending

- App Store Connect processing, TestFlight availability, and tester/review confirmation for build
  4.
- Install and launch build 4 on a physical device, then complete the manual capture-to-resolution
  core loop and relaunch check. The previously paired iPhone 16 Pro Max is unavailable.
- Physical-device notification/deep-link, export/share, and delete/reset checks.
- Manual VoiceOver, notification-permission, largest Dynamic Type, contrast, and reduced-motion
  review. Automated responsive light/dark, narrow-phone, and iPad visual smoke is already green.
- App Store privacy answers, final support email, privacy-policy URL, terms, age rating, and
  screenshots.

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
