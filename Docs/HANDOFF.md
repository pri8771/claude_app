# Handoff

## What the project is

Hindsight is a private decision journal that preserves beliefs and predictions,
prompts later outcome review, and helps users improve judgment.

## Current state

The app builds and has a strong product concept. Demo-data lifecycle changes are
`code_complete` with a successful build, but test and human verification remain.
Quick capture is planned. Insights and the review loop are `verification_pending`.

## Build and run

```bash
xcodebuild build \
  -project Hindsight.xcodeproj \
  -scheme Hindsight \
  -destination 'platform=iOS Simulator,name=iPhone Air' \
  -derivedDataPath /tmp/Hindsight-DerivedData \
  CODE_SIGNING_ALLOWED=NO
```

There is currently no XCTest target.

## Important constraints

- Keep decisions local and preserve user work through interruption and relaunch.
- Demo deletion must never delete personal decisions.
- Preserve existing uncommitted notification and outcome-review changes.
- Do not implement quick capture until minimum required fields are approved.
- Do not present low-sample Insights as established personal patterns.

## Known issues

See `docs/BUGS.md` and `docs/RISKS.md`.

## Next recommended task

`HIND-PROD-001`: produce a one-page quick-capture field contract with compatibility,
review, and Insights behavior. No implementation in that task.
