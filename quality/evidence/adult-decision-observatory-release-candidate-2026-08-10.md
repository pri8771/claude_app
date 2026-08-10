# Adult Decision Observatory release-candidate evidence — 2026-08-10

**Candidate:** Hindsight `1.0 (4)` — Adult Decision Observatory
**Lifecycle:** `verification_pending`
**Scope:** private local Today / History / Capture / Insights / Settings candidate

## Verified automated results

| Recorded at | Environment | Check | Result |
|---|---|---|---|
| 2026-08-10 | iPhone 17 Pro simulator, iOS 26.4.1 | Final exact-source `Scripts/personal_release_candidate_check.sh` | Passed; 127/127 tests, 0 failed, 0 skipped; privacy, appearance, manifest, test-registration, and unsigned Release checks passed |
| 2026-08-10 | iPhone 17 Pro simulator, iOS 26.4.1 | Exact build-4 install and normal launch | Passed; process launched as `com.pchordia.hindsight` and rendered the Today surface without a crash |
| 2026-08-10 | iPhone 17 Pro simulator | Responsive visual smoke, light and dark | Passed |
| 2026-08-10 | Narrow iPhone 17e simulator | Responsive visual smoke | Passed |
| 2026-08-10 | iPad mini simulator | Responsive visual smoke | Passed |
| Historical | Physical iPhone 16 Pro Max | Build 3 signed Debug build and install | Previously passed; the device is now unavailable, so no build-4 device install or launch is claimed |
| 2026-08-10 | Generic iOS distribution destination | Signed archive | Passed |
| 2026-08-10 | App Store/TestFlight export | Signed IPA export | Passed |
| 2026-08-10 17:15:06Z | App Store Connect | Build `1.0 (4)` upload | Succeeded; app ID `6796111127`, delivery UUID `f572a99b-eb57-4cd6-8757-4e41db82310a`; processing |

## Artifact locations

- Complete test result:
  `/private/tmp/hindsight-personal-release-20260810-build4-final/Logs/Test/Test-Hindsight-2026.08.10_13-07-48--0400.xcresult`
- Exact build-4 launch screenshot: `/private/tmp/hindsight-build4-final-launch.png`
- Light iPhone 17 Pro screenshot: `/private/tmp/hindsight-final-light-20260810.png`
- Dark iPhone 17 Pro screenshot: `/private/tmp/hindsight-today-dark-20260810.png`
- Narrow iPhone 17e screenshot: `/private/tmp/hindsight-final-iphone17e-20260810.png`
- iPad mini screenshot: `/private/tmp/hindsight-final-ipadmini-readable2-20260810.png`
- Signed archive: `/private/tmp/Hindsight-1.0-4.xcarchive`
- Exported IPA: `/private/tmp/Hindsight-1.0-4-export/Hindsight.ipa` (3.1 MB; bundle
  `com.pchordia.hindsight`; minimum iOS 17; arm64)
- App Store Connect delivery log:
  `/var/folders/fg/lmdhrms177s93m879bkgvjzr0000gn/T/Hindsight_2026-08-10_13-13-49.866.xcdistributionlogs/ContentDelivery.log`

## Evidence boundary

The complete preflight, simulator tests, privacy/appearance/manifest/test-registration validation,
unsigned Release build, responsive visual smoke, distribution archive/export, and App Store Connect
upload are established for the exact `1.0 (4)` candidate source. Final integrity fixes include
explicit detailed confidence, optional rating presence, due-date analytics eligibility, sample-safe
reminders, coherent fast resolution, durable notes, and transaction-safe deletion/new-decision
retry. Upload success does **not** establish that App Store Connect processing or TestFlight review
has completed. Build 3 is superseded/historical. Its prior physical-device install does **not**
establish build-4 runtime behavior; the paired iPhone 16 Pro Max is now unavailable, so build-4
device scenarios remain manual. Simulator visual smoke is not a substitute for manual VoiceOver,
notification, share/export, deletion, or physical-device checks. Social backend paths remain
deferred and fail closed.

## Remaining verification

- App Store Connect processing, TestFlight availability, and intended tester/review confirmation
  for build 4.
- Install and launch build 4 on an available physical device; complete the capture-to-resolution
  core loop, notification/deep-link, export/share, deletion/reset, and relaunch checks.
- Manual VoiceOver, notification permission, largest Dynamic Type, contrast, and reduced-motion
  review.
- Final public support contact, privacy/support URLs, App Store privacy answers, Terms, age rating,
  and screenshots.

External prerequisites remain in `Docs/DEFERRED_EXTERNAL_ACTIONS.md`.
