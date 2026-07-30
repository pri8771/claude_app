# TestFlight Build 1 metadata

**Status:** release record and copy complete except for the public support email,
privacy-policy URL, privacy answers, and distribution upload.

## App Store Connect identity

- App Store name: **Hindsight — Decision Journal**
- Apple ID: `6796111127`
- Bundle ID: `com.pchordia.hindsight`
- SKU: `hindsight-ios-20260729`
- Team ID: `796XH483R4`
- Version / build: `1.0 (1)`

## Beta description

Hindsight is a private, on-device journal for recording what you believe before you know how things
turn out. Capture a prediction, choose your confidence and review date, then come back later to
compare your confidence with reality.

This beta stores journal content on your device. There are no accounts, ads, analytics, or cloud
sync in Build 1.

## What to test

Please focus on the complete learning loop:

1. Capture a real prediction using the Quick Capture button. Time it if you can; the target is
   under ten seconds.
2. Choose a short review date.
3. When a prediction is due, resolve it from the review queue without instructions.
4. Open Insights after resolving several predictions and check whether the confidence comparison
   is understandable and feels fair.
5. Export your journal from Settings, then verify your data remains in the app.

Please report:

- anything that is confusing, slow, inaccessible, or feels judgmental;
- any missing, duplicated, or unexpectedly changed journal entry;
- notification, export, relaunch, or layout problems;
- device model, iOS version, build number, and steps to reproduce.

## Known limitations

- Build 1 has no voice capture, Siri, widgets, accounts, cloud sync, or social features.
- Insights require resolved predictions; small samples intentionally show limited conclusions.
- Notification timing is controlled by iOS and may vary with system settings.

## Feedback contact

**[PUBLIC SUPPORT EMAIL REQUIRED BEFORE TESTER INVITES]**

## Privacy policy URL

**[PUBLIC HTTPS URL REQUIRED BEFORE EXTERNAL TESTFLIGHT]**

## Internal release gate

- [x] App Store Connect record matches `com.pchordia.hindsight`.
- [ ] Apple Distribution certificate and App Store provisioning are valid.
- [x] Release archive validates as version 1.0, build 1.
- [ ] Distribution-signed IPA uploads successfully.
- [ ] Quick Capture and Resolve pass on a physical device.
- [x] Notifications contain no journal content.
- [ ] JSON/PDF export, clear-all, and relaunch are verified.
- [ ] VoiceOver and largest Dynamic Type pass on every new Build 1 surface.
- [ ] App privacy answers match `Hindsight/PrivacyInfo.xcprivacy` and the published policy.
