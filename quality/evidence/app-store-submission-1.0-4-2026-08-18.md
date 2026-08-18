# App Store submission evidence — Hindsight 1.0 (4) — 2026-08-18

**Candidate:** Hindsight `1.0 (4)` — Adult Decision Observatory (app ID `6796111127`, bundle
`com.pchordia.hindsight`)
**Lifecycle:** `verification_pending` — submitted for App Review; Apple's outcome pending
**Actor:** owner's assistant, via the App Store Connect web UI; owner-approved
**Source pack:** `Docs/APP_STORE_LISTING.md` (prepared 2026-08-18); screenshots
`quality/store-assets/1.0-4/`
**Branch at time of submission:** `release/1.0-4-store-listing` @ `43f75f3` (docs and store
assets only on top of the build-4 source `f7935cd`; the submitted binary is the 2026-08-10 upload)

## Recorded results

| Recorded at (local, America/New_York) | Where | Action | Result |
|---|---|---|---|
| 2026-08-18 | ASC → App Information | Name `Hindsight — Decision Journal`, subtitle "Measure your judgment", primary Productivity, secondary Lifestyle, content rights: does not contain third-party content | Saved |
| 2026-08-18 | ASC → App Privacy | "Data Not Collected"; privacy-policy URL `https://priyanshchordia.com/apps/hindsight/privacy/` | Published |
| 2026-08-18 | ASC → Age rating | Questionnaire answered per listing pack | Computed **4+** |
| 2026-08-18 | ASC → Pricing and Availability | Free; 175 territories; availability all | Saved |
| 2026-08-18 | ASC → Version 1.0 | Promotional text, description, keywords, support URL, marketing URL, copyright `2026 Priyansh Chordia` | Saved |
| 2026-08-18 | ASC → Version 1.0 → Screenshots | 5 × iPhone 6.5" (`iphone-6.5-1284x2778/` 01–05, 1284×2778 derived set) and 5 × iPad 13" (`ipad-13-2064x2752/` 01–05) | Uploaded |
| 2026-08-18 | ASC → Version 1.0 → Build | Build `1.0 (4)` (uploaded 2026-08-10 17:15:06Z, delivery UUID `f572a99b-eb57-4cd6-8757-4e41db82310a`) selectable and attached — establishes ASC processing completed | Attached |
| 2026-08-18 | ASC → App Review Information | Review contact and review notes entered; sign-in **not** required | Saved |
| 2026-08-18 | ASC → Version release | Automatically release after approval | Saved |
| 2026-08-18 ~13:33 | ASC → Version 1.0 | **Add for Review → Submit** | ASC status **"Waiting for Review"**, banner **"1 Item Submitted"** |

## Evidence boundary

- This record establishes that the listing was entered and that version 1.0 with build 4 was
  submitted for App Review on 2026-08-18. It does **not** establish App Review approval, release,
  or App Store availability; those remain open in `Docs/RELEASE_CHECKLIST.md` and
  `Docs/DEFERRED_EXTERNAL_ACTIONS.md`.
- The submission was made **without** the build-4 physical-device pass and without the manual
  notification-permission / largest Dynamic Type / contrast / reduced-motion review (VoiceOver is
  separately deferred per DEC-010). The owner consciously waived those gates for the 1.0
  submission on 2026-08-18; see
  `quality/waivers/1.0-4-device-and-accessibility-owner-waiver-2026-08-18.md` and DEC-011. The
  gates are recorded as waived, **not** done, and remain unsatisfied.
- TestFlight availability of build 4 was not separately checked and is not claimed.
- Times are approximate local wall-clock as observed in the ASC web UI; no ASC API/CLI transcript
  was captured. The authoritative timestamps are the ones in App Store Connect's activity log.

## Related records

- Build-4 automated/preflight/upload evidence:
  `quality/evidence/adult-decision-observatory-release-candidate-2026-08-10.md`
- Listing pack: `Docs/APP_STORE_LISTING.md`
- Status and gates: `Docs/STATUS.md`, `Docs/RELEASE_CHECKLIST.md`, `Docs/DEFERRED_EXTERNAL_ACTIONS.md`
