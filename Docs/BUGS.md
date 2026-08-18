# Bugs

| ID | Severity | Area | Summary | Status | Evidence |
|---|---|---|---|---|---|
| HIND-B01 | high | Capture layout | Sticky navigation competes with lower controls on the audited iPhone Air wizard screen. | confirmed | 2026-07-22 simulator audit |
| HIND-B02 | release_blocking | Quality | The Xcode project has no automated test target. | resolved | commit f3a0557 (T1-fix: app-hosted test target) |
| HIND-B03 | high | Resolution | Outcome review forces verdict selection, preventing save of pending predictions. | resolved | commits 2ad34e6 (T2: kill preselected Correct) + 5c366eb (T5: persistence boundary) |
| HIND-B04 | high | Data safety | Demo data removal used title heuristic, risking deletion of user records. | resolved | commit ee56907 (T3: UUID-only identity) |
| HIND-B05 | high | Today crash | `TodayView` trapped (`EXC_BREAKPOINT`, index out of range) when saving an outcome review shrank `upcomingDecisions` while a stale `ForEach` index from an earlier query evaluation was still in use. | fixed_unmerged | Fixed by commit 59938e2 on branch `fix/todayview-forecast-crash` (2026-08-14). Affected builds: **none uploaded**. Build 4 (commit f7935cd, 2026-08-10) has the safe `ForEach(Array(upcomingDecisions.prefix(5)))` shape; the index-then-resubscript regression was introduced in post-build-4 WIP checkpoint c66c690 (2026-08-11) — verified 2026-08-18 via `git diff f7935cd c66c690 -- Hindsight/Views/TodayView.swift`. Severity lowered from release_blocking on 2026-08-18 because no shipped build contains it; any 1.1 build must be cut from a branch containing 59938e2 (local `factory/pilot-1.1` already does; `origin/main` is behind and has neither c66c690 nor f7935cd). |
| HIND-B06 | medium | Insights/Settings title | Large navigation title on the Insights and Settings tabs renders as a blank band at scroll offset 0; the inline title appears only after scrolling. | observed | 2026-08-18, Debug simulator build of `d0189bc` on iPhone 17 Pro Max and iPad Pro 13-inch (M5), iOS 26.5 (see `quality/store-assets/1.0-4/README.md`). Same `.navigationTitle` configuration is in build 4 (`f7935cd`); not verified on the build-4 binary, iOS 26.4.1, or a physical device. Today/History/other sheets use `.navigationBarTitleDisplayMode(.inline)` and are unaffected. |

“Too many clicks” is tracked as a product risk and planned redesign, not a single
runtime defect.

Record observed behavior, reproduction steps, expected behavior, environment, and evidence. Do not convert assumptions into confirmed bugs.
