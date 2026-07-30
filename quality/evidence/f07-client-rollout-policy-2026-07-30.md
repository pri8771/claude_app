# F0.7 client rollout policy evidence — 2026-07-30

**Lifecycle:** `verification_pending`

## Implemented local boundary

- Added `Hindsight/Services/SocialV2RolloutPolicy.swift`, a pure Foundation-only policy with no persistence, SDK, networking, `UserDefaults`, or process-argument configuration path.
- The immutable all-disabled configuration is the only built-in default.
- Decisions bind a typed environment and an opaque 12–64-character account identifier that rejects whitespace and direct-identifier punctuation, require configured minimum contract and app-build versions, validate all flag dependencies, and fail closed with stable, non-sensitive reason codes.
- Covered runbook flag names are `social_read`, `social_write`, `private_sync_opt_in`, `migration_start`, and `background_sync`.

## Checks

- Passed: `swiftc -module-cache-path /private/tmp/hindsight-f07-module-cache -typecheck Hindsight/Services/SocialV2RolloutPolicy.swift`.
- Passed: `swiftc -parse HindsightTests/SocialV2RolloutPolicyTests.swift`.
- Passed: whitespace checks with `git diff --check --no-index /dev/null` for each of the three new files.
- Added `SocialV2RolloutPolicyTests.swift` to the explicit `HindsightTests` group and Sources build phase in `Hindsight.xcodeproj/project.pbxproj`.
- Passed: `xcodebuild -list -project Hindsight.xcodeproj` listed the `Hindsight`, `HindsightTests`, and `HindsightUITests` targets and the shared `Hindsight` scheme.
- Passed: project inspection confirmed the test file's `PBXFileReference`, `PBXBuildFile`, test group entry, and `HindsightTests` Sources-phase entry. The app policy source is included through the `Hindsight` filesystem-synchronized target group.
- Passed: `git diff --check` and no-index whitespace checks for each new file.
- Passed after CoreSimulator was restarted and the per-user device set was accessed outside the
  restricted workspace sandbox: focused `SocialV2RolloutPolicyTests`, 7/7 with no failures or
  skips at `/private/tmp/hindsight-social-rollout-20260730.xcresult`.
- Passed: the full shared Hindsight scheme, 80/80 with no failures or skips at
  `/private/tmp/hindsight-social-foundation-wave2-20260730.xcresult`.
- The application source directory is synchronized by Xcode, so `Hindsight/Services/SocialV2RolloutPolicy.swift` is included by the Hindsight target; the explicit unit-test target membership is now recorded above.

## Remaining gates

- `verification_pending`: trusted signed/remote configuration integration after F0.3/F0.4/F0.5 approval; real environment/account isolation evidence; green hosted CI; contract compatibility with a selected backend; migration/rollback game day; physical-device and QA promotion evidence.
- No Social v2 UI, networking, persistence, secrets, SDKs, or runtime flag-loading path was added.
