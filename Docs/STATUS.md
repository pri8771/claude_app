# Project Status

## Lifecycle status

`mvp_development`

## Current objective

Reduce first-decision friction while making the long-term value immediately
understandable through removable demo decisions, useful reviews, and sample-aware
Insights.

## Verified

- The simulator app builds successfully.
- Onboarding, Today, first decision entry, tabs, and Settings launch.
- Demo decisions can be loaded alongside real data and removed independently;
  the updated build succeeded on 2026-07-23.

## Verification pending

- Automated unit, integration, and UI-smoke targets; none currently exists.
- Approved quick-capture field contract and implementation.
- Complete review/reminder/export/delete and relaunch QA.
- Insights correctness, sample-size behavior, drill-through, and visual polish.
- Small-phone, keyboard, Dynamic Type, VoiceOver, and physical notification QA.

## Blockers

- The mandatory four-step capture flow is too dense for the product promise.
- No automated test target protects models, statistics, exports, or capture state.

## Next action

Complete `HIND-PROD-001`: define the smallest useful saved decision and document
how optional enrichment behaves without changing the data model.
