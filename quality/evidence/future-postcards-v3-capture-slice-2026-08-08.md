# Future Postcards v3 capture slice — verification evidence

**Date:** 2026-08-08  
**Task:** `P1.CORE.1A`  
**Feature contract:** `FUTURE-POSTCARDS-V3-PERSONAL-CORE`  
**Lifecycle:** `verification_pending`

## Implemented

- Replaced fixed confidence chips with a native 0–100 slider while retaining an explicit
  unselected state. The thumb rests at a neutral visual position, but no confidence is persisted
  until the person interacts.
- Added optional `Why?` reasoning and persisted its trimmed value through the existing
  `Decision.notes` field, avoiding a SwiftData schema migration.
- Preserved Quick Capture resolution behavior for reasoned postcards and narrowed compatibility
  detection to the existing personal/low-stakes/reversible shape.
- Added a Codable local draft snapshot for statement, reasoning, confidence, horizon, and custom
  date. Empty drafts and successfully sealed drafts clear the snapshot; recoverable work survives
  dismissal/relaunch until explicit discard.
- Added Keep Draft / Discard / Keep Editing cancellation behavior and prevented silent interactive
  dismissal while work exists or a save is in progress.
- Kept existing persistence ordering: success feedback, reminder scheduling, and dismissal occur
  only after the SwiftData save succeeds.
- Preserved the existing detailed four-step wizard and its UI smoke coverage.

## Automated verification

Simulator resolved dynamically to `platform=iOS Simulator,id=42822C36-C6AE-4585-BADE-F35E4EE9581A`
(`iPhone 17 Pro Max`, iOS 26.4.1).

1. Full app-hosted unit suite:

   ```text
   xcodebuild test -quiet -project Hindsight.xcodeproj -scheme Hindsight \
     -destination 'platform=iOS Simulator,id=42822C36-C6AE-4585-BADE-F35E4EE9581A' \
     CODE_SIGNING_ALLOWED=NO -only-testing:HindsightTests \
     -resultBundlePath /private/tmp/hindsight-future-postcards-units-20260808.xcresult
   ```

   Result: **81 passed, 0 failed, 0 skipped**.

2. Critical capture UI smoke:

   ```text
   xcodebuild test -quiet -project Hindsight.xcodeproj -scheme Hindsight \
     -destination 'platform=iOS Simulator,id=42822C36-C6AE-4585-BADE-F35E4EE9581A' \
     CODE_SIGNING_ALLOWED=NO \
     -only-testing:HindsightUITests/HindsightCaptureFlowUITests \
     -resultBundlePath /private/tmp/hindsight-future-postcards-ui-20260808.xcresult
   ```

   Result: **3 passed, 0 failed, 0 skipped**. This includes the primary Quick Capture path, the
   accessibility XXXL path, and the retained detailed wizard/review path.

3. Unsigned generic-iOS Release build:

   ```text
   xcodebuild build -quiet -project Hindsight.xcodeproj -scheme Hindsight \
     -configuration Release -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO
   ```

   Result: **passed**.

4. Static checks:

   - `git diff --check` — passed.
   - `jq empty quality/feature-contracts/future-postcards-v3-personal-core.json` — passed.

## Verification still required

- Physical iPhone 16 Pro Max review of slider ergonomics, keyboard behavior, draft restoration,
  custom date, Save, Cancel, Keep Draft, Discard, and failed-save recovery.
- Manual VoiceOver review of the native slider at 0%, 50%, and 100% and of the cancellation dialog.
- Smallest supported iPhone and light-mode visual verification.
- Full Future Postcards v3 shell, postcard visual components, guided start, sample lifecycle,
  resolution/history redesign, and expanded Insights are not implemented by this slice.
- Social accounts, backend, synchronization, friends, Circles, messages, and public features remain
  gated and were not implemented or tested.

## Notes

- The approved Claude Design artifacts remain external design references; no local export is
  claimed by this evidence.
- Existing unrelated documentation changes present before this slice were preserved and are not
  claimed as part of this evidence.
