# Hindsight — Deferred External Actions

This ledger contains only work that cannot be completed autonomously in the repository. Missing
items here do not pause unrelated implementation or verification.

## Apple and physical-device access

- [ ] Re-authenticate App Store Connect if the active session expires or MFA is requested.
- [ ] Confirm that uploaded build `1.0 (4)` finishes App Store Connect processing, becomes
      available in TestFlight, and clears the intended tester/review gate.
- [ ] Install and launch build `1.0 (4)` on an available physical device, then complete the manual
      device pass. Build 3 had previously been installed on the paired iPhone 16 Pro Max, which is
      now unavailable.
- [ ] Accept any one-time iOS trust, notification-permission, or developer-mode prompts that
      cannot be automated safely.

## Public release identity

- [ ] Provide a durable public support email.
- [ ] Publish the final privacy-policy and support URLs on a public domain.
- [ ] Approve final App Store privacy answers, age rating, Terms, and screenshots before submission.

## Networked Social v2 (deferred; personal release remains functional without it)

- [ ] Approve cloud billing and grant development/QA/production project access after ADR-008’s
      hosted proof passes.
- [ ] Complete Sign in with Apple service configuration, server keys, and APNs production setup.
- [ ] Approve legal/safety/moderation policies before any external social tester receives access.

## Completion rule

Each item must be accompanied by dated evidence when completed. No missing external item may be
represented as complete, and no social feature may be simulated to bypass it.
