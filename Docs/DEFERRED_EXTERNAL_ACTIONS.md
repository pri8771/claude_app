# Hindsight — Deferred External Actions

This ledger contains only work that cannot be completed autonomously in the repository. Missing
items here do not pause unrelated implementation or verification.

## Apple and physical-device access

- [ ] Re-authenticate App Store Connect if the active session expires or MFA is requested.
- [x] Confirm that uploaded build `1.0 (4)` finishes App Store Connect processing: **done
      2026-08-18** — build 4 was selectable, attached to version 1.0, and submitted (TestFlight
      availability was not separately checked and is not claimed). (The 2026-08-14 note
      here that build 4 "almost certainly still crashes when an outcome review is saved" was
      withdrawn 2026-08-18: `git diff` shows the build-4 commit `f7935cd` predates the TodayView
      regression, which entered WIP at `c66c690` on 2026-08-11 and is fixed by `59938e2`; see
      `Docs/STATUS.md` "Resolved (2026-08-18)" and `Docs/BUGS.md` HIND-B05. No replacement build
      is required for 1.0.)
- [ ] Install and launch build `1.0 (4)` on an available physical device, then complete the manual
      device pass. Build 3 had previously been installed on the paired iPhone 16 Pro Max, which is
      now unavailable. **Consciously waived by the owner for the 1.0 submission on 2026-08-18**
      (not run; see `quality/waivers/1.0-4-device-and-accessibility-owner-waiver-2026-08-18.md`).
      Remains open for any later build.
- [ ] Apple App Review outcome for version 1.0 (build 4), submitted 2026-08-18 ~13:33 local
      (ASC "Waiting for Review", "1 Item Submitted", release option automatic). Record the
      approval/rejection date and any reviewer messages here and in `Docs/STATUS.md`.
- [ ] Accept any one-time iOS trust, notification-permission, or developer-mode prompts that
      cannot be automated safely.

## Public release identity

- [ ] Provide a durable public support email (`support@priyanshchordia.com` is proposed in
      `Docs/APP_STORE_LISTING.md`; the owner must confirm the mailbox is monitored).
- [ ] Publish the final privacy-policy and support URLs on a public domain (all three URLs
      returned `HTTP/2 200` on 2026-08-14 per `Docs/RELEASE_CHECKLIST.md`; owner confirms content).
- [x] Enter and approve in App Store Connect the listing pack in `Docs/APP_STORE_LISTING.md`
      (2026-08-18): copy, App Privacy answers, age rating, export-compliance answer, review notes,
      pricing Free / all territories, and the screenshots in `quality/store-assets/1.0-4/`.
      **Done 2026-08-18** by the owner's assistant via the ASC web UI, owner-approved: App
      Privacy "Data Not Collected" published, age rating 4+, Free in 175 territories, 5 iPhone
      6.5" + 5 iPad 13" screenshots, build 4 attached, submitted for review. Evidence:
      `quality/evidence/app-store-submission-1.0-4-2026-08-18.md`.

## Networked Social v2 (deferred; personal release remains functional without it)

- [ ] Approve cloud billing and grant development/QA/production project access after ADR-008’s
      hosted proof passes.
- [ ] Complete Sign in with Apple service configuration, server keys, and APNs production setup.
- [ ] Approve legal/safety/moderation policies before any external social tester receives access.

## Completion rule

Each item must be accompanied by dated evidence when completed. No missing external item may be
represented as complete, and no social feature may be simulated to bypass it.
