# Local Device Testing

Use this pass before sending a TestFlight build.

## Build Target

- Scheme: `Hindsight`
- Bundle ID: `com.hindsight.pchordia.app`
- Minimum iOS: 17.0
- Signing: automatic, team `YR2QPBY4TR`

## First-Run Pass

1. Install on a physical iPhone from Xcode.
2. Confirm the app icon appears on the Home Screen.
3. Launch cold and verify dark launch background, splash, then onboarding.
4. Complete onboarding with **Start First Decision**.
5. Create a decision with two options, at least one prediction, and a near review date.
6. Accept the notification prompt when saving the decision.
7. Confirm the decision appears on Today and Decisions.

## Core Loop Pass

1. Open the saved decision.
2. Choose an option if none is selected.
3. Tap **Review early** or wait until the review date.
4. Save an outcome review, including prediction verdicts.
5. Verify status changes to Reviewed and Insights updates.

## Data Ownership Pass

1. Export JSON and confirm the share sheet appears.
2. Export PDF and open the generated file preview.
3. Use **Load sample data** twice; it should not duplicate data when the store already has decisions.
4. Use **Clear all data**, confirm, and verify Today returns to the empty state.

## Device QA Notes

- Test with notifications allowed and denied.
- Test airplane mode; all core features should still work.
- Check Dynamic Type at the largest accessibility size.
- Check VoiceOver on capture and review.
- If a notification tap only opens the app and does not deep-link to the decision, log it as a v1.0 polish bug.
