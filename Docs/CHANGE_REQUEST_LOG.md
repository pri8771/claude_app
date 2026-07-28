# Change Request Log

**Purpose:** every deviation from `POST_MVP_MASTER_PLAN.md` Baseline v1.0 is recorded here.
Nothing in the baseline is ever edited. This log is how the plan legally changes.

**Rules**

1. Raise the CR **before** doing the work, not after. A backfilled delay estimate is worthless.
2. State the estimated delay at the time of raising, and never revise that number — record the
   actual separately. The gap between them is the measurement.
3. Every affected task ID must be listed.
4. `rejected` and `deferred` CRs stay in the log permanently. Decisions not taken are data too.

---

## Template

```markdown
### CR-00N — <short title>

- **Raised:** YYYY-MM-DD by <who>
- **Status:** proposed | accepted | rejected | deferred
- **Tasks affected:** E1.5, E1.7
- **What changes:** <one paragraph>
- **Why:** <rationale — what did we learn that we did not know at baseline?>
- **Estimated delay:** N days *(stated at raising, never revised)*
- **Actual delay:** N days *(filled at completion)*
- **Delay cause:** change-request | underestimate | dependency | external-blocker | rework | discovery
- **Lesson:** <what should the next baseline do differently?>
```

---

## Open

*(none yet — baseline frozen 2026-07-28)*

---

## Closed

*(none yet)*

---

## Running totals

| Metric | Value |
|---|---|
| CRs raised | 0 |
| CRs accepted | 0 |
| CRs rejected | 0 |
| CRs deferred | 0 |
| Total estimated delay | 0 days |
| Total actual delay | 0 days |
| CR estimate accuracy (actual ÷ estimated) | — |

---

## Pre-baseline change requests

Changes that already occurred this session, recorded retroactively for completeness. These
pre-date the baseline and are **not** counted in the metrics above — but they are the first real
data points about how this project changes direction.

### CR-000a — Revert the Call/Receipt pivot

- **Raised:** 2026-07-28 by Priyansh
- **Status:** accepted
- **Tasks affected:** all of the 22-task pivot plan (T1–T22)
- **What changes:** the entire Call / Timestamped Receipt / Brier-calibration pivot was reverted;
  the product returned to the original Decision-journal design with its original analytics screen.
- **Why:** the original Insights/analytics design was preferred. The pivot's lightweight capture
  was valuable but was not the reason for the change.
- **Estimated delay:** n/a (pre-baseline)
- **Actual cost:** ~6 phases of implementation work archived to `archive/call-pivot-complete`
- **Delay cause:** `change-request`
- **Lesson:** the pivot bundled two separable things — *lightweight capture* and *a new analytics
  model*. Only the analytics change was unwanted. **Future plans should decompose changes so the
  good half survives a reversal.** The MVP now re-adopts lightweight capture against the original
  model, which is what should have been proposed initially.

### CR-000b — Voice-first capture becomes the product thesis

- **Raised:** 2026-07-28 by Priyansh
- **Status:** accepted
- **Tasks affected:** created E1 in its entirety
- **What changes:** voice/Siri capture moved from "a convenience feature" to the primary capture
  path, on the grounds that the app has too many taps to be habitually usable.
- **Why:** capture friction was correctly identified as the core adoption blocker.
- **Delay cause:** `discovery`
- **Lesson:** the friction problem was visible in the original audit but was treated as a UI
  concern rather than an existential one. **Rank problems by whether they block adoption, not by
  how hard they are to fix.**

### CR-000c — Baseline task count corrected 78 → 92

- **Raised:** 2026-07-28 by Claude (self-reported)
- **Status:** accepted
- **Tasks affected:** none (documentation only)
- **What changes:** the baseline commit claimed 78 tasks; the epic breakdown actually totals 92.
  Corrected in the plan and in the Notion hub.
- **Why:** the total was summarised from memory rather than counted from the list.
- **Estimated delay:** 0 days
- **Actual delay:** 0 days
- **Delay cause:** `underestimate`
- **Lesson:** an 18% undercount of a list that was *already fully written down* is the cheapest
  possible warning about estimate quality. Arithmetic on the plan must be computed, not recalled —
  and every effort estimate in Baseline v1.0 should be read as optimistic by at least that margin.
