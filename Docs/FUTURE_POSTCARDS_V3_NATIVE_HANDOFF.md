# Future Postcards v3 — Native Shell Handoff

**Lifecycle:** `verification_pending`
**Design reference:** `Hindsight - Future Postcards - Production Candidate v3 - Guided Start - Complete Clickable`
**Specification reference:** `Hindsight - Future Postcards - Production Design Specification v3`
**Implemented boundary:** Phase 0 shell handoff plus Phase 1 navigation/Now/capture presentation slice. This document does not approve accounts, networking, social behavior, or public features.

## Product and interaction decision

The personal loop remains the root product: write a falsifiable future belief, intentionally state confidence, choose when to return, seal locally, and compare the original belief with reality. The native shell therefore leads with the private mailbox and capture action. Circles is present only as a truthful disabled destination so the information architecture can be evaluated without implying that accounts or social data exist.

## Native route map

| Destination | Entry | Current behavior | Authority and recovery |
|---|---|---|---|
| Now | launch, Now tab, notification deep link | Shows the capture prompt, ready, upcoming, and recently opened local records. | SwiftData is authoritative. A stale notification ID is ignored without leaving a dead route. |
| Hindsight | Hindsight tab | Shows resolved records only, with search over prediction, Why, and outcome text. | Local query; empty and no-match states are explicit. |
| Capture | center tab action, Now prompt, first-decision onboarding choice | Presents one-screen capture without replacing the last content tab. | Durable `QuickCaptureDraft`; local transaction must succeed before dismissal. |
| Insights | Insights tab | Retains the existing local Insights implementation until Phase 2 replaces it. | Samples remain excluded by existing identity rules. |
| Circles | Circles tab | Explains that social features are unavailable and the journal remains local/private. | No account, network call, relationship, score, or synthetic activity is created. |
| Settings | Now toolbar, Circles explanation | Retains local sample, export, reminder, and data controls. | Existing local persistence and recovery rules remain authoritative. |
| Detailed decision | Now toolbar `Add detail` | Retains the four-step detailed wizard as a secondary path. | Existing save boundary and tests remain in force. |

The last non-action tab is stored under `AppStorageKeys.selectedMainTab`. Selecting Capture opens the composer but does not persist Capture as a destination. Local-notification routes always select Now before opening the matching record.

## Visual tokens implemented for this slice

| Role | Native token | Value / intent |
|---|---|---|
| Paper background | `FuturePostcardTheme.Colors.paper` | `#F4EEDD`, warm mailbox canvas |
| Raised postcard | `paperRaised` | `#FFFDF7`, readable card/input surface |
| Primary ink | `ink` | `#18140F`, high-contrast text and primary action |
| Secondary ink | `inkMuted` | `#6E665A`, metadata and explanation |
| Personal accent | `rust` | `#B84B32`, selected navigation, due state, validation |
| Postmark accent | `amber` | `#F1C453`, stamp treatment |
| Resolved accent | `sage` | `#66785F`, opened state |
| Structure | `line` / `softLine` | Ink outline and secondary divider |

Typography uses scalable system text styles. Editorial display and headings use the rounded system design; metadata and stamps use monospaced styles. No custom font or new runtime dependency is introduced.

## Components implemented

- `FuturePostcardStamp`: textual state marker; meaning is never color-only.
- `FuturePostcardSurface`: outlined paper card with a non-essential offset shadow.
- `FuturePostcardDecisionCard`: sealed/ready/opened state, authored text, optional Why, confidence, date, and explicit sample marking.
- Future Postcards screen modifier: paper surface plus light navigation appearance scoped to redesigned screens.
- Now mailbox: capture prompt, empty state, ready/upcoming/opened sections, settings and detailed-wizard access.
- Hindsight archive: resolved-only query, search, empty/no-match state, and detail navigation.
- Circles unavailable state: explicit personal/local explanation and no simulated social content.

## State and accessibility contract

- Capture retains statement, optional Why, confidence, horizon, and custom date until confirmed save, explicit discard, or empty dismissal.
- Confidence is unselected until slider interaction and exposes a textual 0–100 percent value.
- Every primary action is at least 44 points high. Cards expose a combined state, prediction, confidence, date, and sample-status label.
- Samples display `SAMPLE · DOES NOT AFFECT YOUR INSIGHTS`; sample identity continues to use explicit UUID provenance.
- Dynamic Type may increase vertical height; critical text is not forced to a single line.
- Motion and shadows are decorative. State remains present in text when Reduce Motion is active.
- The Circles destination contains no fake members, groups, votes, messages, or scores.

## Implemented tests and outstanding evidence

Automated evidence:

- 81 app-hosted unit tests passed on iPhone 17 Pro Max simulator / iOS 26.4.1.
- Three existing capture regression UI tests passed: primary capture, accessibility XXXL capture, and retained detailed wizard.
- New shell UI smoke passed on iPhone 17 Pro / iOS 26.5: five destinations exist; center Capture presents the composer; Circles remains truthfully gated.
- Simulator build and visual capture passed.

Still required before promotion:

- Physical iPhone 16 Pro Max review of tab ergonomics, capture, draft restoration, and due routing.
- Manual VoiceOver focus/order review for Now, Capture, Hindsight, and Circles.
- Smallest-supported-iPhone, dark appearance policy, increased contrast, and Reduce Motion captures.
- Phase 1 redesigned resolution/detail experience and Phase 2 analytics remain unimplemented.

## Change-control boundary

This slice may evolve the native presentation and local routing only. Any account, backend, upload, sync, friend, Circle, message, public profile, event, leaderboard, or remote telemetry behavior requires the Social v2 foundation gates in the execution plan. Existing personal records may not be silently migrated or uploaded.
