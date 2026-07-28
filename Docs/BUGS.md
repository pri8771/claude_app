# Bugs

| ID | Severity | Area | Summary | Status | Evidence |
|---|---|---|---|---|---|
| HIND-B01 | high | Capture layout | Sticky navigation competes with lower controls on the audited iPhone Air wizard screen. | confirmed | 2026-07-22 simulator audit |
| HIND-B02 | release_blocking | Quality | The Xcode project has no automated test target. | resolved | commit f3a0557 (T1-fix: app-hosted test target) |
| HIND-B03 | high | Resolution | Outcome review forces verdict selection, preventing save of pending predictions. | resolved | commits 2ad34e6 (T2: kill preselected Correct) + 5c366eb (T5: persistence boundary) |
| HIND-B04 | high | Data safety | Demo data removal used title heuristic, risking deletion of user records. | resolved | commit ee56907 (T3: UUID-only identity) |

“Too many clicks” is tracked as a product risk and planned redesign, not a single
runtime defect.

Record observed behavior, reproduction steps, expected behavior, environment, and evidence. Do not convert assumptions into confirmed bugs.
