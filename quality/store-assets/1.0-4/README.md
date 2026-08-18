# App Store screenshots — Hindsight 1.0 (4)

**Captured:** 2026-08-18 (local time, Tuesday, August 18, 2026 as rendered in the app)
**Host:** macOS 26.5.2, Xcode 26.6 (17F113)
**App under capture:** Debug simulator build of the working tree at commit `d0189bc`
(branch `release/1.0-4-store-listing`, created from `fix/todayview-forecast-crash` HEAD), built with
`xcodebuild -scheme Hindsight -configuration Debug -destination 'generic/platform=iOS Simulator'
CODE_SIGNING_ALLOWED=NO`. No app source was modified for these captures. This is not the exact
build-4 binary (`f7935cd`); the surfaces shown (Today, History, Capture, Insights, Settings, resolve
sheet) exist in build 4 with the same copy, but layout details may differ slightly from the
uploaded build. Owner should eyeball each frame against the TestFlight build if desired.

## Devices

| Folder | Simulator | UDID | iOS | Native pixel size | Notes |
|---|---|---|---|---|---|
| `iphone-6.9-1320x2868/` | iPhone 17 Pro Max | `3C3D0E59-B4CF-4687-94E9-062ACC483C7B` | 26.5 (23F77) | 1320 × 2868 | Light mode. Native `xcrun simctl io <udid> screenshot`. |
| `iphone-6.9-1320x2868-dark/` | iPhone 17 Pro Max | same | 26.5 | 1320 × 2868 | `xcrun simctl ui <udid> appearance dark`; no Capture frame. |
| `iphone-6.5-1284x2778/` | derived from the iPhone 17 Pro Max frames | — | — | 1284 × 2778 | See "6.5-inch derivation". |
| `ipad-13-2064x2752/` | iPad Pro 13-inch (M5) | `64547157-F17D-4929-ABB4-557A78E246A7` | 26.5 (23F77) | 2064 × 2752 | Portrait, light mode. Native capture. |
| `extras/` | iPhone 17 Pro Max | as above | 26.5 | 1320 × 2868 | Optional 6th frame: the "Reality check" resolve sheet. |

Status bar was set with `xcrun simctl status_bar <udid> override --time 9:41 --batteryState charged
--batteryLevel 100 --wifiBars 3 [--cellularMode active --cellularBars 4]`.

All PNGs are 8-bit RGB with **no alpha channel** (flattened after capture; App Store Connect
rejects alpha). Verified with Pillow on 2026-08-18.

## ASC size requirements checked

- iPhone 6.9" slot: accepts 1320 × 2868 (native here) — matches.
- iPhone 6.5" slot as shown on the Hindsight 1.0 version page on 2026-08-18: 1242 × 2688 or
  1284 × 2778 (portrait) — the derived set is exactly 1284 × 2778.
- iPad 13" slot: accepts 2064 × 2752 or 2048 × 2732 — native iPad Pro 13-inch (M5) is 2064 × 2752.

## 6.5-inch derivation (no 6.5-inch simulator available)

`xcrun simctl list devices available` on this Mac (runtimes iOS 26.4 and 26.5) offers only the
iPhone 17 / 17 Pro / 17 Pro Max / 17e / Air family and current iPads; there is no iPhone 11 Pro
Max / XS Max / 14 Plus class device, so 6.5" frames could not be captured natively. Each 6.5" file
was produced from the same-named 1320 × 2868 file by:

1. downscaling with Lanczos to 1284 × 2790 (scale factor 1284/1320 = 0.9727; never upscaled), then
2. center-cropping 12 px of height (6 px top, 6 px bottom) to 1284 × 2778.

Script: Pillow, run 2026-08-18; recorded in the branch commit message. Aspect difference between
the two sizes is 0.4% so no visible distortion; the crop removes 6 px of status-bar margin and 6 px
of home-indicator margin.

## Frame inventory and what each shows

| # | File | Surface | Content state |
|---|---|---|---|
| 01 | `01-today.png` | Today tab, top | Calibration pulse showing **10 results**, "Your confidence and outcomes are close.", the Capture card, and the "Ready for reality — Resolve 1 forecast" card. |
| 02 | `02-history.png` | History tab, scrolled to the ledger | Filter chips (All / Happened / Did not happen / Could not judge, "10 of 10"), chronological trail with resolved cards showing category, stated confidence, BEFORE statement, AFTER outcome. |
| 03 | `03-capture.png` | Quick Capture sheet ("New forecast") | Statement typed ("The Saturday farmers market will still have peaches next weekend"), slider at 66% (iPad: 63%), "This week" preset selected with "Review on August 22, 2026.", enabled "Lock in my belief". |
| 04 | `04-insights.png` | Insights tab | Signal Garden hero: n = 10 eligible, mean stated confidence 62%, observed 60%, gap −2 pp, Brier 0.118; iPad frame also shows the evidence-milestone strip, the 80%+ card (n = 3, 85% / 100% / +15 pp) and the first confidence bands. |
| 05 | `05-settings.png` | Settings tab | "Your Hindsight" header, private-garden note, Reminders and Haptics toggles, Your data (Export as JSON / PDF, Explore example records), Help, Delete data. |
| 06 | `extras/06-resolve-iphone-6.9-1320x2868.png` | "Reality check" resolve sheet | "11 signals are ready", the first due forecast card (60% confident, book-club statement), and the three unselected outcome buttons. |

The iPhone Insights and Settings frames are scrolled ~55 pt from the very top so the inline
navigation title is visible; at scroll offset 0 the large navigation title renders as a blank
band on this simulator (see "Observations" below).

## Data shown (provenance)

The screens show a personal dataset, not the app's bundled example records:

- 2 forecasts were typed through the Quick Capture UI in the simulator (kitchen renovation, 72%,
  This week; farmers-market peaches, 66%, This week — the latter is the one shown in the Capture
  frame).
- 13 additional forecast records were inserted into the simulator's SwiftData store
  (`Library/Application Support/default.store`, tables `ZDECISION`/`ZPREDICTION`) with `sqlite3`
  while the app was terminated, using the same column shape the app writes for a Quick Capture
  record (Awaiting Review status, pending prediction, generic adult statements about work, money,
  habits, and household matters; categories Career/Financial/Health/Relationships/Personal; created
  2–190 days ago; 11 with review dates already past, 2 upcoming). This was done because the app
  correctly refuses review dates in the past, so due/resolved records cannot be produced through
  the UI on capture day.
- All 10 resolutions were then performed through the app's own "Reality check" resolve flow
  (6 "It happened", 4 "It did not happen"); one due forecast was left unresolved so Today shows a
  live "Resolve 1 forecast" card. Every number on Insights/History was computed by the app from
  those records.
- The iPad simulator received a copy of the iPhone simulator's `default.store` (WAL checkpointed
  first) plus the same `UserDefaults` keys, so both device sets show identical data.
- Onboarding was skipped by writing `hasCompletedOnboarding`, `didRequestNotifications`, and
  `hasLaunchedBefore` to the app's `UserDefaults` via `xcrun simctl spawn <udid> defaults write`
  before launch (iPhone) — no Debug launch argument or code change was used. Notification
  permission was granted in the simulator when the first capture triggered the prompt.

No real personal data appears in any frame.

## Observations recorded while capturing (not fixed here)

- On both simulators, the **Insights** and **Settings** tabs use a large navigation title and the
  title text does not render at scroll offset 0 (blank band above the content); the inline title
  appears once the list scrolls. Tracked as `Docs/BUGS.md` HIND-B06 (observed; same
  `.navigationTitle` configuration exists in build 4 `f7935cd`; not verified on the build-4 binary
  or on iOS 26.4.1/device).
- The Insights "Evidence in motion" milestone strip hyphenates "Directional" as "Di-rec-tional" on
  iPhone width; cosmetic.

## Not produced

- No 6.5"-class or 5.5"-class native captures (no such simulators installed).
- No landscape iPad frames (the app is portrait-first; ASC accepts portrait-only sets).
- No captures from the exact build-4 IPA (`/private/tmp/Hindsight-1.0-4-export/Hindsight.ipa` and
  the archive no longer exist on this Mac as of 2026-08-18).
