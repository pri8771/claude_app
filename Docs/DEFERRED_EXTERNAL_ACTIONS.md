# Hindsight — Deferred External Actions

This ledger contains only work that cannot be completed autonomously in the repository. Missing
items here do not pause unrelated implementation or verification.

## Apple and physical-device access

- [ ] Re-authenticate App Store Connect if the active session expires or MFA is requested.
- [ ] Confirm that uploaded build `1.0 (4)` finishes App Store Connect processing, becomes
      available in TestFlight, and clears the intended tester/review gate. (The 2026-08-14 note
      here that build 4 "almost certainly still crashes when an outcome review is saved" was
      withdrawn 2026-08-18: `git diff` shows the build-4 commit `f7935cd` predates the TodayView
      regression, which entered WIP at `c66c690` on 2026-08-11 and is fixed by `59938e2`; see
      `Docs/STATUS.md` "Resolved (2026-08-18)" and `Docs/BUGS.md` HIND-B05. No replacement build
      is required for 1.0.)
- [ ] Install and launch build `1.0 (4)` on an available physical device, then complete the manual
      device pass. Build 3 had previously been installed on the paired iPhone 16 Pro Max, which is
      now unavailable.
- [ ] Accept any one-time iOS trust, notification-permission, or developer-mode prompts that
      cannot be automated safely.

## Public release identity

- [ ] Provide a durable public support email (`support@priyanshchordia.com` is proposed in
      `Docs/APP_STORE_LISTING.md`; the owner must confirm the mailbox is monitored).
- [ ] Publish the final privacy-policy and support URLs on a public domain (all three URLs
      returned `HTTP/2 200` on 2026-08-14 per `Docs/RELEASE_CHECKLIST.md`; owner confirms content).
- [ ] Enter and approve in App Store Connect the listing pack in `Docs/APP_STORE_LISTING.md`
      (2026-08-18): copy, App Privacy answers, age rating, export-compliance answer, review notes,
      pricing Free / all territories, and the screenshots in `quality/store-assets/1.0-4/`.

## Networked Social v2 (deferred; personal release remains functional without it)

- [ ] Approve cloud billing and grant development/QA/production project access after ADR-008’s
      hosted proof passes.
- [ ] Complete Sign in with Apple service configuration, server keys, and APNs production setup.
- [ ] Approve legal/safety/moderation policies before any external social tester receives access.

## Completion rule

Each item must be accompanied by dated evidence when completed. No missing external item may be
represented as complete, and no social feature may be simulated to bypass it.
