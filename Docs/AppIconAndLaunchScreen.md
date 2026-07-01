# App Icon & Launch Screen

Hindsight's brand mark and launch experience are built **entirely from local
SwiftUI vector shapes** — no raster assets, no networking, no dependencies.

- **Source of truth:** `Hindsight/Views/AppIconPreviewView.swift`
  (`HindsightIconMark`)
- **Launch animation:** `Hindsight/Views/SplashView.swift`
- **OS launch background:** `LaunchBackground` colour asset + `UILaunchScreen`
  in `Hindsight-Info.plist`

---

## The icon concept

A **sealed decision on a private journal card**:

| Layer | Colour | Meaning |
|-------|--------|---------|
| Rounded-square base | `#1A1A2E` navy | Private, dark, calm |
| Centered journal card | `#2E2E50` → `#242442` | A decision page |
| Card border | `#343456` | — |
| Wax seal | `#E94560` accent red | The decision, committed |
| Time-arc | `#F5A623` amber | A clock sweep / time loop |
| "Future" spark | `#F5A623` amber | The answer reality will give |

No text, no generic brain/productivity glyph, no neon. It stays legible down
to 40 px (verify with the **Export screen** preview in `AppIconPreviewView`).

---

## Exporting a 1024×1024 PNG

`HindsightIconMark(size: 1024, rounded: false)` renders a full, opaque square
(iOS applies the rounded-corner mask itself — never bake corners or alpha into
the App Store icon).

Pick one:

### A. In-app export button (easiest)
1. Temporarily show `AppIconPreviewView()` (e.g. set it as the root in
   `HindsightApp`, or push it from a debug menu) and run on a device/simulator.
2. Tap **Export 1024×1024 PNG** → the share sheet opens → **Save to Files**.
3. Rename to `AppIcon-1024.png`.

### B. Xcode canvas
Open `AppIconPreviewView.swift`, run the **"Export screen"** preview live, and
tap the export button (interactive previews can present the share sheet).

### C. Snippet (anywhere)
```swift
let r = ImageRenderer(content: HindsightIconMark(size: 1024, rounded: false)
    .frame(width: 1024, height: 1024))
r.scale = 1
let data = r.uiImage?.pngData()   // write to disk
```

---

## Filling the asset catalog

Path: `Hindsight/Assets.xcassets/AppIcon.appiconset/`

### Current checked-in state

The asset catalog now includes explicit PNGs for every iPhone, iPad and
App Store marketing icon size, generated from the 1024×1024 source artwork.
The App Store source file is:

`Hindsight/Assets.xcassets/AppIcon.appiconset/icon-1024.png`

Re-run the generator below whenever the icon artwork changes.

### Alternative — explicit per-size PNGs
Run the generator (macOS, built-in `sips` only):

```bash
Scripts/generate_app_icon.sh AppIcon-1024.png
```

It writes all sizes **and** a matching `Contents.json`. Required sizes:

| Idiom | Points | Scales | Pixels |
|-------|--------|--------|--------|
| iPhone notification | 20 | @2x @3x | 40, 60 |
| iPhone settings | 29 | @2x @3x | 58, 87 |
| iPhone spotlight | 40 | @2x @3x | 80, 120 |
| iPhone app | 60 | @2x @3x | 120, 180 |
| iPad notifications | 20 | @1x @2x | 20, 40 |
| iPad settings | 29 | @1x @2x | 29, 58 |
| iPad spotlight | 40 | @1x @2x | 40, 80 |
| iPad app | 76 | @1x @2x | 76, 152 |
| iPad Pro app | 83.5 | @2x | 167 |
| App Store marketing | 1024 | @1x | 1024 |

> **Status:** app icons are ready for local device testing and App Store
> screenshot/device installs. The SwiftUI icon preview remains the source of
> truth for future visual changes.

---

## Launch screen

Two cooperating layers, neither needing an imported image:

1. **OS launch screen — instant navy, no white flash.**
   `Hindsight-Info.plist` declares:
   ```xml
   <key>UILaunchScreen</key>
   <dict>
     <key>UIColorName</key><string>LaunchBackground</string>
     <key>UIImageRespectsSafeAreaInsets</key><true/>
   </dict>
   ```
   `LaunchBackground` is a colour asset set to `#1A1A2E`. The build still
   auto-generates all other Info.plist keys: `GENERATE_INFOPLIST_FILE = YES`
   stays on and merges its `INFOPLIST_KEY_*` values into this file, while
   `INFOPLIST_FILE = Hindsight-Info.plist` supplies the custom `UILaunchScreen`
   key. (The previous `INFOPLIST_KEY_UILaunchScreen_Generation` was removed so
   it doesn't override this.) The plist lives at the **repo root**, outside the
   synchronized `Hindsight/` group, so it is never copied as a bundle resource.

2. **SwiftUI splash — branded, fades into the app.**
   `SplashView` (the shared `HindsightIconMark` + wordmark) is shown as an
   overlay by `HindsightRootView`, then crossfades out after ~1.3 s:
   ```swift
   .overlay { if showSplash { SplashView().transition(.opacity) } }
   .task {
       try? await Task.sleep(nanoseconds: 1_300_000_000)
       withAnimation(.easeInOut(duration: 0.45)) { showSplash = false }
   }
   ```

Result: navy from the very first frame → the mark and wordmark settle in →
they dissolve into Today/Onboarding. No storyboard, no imported imagery.

---

## Guarantees

- 100% local. No networking, analytics, accounts, cloud, third-party SDKs, or
  remote/imported image assets were added.
- All artwork is SwiftUI vectors; the only generated raster is the 1024 PNG
  **you** export for the App Store icon slot.
