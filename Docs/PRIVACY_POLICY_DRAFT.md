# Hindsight Privacy Policy — publication draft

> **Scope:** This draft describes only Hindsight `1.0 (4)`, the local-only personal
> decision-calibration release. It does not authorize or describe Social v2. Before any account,
> backend, synchronization, telemetry, friend, group, messaging, public-event, leaderboard,
> moderation, or other remote feature reaches testers, replace this policy and the App Store
> privacy answers using an approved data inventory and obtain owner/legal review.

**Draft last updated:** August 10, 2026
**Proposed effective date:** **`<USER/LEGAL: SET WHEN PUBLISHED>`**
**Publication status:** **DRAFT — not legally approved or published**
**Required publication location:** **`<USER-OWNED: PUBLIC HTTPS PRIVACY-POLICY URL>`**
**Required contact:** **`<USER-OWNED: DURABLE SUPPORT EMAIL>`**

Hindsight is a private decision-calibration journal. Version 1.0 lets you record what you believe
before an outcome is known, return after a chosen date, resolve what happened, and learn how your
stated confidence compares with observed results. This version works on your device, requires no
account, and does not send your journal or Insights data to a Hindsight server.

## Information stored on your device

Hindsight stores the content you create so the app can provide its core experience. Depending on
what you choose to enter, local records may include:

- forecast or decision statements;
- intentionally selected confidence from 0–100%;
- optional reasoning (the “Why” field), categories, options, or notes;
- creation and review dates;
- whether an outcome happened, did not happen, or could not be judged;
- optional outcome reflections and ratings; and
- derived on-device calibration results and record eligibility.

Hindsight also stores local drafts and preferences such as onboarding completion, appearance,
reminder choices, and haptic settings. SwiftData and Apple preference storage are authoritative
for this personal release.

## Information collected by Hindsight

Hindsight `1.0 (4)` does not collect personal information or transmit app content to the developer
or a third-party partner. It has no Hindsight account, backend, cloud-sync service, developer
telemetry, advertising SDK, or third-party analytics SDK.

The app does not collect journal content, contact information, identifiers, usage analytics,
advertising data, precise or coarse location, contacts, photos, audio, health information,
financial information, payment information, or browsing history. It does not track you across
apps or websites and does not use tracking domains.

The app’s privacy manifest declares no collected data types, no tracking, and no tracking domains.
It declares Apple’s required-reason `UserDefaults` API category with reason `CA92.1` for local
preferences.

## On-device Insights

Hindsight calculates personal calibration and other Insights locally from eligible records on your
device. These calculations may include observed outcome rate, average stated confidence,
calibration gap, confidence bands, Brier score, categories, and time horizons. Hindsight does not
upload those results or use them for advertising, profiling, or developer analytics.

Only real, due, terminal binary forecasts are eligible for calibration. Pending, example,
cancelled, could-not-judge, and not-yet-due records are excluded. This eligibility rule affects
what the app shows; it does not create any remote processing.

## Notifications

If you enable review reminders, Hindsight asks iOS for notification permission and schedules local
notifications on your device. You can deny permission or change it later in iOS Settings. Reminder
text is generic and does not include your forecast, reasoning, or journal content. Hindsight does
not use a remote push-notification server in version 1.0.

## Exporting and sharing

You can choose to export your journal as JSON or PDF. Export files are created locally. When you
use the iOS share sheet, the file goes only to the person, app, or storage destination you select.
Hindsight does not receive a copy. Review the privacy practices of any destination before sharing
an export.

Example records are explicitly separated from personal records and are not included in your
personal export.

## Example data

You may choose to add example records to understand the interface. Example records have explicit
sample identity and are kept separate from personal counts, Insights, reminders, notifications,
exports, and relationships. You can remove examples without deleting your personal records.

## Deleting your data

You can delete individual records or clear Hindsight data from within the app. The corresponding
local records, recoverable drafts, and related local notifications are removed according to the
selected action. Deleting the app also removes its local application data from that device,
subject to Apple’s device and backup behavior.

Because Hindsight `1.0 (4)` has no account or developer-held journal database, there is no remote
Hindsight account or server copy to delete.

## Security and device backups

Hindsight relies on Apple’s application sandboxing, device security, and local persistence
frameworks. Protect access to your device and Apple Account. No system can guarantee absolute
security.

Your app data may be included in device or iCloud backups according to your Apple settings and
Apple’s policies. Hindsight does not operate that backup service and does not provide its own
cross-device sync or recovery service.

Apple platform services may separately process App Store distribution, backup, or diagnostic
information under Apple’s policies and your device settings. Those services are not a Hindsight
account or backend, and Hindsight does not use them to receive your forecast text or Insights.

## Children’s privacy

Hindsight is designed and marketed as a judgment tool for adults and is not directed to children
under 13. The app does not knowingly collect personal information from children—or from any other
user—in version 1.0. The App Store age rating is determined separately from Apple’s content-rating
questionnaire and does not change this intended audience.

## Changes to this policy

This policy will be reviewed and updated before Hindsight introduces any account, server,
synchronization, telemetry, social feature, advertising, third-party data processor, or other
remote data practice. The effective date and App Store privacy answers will be updated when the
policy changes.

## Contact

Privacy or support questions: **`<USER-OWNED: DURABLE SUPPORT EMAIL>`**

Public support page: **`<USER-OWNED: PUBLIC HTTPS SUPPORT URL>`**

This draft must receive owner/legal approval and be published at the public HTTPS privacy-policy
URL before external TestFlight distribution or App Store submission.
