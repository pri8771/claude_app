# Hindsight 1.0 (4) — App Store and TestFlight submission packet

**Lifecycle:** `verification_pending`
**Prepared:** August 10, 2026
**Candidate:** Personal decision-calibration release
**Scope:** private, local-only iOS app; Social v2 is not included

> Do not submit the App Store version or invite external testers until every `USER-OWNED` field
> below is replaced and the pending release gates are supported by dated evidence.

## Current candidate facts

| Field | Value |
|---|---|
| App Store record name | Hindsight — Decision Journal |
| Apple app ID | `6796111127` |
| Bundle ID | `com.pchordia.hindsight` |
| SKU | `hindsight-ios-20260729` |
| Team ID | `796XH483R4` |
| Version / build | `1.0 (4)` |
| Minimum OS | iOS 17 |
| Distribution architecture | arm64 |
| Product boundary | Local SwiftData; no account, backend, sync, telemetry, ads, or social surface |

Verified for the exact build-4 candidate:

- Final release preflight passed on an iPhone 17 Pro simulator running iOS 26.4.1: 127/127
  tests passed, with 0 failures and 0 skips. Privacy, appearance, manifest, test-registration,
  and unsigned Release checks passed.
- The exact simulator product installed, launched as `com.pchordia.hindsight`, and rendered Today
  without crashing. Responsive light/dark, narrow-iPhone, and iPad smoke checks passed.
- Signed archive `/private/tmp/Hindsight-1.0-4.xcarchive` and 3.1 MB exported IPA
  `/private/tmp/Hindsight-1.0-4-export/Hindsight.ipa` succeeded.
- App Store Connect accepted the upload at 2026-08-10 17:15:06Z (delivery UUID
  `f572a99b-eb57-4cd6-8757-4e41db82310a`). The last verified state is **processing**.

Not yet verified or approved:

- App Store Connect processing completion, TestFlight availability, or tester/review state.
- Build-4 install/launch and core-loop testing on a physical device.
- Manual VoiceOver, notification-permission, largest Dynamic Type, contrast, and reduced-motion
  review.
- Public support/privacy URLs, support contact, final privacy answers, age rating, legal terms, or
  production screenshots.

## App Store product-page copy — English (U.S.)

Apple currently permits up to 30 characters for the name and subtitle, 170 characters for
promotional text, 4,000 characters for the description, and 100 bytes for keywords. The proposals
below fit those limits.

### Name — 28 characters

```text
Hindsight — Decision Journal
```

### Subtitle — 21 characters

```text
Measure your judgment
```

### Promotional text — 130 characters

```text
Record what you believe before the outcome is known, then see how your confidence compares with reality—privately, on your device.
```

### Full description

```text
What did you believe before you knew how things would turn out?

Hindsight is a private decision-calibration journal. Record a clear forecast, choose how confident you are from 0–100%, and set a date to return. When the date arrives, resolve what happened and turn your past confidence into evidence you can learn from.

CAPTURE WHAT YOU BELIEVE
Write one falsifiable statement, choose any confidence from 0–100%, and set a preset or custom review date. Add why you believe it if that context will be useful later—it is always optional.

COMPARE CONFIDENCE WITH REALITY
Resolve each forecast as happened, did not happen, or could not be judged. Hindsight preserves the original statement, confidence, reasoning, and review date so the record stays honest.

SEE YOUR CALIBRATION
Insights shows what happened when you expressed different levels of confidence. See observed success rates, average confidence, calibration gaps, Brier score, confidence bands, and eligible sample sizes. Low-sample states are labeled clearly instead of making premature claims.

FIND PATTERNS IN YOUR JUDGMENT
When enough evidence exists, compare patterns by category, time horizon, and whether you wrote down your reasoning. Every result explains the records and date range behind it.

BUILD A PERSONAL EVIDENCE LEDGER
History keeps resolved forecasts searchable and chronological, with the original belief beside the eventual outcome.

PRIVATE BY DESIGN
Version 1.0 requires no account and uses no Hindsight server, cloud sync, advertising, tracking, or developer analytics. Your forecasts and insights stay on your device. Optional example records are kept separate from your personal counts and exports. You can export your journal or delete it from Settings at any time.

Hindsight is an instrument for reflection and better judgment. It is not a prediction market, financial adviser, medical tool, or public performance feed.
```

### Keywords — 91 ASCII bytes

```text
forecast,prediction,confidence,calibration,reflection,accuracy,judgment,probability,outcome
```

### Proposed categories

- Primary: **Productivity**
- Secondary: **Lifestyle**
- Do not select Games, Health & Fitness, Medical, Finance, or Kids; the current app does not
  provide those regulated experiences.

### Required and optional URLs/contact

- Support URL: **`<USER-OWNED: PUBLIC HTTPS SUPPORT URL>`**
- Privacy Policy URL: **`<USER-OWNED: PUBLIC HTTPS PRIVACY-POLICY URL>`**
- Marketing URL (optional): **`<USER-OWNED: PUBLIC HTTPS MARKETING URL OR OMIT>`**
- Public support email: **`<USER-OWNED: DURABLE SUPPORT EMAIL>`**
- Copyright/legal name: **`© 2026 <USER-OWNED: LEGAL OWNER NAME>`**

## TestFlight copy

### Beta description

```text
Hindsight 1.0 (4) is a private decision-calibration journal for adults who want evidence about their own judgment. Record a falsifiable forecast, intentionally choose confidence from 0–100%, add an optional reason, and set a future review date. Resolve it later and use Insights to compare stated confidence with observed outcomes.

This beta stores personal content locally using SwiftData. It has no account, Hindsight backend, cloud sync, ads, tracking, developer telemetry, friends, groups, messaging, or public leaderboards. Optional example data is explicitly separated from personal counts, analytics, reminders, notifications, and exports.
```

### What to test

```text
Please test the complete belief → wait → resolve → learn loop and report your device model, iOS version, build number, exact steps, and whether the issue repeats.

1. Fresh start
• Complete onboarding and confirm that example data is optional.
• Check Today, History, Insights, and Settings when you have no personal records.

2. Capture
• Create a forecast with a short statement, confidence, and a preset review date.
• Repeat with 0%, 50%, and 100% confidence and a custom date.
• Leave Why empty once, then add a longer Why on another forecast.
• Dismiss or interrupt Capture before saving, reopen it, and confirm your draft survives.
• Tap the final save action more than once and confirm only one forecast appears.

3. Wait and resolve
• Set a short future review date and return after it is due.
• Resolve forecasts as Happened, Didn't happen, and Couldn't judge.
• Confirm the original statement, confidence, Why, and review date do not change.
• Interrupt a resolution note and confirm it can be recovered and saved without a duplicate.

4. History and Insights
• Search History by words from a resolved forecast and check empty/no-match states.
• With a small sample, confirm Insights says there is not enough evidence instead of making a personality claim.
• After enough due binary resolutions, compare the shown denominator, date window, observed rate, average confidence, calibration gap, confidence bands, and Brier score with your records.
• Confirm examples and Couldn't judge outcomes do not change personal calibration.

5. Reminders and lifecycle
• Enable review reminders, accept or decline notification permission, and verify the app remains usable either way.
• Open a due reminder and confirm it routes to the expected record without exposing forecast text on the notification.
• Terminate and relaunch the app; confirm saved records and interrupted drafts remain.

6. Data control and presentation
• Export JSON and PDF, inspect the contents, and confirm data remains in the app afterward.
• Remove example data without removing personal records.
• Delete one record, then test clear-all/reset and relaunch.
• Check light/dark mode, largest Dynamic Type, VoiceOver order and labels, Increase Contrast, Reduce Motion, long text, and keyboard-visible layouts.

Please report anything confusing, slow, inaccessible, judgmental, duplicated, lost, unexpectedly changed, or inconsistent with the local-only privacy promise.
```

### Known limitations

```text
• Version 1.0 has no account, Hindsight cloud sync, collaboration, friends, groups, messaging, public events, leaderboards, Siri, widgets, or voice capture.
• Personal records are device-local. Apple device backups may preserve app data according to the user's Apple and iCloud settings, but Hindsight does not provide cross-device recovery.
• Calibration requires real, due, resolved binary forecasts. Pending, example, cancelled, couldn't-judge, and not-yet-due records are excluded. Sparse samples intentionally show limited conclusions.
• iOS controls notification permission and delivery timing.
• Build-4 physical-device and final manual accessibility evidence are still pending; testers should report those results rather than assuming they passed.
```

### Beta review / App Review notes

```text
Hindsight 1.0 (4) is a local-only iOS app. No login, account, server, subscription, in-app purchase, paid content, advertising, unrestricted web access, social feed, messaging, or third-party content is required or available.

Primary path:
1. Launch and complete the short guided start.
2. Tap the center Capture action.
3. Enter a statement, intentionally move the 0–100% confidence slider, and choose a future preset or custom review date. Why is optional.
4. Save. The forecast appears in Today/upcoming.
5. After its review date, select Happened, Didn't happen, or Couldn't judge.
6. Resolved personal forecasts appear in History; eligible due binary forecasts feed Insights.

Settings contains local reminder controls, optional example-data controls, JSON/PDF export, appearance, recovery, and deletion. Example data is marked and excluded from personal analytics, reminders, notifications, and exports. Local notification text is generic and contains no forecast content.

No special credentials or hardware are required. To test resolution, create a forecast with a short custom review date and return after that date passes.

Review contact email: <USER-OWNED: REVIEW CONTACT EMAIL>
Review contact phone: <USER-OWNED: REVIEW CONTACT PHONE>
```

## Proposed App Privacy answers — owner/legal approval required

These answers describe only Hindsight `1.0 (4)`. They must be revisited before any account,
backend, sync, telemetry, friend, group, messaging, public-event, leaderboard, or remote feature is
enabled.

| App Store Connect question | Proposed answer | Evidence and rationale |
|---|---|---|
| Do you or third-party partners collect data from this app? | **No, we do not collect data from this app** | Personal forecasts, drafts, outcomes, preferences, and derived Insights remain on device. There is no Hindsight backend, account, telemetry, ad SDK, or third-party runtime SDK. |
| Data types collected | **None selected** | User content is stored locally and is not transmitted to the developer. A user-initiated JSON/PDF export goes only to the destination the user chooses through the iOS share sheet. |
| Data linked to the user | **None** | There is no account or remote identifier. |
| Data used to track the user | **None / No tracking** | `PrivacyInfo.xcprivacy` declares `NSPrivacyTracking` as false and has no tracking domains. |
| Third-party partner data practices | **None** | The production app uses Apple frameworks and no third-party analytics, advertising, or data-processing SDK. |
| Privacy Policy URL | **`<USER-OWNED: PUBLIC HTTPS PRIVACY-POLICY URL>`** | Required for iOS submission; publish the approved policy before entering this field. |
| Privacy Choices URL | **Omit** | There is no remote account or developer-held personal data to manage in this build. Reassess if data practices change. |

The privacy manifest declares no collected data types and one required-reason API category:
`UserDefaults`, reason `CA92.1`, for on-device preferences. Apple’s questionnaire asks about data
collected by the developer or integrated partners; local-only storage and user-directed export do
not create a Hindsight collection path. The account owner remains responsible for confirming and
publishing the answers.

## Proposed age-rating questionnaire — owner approval required

The 2026 questionnaire asks about in-app controls, capabilities, and content frequency. Use the
following answers for build 4 only:

| Section | Proposed answer |
|---|---|
| Parental controls | No |
| Age assurance | No |
| Unrestricted web access | No |
| User-generated content | No — private text is not broadly distributed |
| Social media | No |
| Social media disabled for users under 13 | No / not applicable |
| Messaging and chat | No |
| Advertising | No |
| Profanity or crude humor | None |
| Horror or fear themes | None |
| Alcohol, tobacco, or drug references | None |
| Medical or treatment information | None |
| Health or wellness topics | None — the app provides calibration evidence, not health advice |
| Mature or suggestive themes | None |
| Sexual content or nudity | None |
| Graphic sexual content and nudity | None |
| Cartoon or fantasy violence | None |
| Realistic violence | None |
| Prolonged graphic or sadistic realistic violence | None |
| Guns or other weapons | None |
| Gambling | No |
| Simulated gambling | None |
| Contests | None — there is no competition or ranking |
| Loot boxes | No |
| Made for Kids | No |
| Age category / override | Not Applicable; do not override unless owner/legal policy requires it |
| Age Suitability URL | Omit unless a dedicated approved page is published |

Expected result: **4+** under Apple’s current global questionnaire because the app provides none
of the listed objectionable content or network capabilities. This rating describes content, not
the product’s adult target audience. App Store Connect calculates the actual global and regional
ratings; record that result before release.

## Screenshot production shot list

These are production directions, not completed submission evidence. Capture actual build-4 UI at
the device sizes currently requested by App Store Connect. Use a temporary, non-personal simulator
dataset whose on-screen calculations are generated by the real app; do not composite unsupported
features or imply social/cloud behavior.

| Priority | Screen/state | Caption | Production notes |
|---:|---|---|---|
| 1 | Today with one due and one upcoming forecast | **Know what deserves your attention** | Lead with the calm adult information architecture and center Capture action. |
| 2 | Capture with statement, moved confidence slider, and date controls | **Record what you believe in moments** | Make 0–100% legible; show Why as optional and custom date available. |
| 3 | Insights confidence band with a real denominator | **See what your confidence means in practice** | Values must match the staged records exactly; show eligibility/window copy. |
| 4 | Insights calibration summary | **Measure confidence against reality** | Show observed rate, average confidence, calibration gap, and low-sample honesty. |
| 5 | Resolution with three unselected outcome choices | **Resolve honestly—without rewriting the past** | Show Happened, Didn't happen, and Couldn't judge; keep the original forecast visible. |
| 6 | Searchable resolved History | **Build an evidence trail for your judgment** | Use long but readable adult-oriented forecast text; no private real-world data. |
| 7 | Settings privacy/export/example-data controls | **Private by design. Yours to export or erase.** | Show local-only explanation and real controls, not a marketing-only mock. |

Recommended sequence: frames 1–3 first because they communicate attention, low-friction capture,
and differentiated calibration before secondary workflow details. Produce at least one dark-mode
frame only if it remains visually coherent with the set. Obtain owner approval for every final
image and caption.

Existing simulator screenshots are release evidence, not automatically App Store-ready creative:

- `/private/tmp/hindsight-build4-final-launch.png`
- `/private/tmp/hindsight-final-light-20260810.png`
- `/private/tmp/hindsight-today-dark-20260810.png`
- `/private/tmp/hindsight-final-iphone17e-20260810.png`
- `/private/tmp/hindsight-final-ipadmini-readable2-20260810.png`

## Export-compliance notes — not legal advice

- The build-4 product has no network service, backend, custom cryptography feature, secure
  messaging, VPN, payment system, or third-party crypto library.
- A targeted source/project check found no `CryptoKit`, `CommonCrypto`, `SecKey`, or `SecItem` use
  and no current `ITSAppUsesNonExemptEncryption` declaration.
- Proposed App Store Connect classification: the app **does not use non-exempt encryption** and no
  export-compliance documentation is expected. The Account Holder must confirm this conclusion
  against Apple’s current questions and applicable law.
- If that conclusion is approved, add `ITSAppUsesNonExemptEncryption = NO` to the app target in a
  separately reviewed build so future uploads state the classification explicitly. Do not alter
  the already-uploaded build’s recorded facts.

## Final submission gates

- [x] Exact-source automated preflight, simulator launch, responsive smoke, archive, and IPA
      export have dated evidence.
- [x] App Store Connect accepted the build-4 upload.
- [ ] Build 4 completes processing and becomes available in TestFlight.
- [ ] Build-4 physical-device core loop, reminders/deep links, export/share, deletion/reset, and
      relaunch pass.
- [ ] Manual VoiceOver, notification permission, largest Dynamic Type, contrast, and reduced
      motion pass.
- [ ] Every `USER-OWNED` placeholder is replaced with approved public/account information.
- [ ] Account owner/legal approves privacy answers, age rating, terms, export classification, and
      screenshots.
- [ ] App Review contact and final review notes are entered and verified.

## Apple submission references

- [App information field limits](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/)
- [Platform version metadata limits](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information/)
- [Manage App Privacy](https://developer.apple.com/help/app-store-connect/manage-app-information/manage-app-privacy/)
- [Age-rating categories and values](https://developer.apple.com/help/app-store-connect/reference/app-information/age-ratings-values-and-definitions/)
- [Export-compliance overview](https://developer.apple.com/help/app-store-connect/manage-app-information/overview-of-export-compliance/)
