# Local Device Testing

Use this pass before sending a TestFlight build.

## Build Target

- Scheme: `Hindsight`
- Bundle ID: `com.pchordia.hindsight`
- Minimum iOS: 17.0
- Signing: automatic, team `796XH483R4`

## First-Run Pass

1. Install on a physical iPhone from Xcode.
2. Confirm the app icon appears on the Home Screen.
3. Launch cold and verify dark launch background, splash, then onboarding.
4. Complete onboarding and open **Quick Capture**.
5. Enter a prediction, choose one confidence chip and a short review horizon, then save.
6. Confirm the prediction appears on Today and Decisions.
7. Open **Add detail** and verify the retained detailed wizard can still save a full decision.

## Core Loop Pass

1. Use a due prediction in Today’s **Ready to Revisit** section.
2. Open the direct **Resolve Prediction** action without entering the full detail screen.
3. Save Accurate, Partly Accurate, or Inaccurate and verify the next card appears exactly once.
4. Verify the completed Quick Capture leaves the review queue.
5. Open Insights and verify the 80%+ card uses resolved predictions only.

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
