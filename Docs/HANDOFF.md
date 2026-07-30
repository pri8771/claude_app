# Handoff

## What the project is

Hindsight is a private decision journal that preserves beliefs and predictions,
prompts later outcome review, and helps users improve judgment.

## Current state

Build 1 is code-complete and the 2026-07-30 regression run passed 73/73 tests. The Social v2
networked direction is accepted as a program, but only its mandatory F0 planning/contracts, local
delivery controls, and a disposable PostgreSQL integrity slice have begun. No Social v2 app
feature code, cloud backend, account, user-data upload, or third-party runtime dependency exists.

## Build and run

```bash
xcodebuild build \
  -project Hindsight.xcodeproj \
  -scheme Hindsight \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  -derivedDataPath /tmp/Hindsight-DerivedData \
  CODE_SIGNING_ALLOWED=NO
```

Automated unit, integration, and UI-smoke targets exist. The 2026-07-30 foundation regression
passed 73/73 on an iPhone 17 Pro simulator;
physical-device accessibility/notification/export checks and final distribution signing remain.

## Important constraints

- Keep decisions local and preserve user work through interruption and relaunch.
- Demo deletion must never delete personal decisions.
- Preserve existing uncommitted notification and outcome-review changes.
- Do not implement quick capture until minimum required fields are approved.
- Do not present low-sample Insights as established personal patterns.
- Existing local records remain private by default. Server-backed work must follow
  `SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md`, the accepted F0 contracts, and the vendor-neutral
  API boundary; never upload legacy data without explicit consent or claim a social lock before
  server acknowledgement.
- ADR-008 is proposed, not accepted. Do not create provider projects, add an SDK, or begin Phase 1
  identity/sync work until its hosted proof and owner reviews pass.

## Known issues

See `docs/BUGS.md` and `docs/RISKS.md`.

## Next recommended task

Send `CLAUDE_DESIGN_PROMPT.md` to Claude Design, review the F0.1/F0.4–F0.6 owner decisions, and
extend the passed local PostgreSQL slice into the hosted F0.3 auth/RLS/realtime/APNs/isolation/
restore proof. Accept or revise ADR-008 before provisioning isolated development and QA services.
