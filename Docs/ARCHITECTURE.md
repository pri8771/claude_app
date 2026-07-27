# Architecture

## Current architecture

Hindsight is a native SwiftUI and SwiftData app. The root view gates onboarding
and the main tab shell. Decision capture uses a transient `DecisionDraft` across
four paged views, then writes related decisions, options, predictions, and reviews
to SwiftData. `Statistics` derives Insights from local models. Notification and
export managers provide reminders and JSON/PDF output.

## Data flow

```text
Capture UI -> DecisionDraft validation -> SwiftData decision graph
-> Today/Decisions/Review -> Statistics -> Insights
                               -> Notification scheduling
                               -> JSON/PDF export
```

## Persistence

- Decisions own options, predictions, and outcome reviews through cascading relationships.
- Demo decisions use stable identifiers and can be removed without deleting user decisions.
- Full deletion and export are user initiated.
- Draft interruption, migration, relaunch, and reminder reconciliation require tests.

## External dependencies

- Apple SwiftUI, SwiftData, Charts, UserNotifications, and UIKit share/PDF surfaces.
- No backend, account, analytics SDK, or third-party runtime dependency.

## Known architectural risks

- Capture validity is coupled to four mandatory steps.
- Statistics are unprotected by automated tests.
- Notification scheduling is difficult to verify without abstraction and device QA.
- Demo identification includes compatibility handling for legacy title-based samples.
