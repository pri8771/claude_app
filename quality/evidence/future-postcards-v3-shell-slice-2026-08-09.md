# Future Postcards v3 shell slice evidence — 2026-08-09

Lifecycle: `verification_pending`

## Evidence recorded

- Debug simulator build succeeded for the Hindsight scheme on iPhone 17 Pro Max, iOS 26.4.1, with code signing disabled.
- Combined regression run executed 85 tests: 81 unit tests and three pre-existing capture UI tests passed. The new shell test reached its final assertion, where XCTest rejected a direct string query longer than its 128-character limit; this was a test-query defect, not an app failure.
- The assertion was replaced with a supported property predicate. The corrected new shell test then passed independently on a clean iPhone 17 Pro simulator, iOS 26.5.
- The new test verifies Now, Hindsight, Capture, Insights, and Circles tab presence; center Capture presentation; and the truthful Circles-disabled explanation.
- A simulator screenshot was inspected after isolated `-uiTestReset` launch. Warm paper, editorial hierarchy, stamped postcard surface, empty mailbox, center capture tab, and Circles destination were visible. A legacy dark navigation-background mismatch was identified and corrected by requiring the new screen-scoped navigation background to be visible.

## Result

Implementation is code-complete for the native shell slice. Promotion remains `verification_pending` until physical iPhone, VoiceOver, smallest-device, contrast, and reduced-motion evidence is attached. No backend, account, sync, or real social behavior was introduced.
