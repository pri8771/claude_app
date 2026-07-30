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
- Automated unit, integration, and UI-smoke targets now exist; the 2026-07-30 dedicated-simulator
  regression passed 73/73 tests, including Quick Capture at the largest accessibility text size.
  Physical notification/deep-link, manual VoiceOver, manual largest-Dynamic-Type review of
  resolution and Insights, export/delete/relaunch, and distribution signing remain
  `verification_pending`.

## Social v2 planned suites

Before any Social v2 phase reaches `qa`, add task-specific coverage from
`SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md`, including:

- authentication token, replay, revocation, and cross-account cases;
- server authorization matrices for friends, blocks, groups, roles, and visibility;
- idempotent/concurrent forecast locking against server UTC deadlines;
- migration consent, interruption, relaunch, duplicate, and recovery fixtures;
- offline outbox, conflict, stale realtime event, pagination, and removed-access behavior;
- resolution, dispute, void, correction, scoring version, and leaderboard reconciliation;
- universal-link/iMessage installed, uninstalled, signed-out, expired, forwarded, and tampered
  routes;
- telemetry/push/share payload leakage tests;
- moderation, anti-cheat, environment isolation, backup/restore, load, and rollback drills.
