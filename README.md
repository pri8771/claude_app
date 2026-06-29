# Hindsight

> *Remember what you believed before reality gave you the answer.*

**Hindsight** is a private decision journal for iOS that runs **100% on-device**.
Capture the important decisions in your life, record what you predict will
happen, get reminded to look back later, and learn the patterns in your own
decision-making over time.

No account. No cloud. No tracking. No networking code of any kind — your
decisions never leave your device.

---

## Highlights

- **Capture decisions** through a focused 4-step wizard (basics → options →
  predictions → review date).
- **Weigh your options** with upside/downside, effort, risk and a gut-feeling
  rating for each.
- **Make falsifiable predictions** with a confidence slider and a resolution
  date — *"I'll still feel good about this in 30 days."*
- **Get reminded** with a local notification when it's time to review:
  *"Past you made a prediction about: …"*
- **Review the outcome** — grade the result *and* the process separately, mark
  each prediction correct / partial / incorrect, and capture the lesson.
- **Discover your patterns** on the Insights screen: review rate, average
  quality, prediction accuracy, charts, and plain-language insights mined from
  your own history (*"You rise to high stakes"*, *"Career decisions go
  unreviewed"*).
- **Own your data** — export everything as JSON or a printable PDF, or wipe it
  all in one tap.

## Requirements

- **Xcode 16** or later (the project uses Xcode's file-system synchronized
  groups)
- **iOS 17.0+**
- SwiftUI app lifecycle · SwiftData · Swift Charts

## Getting started

```bash
open Hindsight.xcodeproj
```

Select an iOS 17+ simulator (or device) and press **Run**.

To explore the app with realistic content, open **Settings → Your Data → Load
sample data**.

## Running the tests

Unit tests cover the pure logic that drives the app's numbers — the clarity
score, the analytics in `Statistics`, the `Decision` derived state, and JSON
export:

```bash
xcodebuild test -scheme Hindsight -destination 'platform=iOS Simulator,name=iPhone 15'
```

Or press **⌘U** in Xcode. Tests live in `HindsightTests/`.

## Design system

The visual language is dark and premium, built on an exact palette:

| Token            | Hex       |
| ---------------- | --------- |
| Background       | `#1A1A2E` |
| Accent (red)     | `#E94560` |
| Amber / gold     | `#F5A623` |
| Success (green)  | `#4CAF50` |

Spacing (`4 / 8 / 16 / 24 / 32`), corner radii, typography (SF Pro, rounded)
and shadows all live in `HindsightTheme`, and the reusable UI primitives
(`HCard`, `HButton`, `HBadge`, `HSlider`, `HStarRating`, `HProgressRing`,
`HSectionHeader`, `HEmptyState`, …) live in `HindsightComponents`.

## Project structure

```
Hindsight/
├── HindsightApp.swift            # @main entry, SwiftData container, appearance
├── HindsightRootView.swift       # Splash + onboarding gate, root router
├── Views/MainTabView.swift       # Root TabView (Today · Decisions · Insights · Settings)
├── Models/
│   ├── Decision.swift            # @Model — the core entity
│   ├── DecisionOption.swift      # @Model — a choice that was weighed
│   ├── Prediction.swift          # @Model — a falsifiable bet about the future
│   ├── OutcomeReview.swift       # @Model — the retrospective
│   └── HindsightEnums.swift      # Category / Stakes / Decision & Prediction status
├── Theme/
│   ├── HindsightTheme.swift      # Colours, typography, spacing, radii, shadows
│   ├── HindsightComponents.swift # Reusable views (cards, buttons, ratings, …)
│   └── HindsightInputs.swift     # Themed text fields, editor, stepper
├── Managers/
│   ├── NotificationManager.swift # Local review reminders
│   ├── ExportManager.swift       # JSON + PDF export
│   ├── ClarityScore.swift        # 0–100 completeness score
│   ├── Statistics.swift          # Analytics + pattern detection
│   ├── SampleData.swift          # Preview / demo seed data
│   ├── ModelContext+Save.swift   # Safe, logged SwiftData saves
│   └── AppStorageKeys.swift
└── Views/
    ├── TodayView.swift           # Home: greeting, stats, needs-review, wins, FAB
    ├── AllDecisionsView.swift    # Searchable / filterable list
    ├── DecisionDetailView.swift  # Header, timeline, options, predictions, outcome
    ├── OutcomeReviewView.swift   # Retrospective form
    ├── DecisionCardView.swift    # Shared list card
    ├── PredictionCardView.swift  # Prediction display card
    ├── SettingsView.swift        # Profile, reminders, privacy, export, wipe
    ├── Insights/InsightsView.swift
    └── NewDecision/              # The 4-step wizard + its draft model

HindsightTests/                  # Unit tests (clarity score, statistics, model, export)
```

## Privacy

Hindsight contains **no networking code**. There is no backend, no analytics
SDK, no Firebase, no Supabase. All data is persisted locally with SwiftData and
stays on the device. Export is an explicit, user-initiated action that produces
a file you choose to share.
