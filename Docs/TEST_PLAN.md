# Test Plan

## Required suites

- Model relationships, deletion cascades, derived state, and migrations.
- `DecisionDraft`, clarity, minimum quick-capture fields, and optional enrichment.
- Statistics and minimum-sample behavior for every Insights claim.
- Demo insertion idempotency, coexistence, legacy recognition, targeted deletion,
  export behavior, and preservation of user records.
- Notification scheduling, cancellation, permission denial, and reconciliation.
- JSON/PDF export and full user-data deletion.
- UI smoke: onboarding demo, remove demo, quick capture, review, Insights, relaunch.
- Small/standard/large phones with keyboard, Dynamic Type, VoiceOver, and dark appearance.

## Environment limitations

- Notification delivery and authorization transitions require physical-device QA.
- Subjective capture friction and Insights usefulness require uncoached human review.
- No automated test target exists yet; current state is `verification_pending`.
