# Build 1 TestFlight evidence — 2026-07-29

Feature contract: `BUILD1-TESTFLIGHT`
Status: `verification_pending`

## Automated tests

- Revalidation command: `xcodebuild test -quiet -project Hindsight.xcodeproj -scheme Hindsight -destination 'platform=iOS Simulator,id=ECE07C31-F8DD-4936-A59D-05390000E57B' ... CODE_SIGNING_ALLOWED=NO`
- Revalidation environment: dedicated `Hindsight-AgentSession-1785185137` iPhone 17 Pro
  simulator, iOS 26.5, arm64.
- Revalidation result (2026-07-30): **73 passed, 0 failed, 0 skipped**.
- Revalidation bundle:
  `/private/tmp/hindsight-social-plan-promotion-green-20260730.xcresult`.
- The suite includes Quick Capture at accessibility XXXL, primary Quick Capture, and the retained
  detailed-wizard UI flows.
- Original release result (2026-07-29): **72 passed, 0 failed, 0 skipped** on iOS 26.4.1,
  retained at `/private/tmp/hindsight-testflight-final-rerun-20260729.xcresult`.
- Result summary was independently read with `xcrun xcresulttool get test-results summary`.

## Release build and archive

- Generic iOS Release build with signing disabled: **PASS**.
- Final archive: `/private/tmp/Hindsight-1.0-1-final-20260729.xcarchive`.
- Code signature verification: **PASS**.
- Bundle: `com.pchordia.hindsight`.
- Version/build: `1.0 (1)`.
- Team: `796XH483R4`.
- `ITSAppUsesNonExemptEncryption`: `false`.
- Bundled `PrivacyInfo.xcprivacy`: plist validation **PASS**.
- App icon matrix: all declared files present; every PNG reports `hasAlpha: no`.

## Apple release setup

- Registered App ID: `com.pchordia.hindsight`.
- App Store Connect record: **Hindsight — Decision Journal**.
- Apple ID: `6796111127`.
- SKU: `hindsight-ios-20260729`.
- The development-signed Release app installed successfully on paired
  **iPhone 16 Pro Max (iPhone17,2)**.
- Physical launch attempt was rejected because the device was locked; no interaction result is
  claimed.
- App Store export attempt failed with `No Accounts` and no App Store provisioning profile;
  distribution signing remains externally blocked.

## Required human evidence still missing

- Physical Quick Capture and direct Resolve pass.
- Notification delivery and cold-launch deep link.
- JSON/PDF export, clear-all, and relaunch.
- VoiceOver and largest Dynamic Type.
- Published privacy policy/support contact.
- Distribution-signed IPA upload and internal TestFlight installation.
