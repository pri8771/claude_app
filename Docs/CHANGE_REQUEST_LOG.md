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

### CR-001 — MVP had no baselined task list

- **Raised:** 2026-07-28 by Claude (gap found when asked "how do we get to MVP?")
- **Status:** accepted
- **Tasks affected:** none in Baseline v1.0 — creates a new Baseline M1.0 that precedes it
- **What changes:** `POST_MVP_MASTER_PLAN.md` covers H2–H4 only, on the assumption the MVP was
  already planned. It was not: the MVP existed as a recommendation in `PRODUCT_BRAINSTORM.md`
  with no task breakdown, estimates, or release track. Added `MVP_PLAN.md` (Baseline M1.0):
  23.5 days to first TestFlight, 41.5 to voice-complete.
- **Why:** planning started at the wrong end. The post-MVP plan was requested and delivered
  before the thing it comes after had been costed.
- **Estimated delay:** 0 days (found before execution started)
- **Actual delay:** 0 days
- **Delay cause:** `discovery`
- **Lesson:** **plan the nearest milestone first.** A detailed 231-day post-MVP plan sat on top of
  an uncosted MVP — precision at the far horizon while the near one was a sketch. Sequence
  planning the way work executes: nearest deliverable first, in the most detail.

**Two findings from writing M1.0 that reduce risk in Baseline v1.0:**

1. The App Group store migration (`E1.1`/`E1.2`) — the highest-risk item in Baseline v1.0 — is
   **not required for the MVP**. In-app voice runs in the app's own process; only widgets and
   Siri extensions need the shared container. That risk moves later than the baseline implies.
2. `E5.4` (manual VoiceOver audit) is duplicated as `M1.10`. `E5.4` should be marked superseded
   rather than done twice.

### CR-002 — Jira field configuration blocks all issue creation

- **Raised:** 2026-07-28 by Claude (found by test-creating one issue before bulk creation)
- **Status:** accepted
- **Tasks affected:** E6.1, E6.2, E6.3
- **What changes:** the HIND project inherited a shared field configuration and screen scheme from
  existing projects. 30 fields are marked required, ~20 of them belonging to unrelated projects
  (Execution Agent, Agent Plan, Commit SHA(s), Delegation Mode, …). Issue creation fails outright.
  Fixing it requires a dedicated field configuration, field configuration scheme, screen, screen
  scheme, and issue type screen scheme for HIND — none of which were in the original 1-day estimate
  for E6.2.
- **Why:** new Jira projects inherit shared configuration objects by default. The baseline assumed
  "create custom fields" was the whole job; the actual job is "isolate this project's configuration
  from every other project's."
- **Estimated delay:** 0.5 days
- **Actual delay:** *(pending)*
- **Delay cause:** `discovery`
- **Lesson:** **test one before creating many.** A single test issue surfaced a total blocker in one
  API call; creating 117 blind would have produced 117 failures or, worse, 117 issues carrying
  fabricated values for `Actual` and `Delay Cause`. Any bulk operation against an unfamiliar system
  should be preceded by a single-item probe.

**Second, subtler finding:** `Actual` and `Delay Cause` were marked required *at creation*. Those
fields are only meaningful once a task is finished — requiring them at creation would have made
every issue start life with a fabricated actual and a fabricated cause, corrupting the exact
measurement this project exists to produce. This is the same error the app guards against by
refusing to default a confidence value the user never gave. **Never make a field required at a
point in the lifecycle where its true value cannot be known.**
