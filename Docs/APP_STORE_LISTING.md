# Hindsight 1.0 (4) — App Store listing pack

**Prepared:** 2026-08-18
**Build being submitted:** `1.0 (4)` — already in App Store Connect (app ID `6796111127`, bundle
`com.pchordia.hindsight`), version page state "Prepare for Submission" as of 2026-08-18.
**Owner decision (2026-08-14, reconfirmed 2026-08-18):** ship 1.0 from build 4, **Free**, no
in-app purchase, all territories.
**Source of truth for the product facts below:** the build-4 source (`f7935cd`) and the current
tree; every claim was checked against code on 2026-08-18. Where this pack differs from
`Docs/TESTFLIGHT_RELEASE_METADATA.md` (2026-08-10), this pack is newer and the difference is noted.

**2026-08-18 update:** the values in this pack were entered in App Store Connect on 2026-08-18
(owner's assistant via the ASC web UI, owner-approved) and version 1.0 with build 4 was
submitted for App Review at ~13:33 local ("Waiting for Review"). Age rating computed 4+; App
Privacy "Data Not Collected" published; Free in 175 territories; 5 iPhone 6.5" + 5 iPad 13"
screenshots uploaded; release automatic. Dated record:
`quality/evidence/app-store-submission-1.0-4-2026-08-18.md`. Apple's acceptance remains an open
gate in `Docs/RELEASE_CHECKLIST.md`.

---

## 1. App Information (applies to all versions)

| Field | Value | Notes |
|---|---|---|
| Name (30 max) | `Hindsight — Decision Journal` | 28 characters. Already the ASC record name. |
| Subtitle (30 max) | `Measure your judgment` | 21 characters. |
| Primary category | **Productivity** | Journal / self-tracking utility. |
| Secondary category | **Lifestyle** | Optional; leave blank if the owner prefers a single category. |
| Content rights | Does **not** contain, show, or access third-party content | Everything shown is the user's own text; example records are authored in the app bundle (`Hindsight/Managers/SampleData.swift`). |
| Age rating | See section 5 (expected **4+**) | |
| Bundle ID | `com.pchordia.hindsight` | |
| SKU | `hindsight-ios-20260729` | Already set. |
| Primary language | English (U.S.) | |

## 2. Version information — 1.0

### Promotional text (170 max) — 130 characters

```text
Record what you believe before the outcome is known, then see how your confidence compares with reality—privately, on your device.
```

### Description (4,000 max) — 1,926 characters

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
Version 1.0 requires no account and uses no Hindsight server, cloud sync, advertising, tracking, or developer analytics. Your forecasts and insights stay on your device. Optional example records are kept separate from your personal counts and exports. You can export your journal as JSON or PDF, or delete it, from Settings at any time.

Hindsight is an instrument for reflection and better judgment. It is not a prediction market, financial adviser, medical tool, or public performance feed.
```

Claims checked against code on 2026-08-18: 0–100 confidence slider with no default selection
(`QuickCaptureSheet`), preset + custom review dates (`Tomorrow / This week / This month /
6 months / Pick date`), optional "Add your thinking" note, three outcomes
(`DuePredictionResolveStackView`: "It happened / It did not happen / It cannot be judged clearly"),
Insights metrics (`InsightsView`: mean stated confidence, observed outcome rate, observed −
confidence gap, Brier, fixed confidence bands, per-card `n =` denominators, category / time-horizon /
reasoning cohorts gated by a minimum sample size), searchable History that excludes example
records (`HindsightArchiveView`), JSON and PDF export via the share sheet and "Clear all data"
(`SettingsView`), no account/network code (`Scripts/privacy_no_network_audit.sh` passes).

### Keywords (100 characters max) — 96 characters

```text
forecast,prediction,confidence,calibration,reflection,accuracy,judgment,probability,outcome,bias
```

Do not repeat "hindsight", "decision", or "journal": those words are already indexed from the name.

### URLs and contact

| Field | Value | Status |
|---|---|---|
| Support URL | `https://priyanshchordia.com/apps/hindsight/support/` | Returned `HTTP/2 200` on 2026-08-14 (`Docs/RELEASE_CHECKLIST.md`). |
| Marketing URL (optional) | `https://priyanshchordia.com/products/hindsight/` | Returned `HTTP/2 200` on 2026-08-14. |
| Privacy Policy URL (App Privacy section) | `https://priyanshchordia.com/apps/hindsight/privacy/` | Returned `HTTP/2 200` on 2026-08-14. Owner confirms the page text matches the "Data Not Collected" answers below. |
| Public support email (shown on the support page, not an ASC field) | `support@priyanshchordia.com` | Proposed in `Docs/TESTFLIGHT_RELEASE_METADATA.md`; owner must confirm the mailbox exists and is monitored (open item in `Docs/DEFERRED_EXTERNAL_ACTIONS.md`). |
| Copyright | `2026 Priyansh Chordia` | |
| Version | `1.0` | Matches `MARKETING_VERSION = 1.0`; build `4` = `CURRENT_PROJECT_VERSION`. |

### What's New in This Version

First release; ASC does not show this field for a 1.0. If it appears, use:

```text
First release of Hindsight: capture a forecast with a 0–100% confidence and a review date, resolve it later, and see how your confidence compares with reality. Everything stays on your device.
```

### Build

Select build **1.0 (4)** (uploaded 2026-08-10 17:15:06Z, delivery UUID
`f572a99b-eb57-4cd6-8757-4e41db82310a`). No other build should be selected for 1.0.

## 3. Screenshots

Assets and provenance: `quality/store-assets/1.0-4/README.md`. Summary:

| ASC slot (as shown on the version page 2026-08-18) | Folder | Files | Pixel size | Provenance |
|---|---|---|---|---|
| iPhone 6.5" Display (1284 × 2778 accepted) | `iphone-6.5-1284x2778/` | 01-today, 02-history, 03-capture, 04-insights, 05-settings | 1284 × 2778 | Downscaled (×0.9727) and center-cropped (12 px total height) from the iPhone 17 Pro Max captures; no upscaling. No 6.5"-class simulator exists in the installed runtimes. |
| iPhone 6.9" (Media Manager accepts 1320 × 2868) | `iphone-6.9-1320x2868/` | same five | 1320 × 2868 | Native iPhone 17 Pro Max simulator captures, iOS 26.5. |
| iPhone 6.9" dark-mode alternates (optional) | `iphone-6.9-1320x2868-dark/` | 01, 02, 04, 05 | 1320 × 2868 | Same device, `simctl ui appearance dark`. |
| iPad 13" Display (2064 × 2752 accepted) | `ipad-13-2064x2752/` | 01-today, 02-history, 03-capture, 04-insights, 05-settings | 2064 × 2752 | Native iPad Pro 13-inch (M5) simulator captures, iOS 26.5, portrait. |
| Extra (optional 6th frame) | `extras/06-resolve-iphone-6.9-1320x2868.png` | Reality-check (resolve) sheet | 1320 × 2868 | Native iPhone 17 Pro Max capture. |

Suggested order and captions (captions are optional in ASC; the images carry no text overlays):

1. Today — *Know what deserves your attention*
2. History — *Build an evidence trail for your judgment*
3. Capture — *Record what you believe in moments*
4. Insights — *See what your confidence means in practice*
5. Settings — *Private by design. Yours to export or erase.*

All frames show records that were entered through the app's own capture and resolve flows in a
simulator (statements are generic, non-personal adult forecasts); the numbers on Insights are what
the app computed from those records. No compositing, no implied cloud/social features.

## 4. App Privacy — answers derived from the binary/source

Verified 2026-08-18 against `Hindsight/PrivacyInfo.xcprivacy` (build 4 and HEAD are identical) and
`Scripts/privacy_no_network_audit.sh` (passes: no `URLSession`, `URLRequest`, `NWConnection`,
`WKWebView`, analytics/ads SDK symbols, or `http(s)://` literals in `Hindsight/`). The project has
no third-party dependencies (`.factory/project-context.json`:
`thirdPartyDependenciesAllowed: false`; no SPM/CocoaPods manifests).

| ASC question | Answer | Evidence |
|---|---|---|
| Do you or your third-party partners collect data from this app? | **No, we do not collect data from this app** → label shows **"Data Not Collected"** | No network code; no backend; no account; no analytics or ad SDK. Journal content lives in a local SwiftData store (`StoreBootstrap`), preferences in `UserDefaults`. |
| Data types | none | `NSPrivacyCollectedDataTypes` is an empty array. |
| Tracking | **No** | `NSPrivacyTracking = false`; `NSPrivacyTrackingDomains` empty; no `AppTrackingTransparency` usage. |
| Required-reason APIs (declared in the manifest, not an ASC question) | `NSPrivacyAccessedAPICategoryUserDefaults`, reason `CA92.1` | On-device preferences only. |
| Privacy Policy URL | `https://priyanshchordia.com/apps/hindsight/privacy/` | |
| Privacy Choices URL | leave blank | No developer-held personal data to manage. |

User-initiated JSON/PDF export goes only to the destination the user picks in the iOS share sheet;
that is not developer collection. Local notifications carry generic text ("A prediction is due" /
"Open Hindsight when you're ready to see how it turned out"), never forecast content
(`NotificationManager`).

These answers must be revisited before any account, sync, telemetry, or social feature ships.

## 5. Age rating questionnaire — answers with reasons

Answer every content item **None** and every capability item **No**, except as noted. Rationale is
the same for all: the app shows only user-typed text plus bundled example forecasts about work,
money, health habits, and relationships; there is no media, feed, chat, web view, purchase, or
competition.

| Question | Answer | Reason (from code) |
|---|---|---|
| Cartoon or fantasy violence; realistic violence; prolonged graphic or sadistic realistic violence | None | No such content; SF Symbols and gradients only. |
| Profanity or crude humor | None | App copy is neutral; user text is private and not shown to others. |
| Mature or suggestive themes; sexual content or nudity; graphic sexual content | None | None present. |
| Horror or fear themes | None | None present. |
| Medical or treatment information | None | Bundled example "Commit to morning workouts" is a habit forecast, not medical advice; the description explicitly disclaims medical use. |
| Health or wellness topics | None | The app does not give health guidance; the `Health` category is a user-chosen label for a forecast. |
| Alcohol, tobacco, or drug use or references | None | None present. |
| Simulated gambling; gambling; contests; loot boxes | None / No | No wagering, scoring against others, prizes, or purchases. |
| Guns or other weapons | None | None present. |
| Unrestricted web access | No | No `WKWebView`/`SFSafariViewController`; the only links are `UIApplication.openSettingsURLString` (opens iOS Settings). |
| User-generated content | No | Text is private on the device; nothing is shared or displayed to other users. Fail-closed social flags remain off (`SocialV2RolloutPolicyTests`). |
| Messaging and chat; social media | No | None. |
| Advertising | No | None. |
| Parental controls; age assurance | No | Not applicable. |
| Made for Kids | No | Adult-oriented reflection tool; leave Kids Category unselected. |
| Age rating override | None | Do not raise the rating unless the owner wants to; expected computed rating **4+**. |

Record the rating that ASC actually computes when the questionnaire is saved.

## 6. Export compliance

`Hindsight-Info.plist` already contains `ITSAppUsesNonExemptEncryption = NO`, and has since commit
`1351174` (2026-07-30). The key is present in the build-4 source (`git show
f7935cd:Hindsight-Info.plist`) and the app target uses that plist (`INFOPLIST_FILE =
"Hindsight-Info.plist"`, merged with the generated plist), so build 4 was uploaded with the
declaration. **No code change is needed and no new build is required.**

- ASC therefore should not prompt for export compliance when build 4 is attached; if the
  "Export Compliance Information" question does appear, answer **No** to "Does your app use
  encryption?" — the app has no networking, custom cryptography, or third-party crypto library
  (`CryptoKit`, `CommonCrypto`, `SecKey`, `SecItem` are not referenced in `Hindsight/`).
- Correction to `Docs/TESTFLIGHT_RELEASE_METADATA.md` (2026-08-10), which said there was "no
  current `ITSAppUsesNonExemptEncryption` declaration": that was stale; the key was already in
  the plist and in build 4.

## 7. Pricing and availability

| Field | Value |
|---|---|
| Price | **Free** (Tier 0) |
| In-app purchases / subscriptions | None (no StoreKit code in the app). |
| Availability | **All territories** |
| Pre-order | No |
| App distribution / Business | Default (public App Store). |
| Tax category | Default (App Store software). |

## 8. App Review Information

| Field | Value |
|---|---|
| Sign-in required | **No** — there is no account or login anywhere in the app. Leave demo credentials empty. |
| Contact first/last name | Priyansh Chordia |
| Contact phone | owner enters (not in repo) |
| Contact email | `priyansh.chordia@gmail.com` |
| Attachment | none needed |

### Notes to the reviewer (paste into "Notes")

```text
Hindsight is a local-only decision journal. There is no login, account, server, subscription, in-app purchase, advertising, web view, social feed, messaging, or third-party content. All data stays on the device.

Reaching each surface (iPhone: bottom tab bar; iPad: top tab bar):
1. First launch shows a short guided start (a few pages). Its last page offers "Start First Decision" (opens the detailed capture wizard) or "Start Empty" (goes straight to Today).
2. Today (first tab): what is due, what is upcoming, and a calibration summary. "Capture what I believe" opens the capture sheet.
3. Capture (center tab or the round + button): type one checkable statement, move the 0–100% confidence slider (nothing is preselected), pick a review date (Tomorrow / This week / This month / 6 months / Pick date), optionally add your reasoning, then "Lock in my belief".
4. History (second tab): searchable ledger of resolved forecasts with the original confidence next to the outcome; filter chips for Happened / Did not happen / Could not judge.
5. Insights (fourth tab): calibration metrics computed from due, resolved, binary forecasts; every card shows its own n; low-sample states are labeled.
6. Settings (last tab): review reminders (local notifications only), haptics, Export as JSON / Export as PDF (share sheet), "Explore example records" (adds clearly labeled example forecasts that never enter personal Insights/History counts and can be removed with the same button), "Show onboarding again", "Clear all data".

To exercise the resolve flow quickly: capture a forecast with "Tomorrow" as the review date, or use Settings > "Explore example records" — one example ("Move to a cheaper apartment across town") is already past due, so Today shows a "Resolve" card immediately. Resolution offers three outcomes: It happened / It did not happen / It cannot be judged clearly.

Reminders are optional; declining notification permission does not affect any other feature. Notification text is generic and never includes forecast content.
```

## 9. Owner checklist for the ASC session

- [ ] App Information: name, subtitle, categories, content rights (section 1).
- [ ] 1.0 version page: promo text, description, keywords, support/marketing URLs, copyright
      (section 2); attach build 1.0 (4).
- [ ] Screenshots: upload the 6.5" set (or the 6.9" set via Media Manager) and the iPad 13" set
      (section 3, `quality/store-assets/1.0-4/`).
- [ ] App Privacy: "Data Not Collected", privacy policy URL (section 4); publish the label.
- [ ] Age rating questionnaire (section 5); record the computed rating.
- [ ] Export compliance: should not prompt; if it does, answer "No" (section 6).
- [ ] Pricing: Free, all territories (section 7).
- [ ] App Review information and notes (section 8).
- [ ] Submit for review only after the owner accepts that the physical-device and manual
      accessibility gates in `Docs/RELEASE_CHECKLIST.md` remain open (simulator evidence only).

## 10. Not covered by this pack

- Any physical-device evidence for build 4 (none exists; the paired device is unavailable).
- Terms of Use / EULA: the standard Apple EULA applies unless the owner adds a custom one.
- Localizations other than English (U.S.).
