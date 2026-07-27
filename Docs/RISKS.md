# Risks

| ID | Risk | Probability | Impact | Mitigation | Owner | Status |
|---|---|---|---|---|---|---|
| HIND-R01 | Capture abandonment from too many required fields. | high | high | Approve and implement quick-capture contract. | Product worker | open |
| HIND-R02 | Insights imply patterns from insufficient data. | high | high | Sample thresholds, explanatory states, and statistics tests. | Insights worker | open |
| HIND-R03 | Demo records mix with or delete user records. | low | high | Stable identifiers, idempotency, targeted deletion tests. | Data worker | open |
| HIND-R04 | Reminder state diverges from decisions or permissions. | medium | high | Abstraction, reconciliation tests, and device QA. | iOS worker | open |
| HIND-R05 | Existing dirty notification/review changes are overwritten. | medium | high | Start with git status and preserve overlapping work. | All workers | open |
