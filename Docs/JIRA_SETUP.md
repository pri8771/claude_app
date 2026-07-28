# Jira Setup — custom fields for the planning experiment

Everything here must be created in the **Jira admin UI**. The API can create issues but not
projects, custom fields, or issue types.

**Project:** create `HIND` / "Hindsight" (Scrum or Kanban — either works).

---

## 1. Use built-in fields where they already fit

Do **not** create custom fields for these. Duplicating them causes drift.

| Need | Use | Values |
|---|---|---|
| Function tag | **Labels** (built-in) | `ENG` `QA` `DESIGN` `MKT` `UA` `SALES` `OPS` `LEGAL` `PM` |
| Epic grouping | **Parent / Epic Link** (built-in) | One epic per E/M/T/V group |
| Workflow state | **Status** (built-in) | Default is fine |
| Dependencies | **Issue links** — "is blocked by" | Not a text field |

> **On `Original Estimate`:** Jira's built-in time-tracking field looks like a fit for Baseline,
> but it is editable and entangled with worklogs. Use a dedicated locked Number field instead —
> immutability is the whole point.

---

## 2. Custom fields to create — 6 total

| # | Field name | Type | Applies to | Purpose |
|---|---|---|---|---|
| 1 | **Task ID** | Text field (single line) | Task, Story, Bug | Stable cross-system ID: `M1.1`, `E4.3`, `T6`. Never renumber |
| 2 | **Baseline Est** | Number field | Task, Story, Bug | Ideal days. **Set once, never edited** |
| 3 | **Current Est** | Number field | Task, Story, Bug | Revised estimate; every change needs a CR |
| 4 | **Actual** | Number field | Task, Story, Bug | Ideal days at completion |
| 5 | **Delay Cause** | Select List (single choice) | Task, Story, Bug | Required when Actual > Baseline |
| 6 | **Risk** | Select List (single choice) | Task, Story, Bug | `LOW` `MED` `HIGH` |

**Delay Cause options** — exactly these six, spelled this way:

```
change-request
underestimate
dependency
external-blocker
rework
discovery
```

**Optional 7th:** `Horizon` — Select List with `MVP` `H2` `H3` `H4`. Only worth it if you don't
want to use fix-versions or components for the same grouping.

---

## 3. Change Requests as their own issue type

Cleaner than a text field, because "Tasks Affected" becomes real issue links you can traverse.

**Create issue type:** `Change Request` (standard level, not sub-task).

Fields on it — three of these are reused from above, so only two are new:

| Field | Type | New? |
|---|---|---|
| **CR ID** | Text (single line) — `CR-001` | reuse `Task ID` instead if you prefer |
| **Est Delay** | Number — **stated at raising, never revised** | **new** |
| **Actual Delay** | Number | **new** |
| **Delay Cause** | Select List | reuse #5 |
| **Lesson** | Text field (multi-line) | **new** |
| CR status | use built-in **Status** with a workflow: `proposed → accepted / rejected / deferred` | — |
| Tasks affected | **Issue links** — "relates to" | — |

So the true total is **6 task fields + 3 CR fields = 9 custom fields.**

---

## 4. Enforcement — how immutability actually holds

Jira will not lock a field by default. Three options, weakest to strongest:

1. **Convention + audit (recommended to start).** Jira records every field change in issue
   history, so an edited Baseline is *detectable* even if not prevented. Cheap, and detection is
   most of the value.
2. **Field configuration → read-only** after initial population. Blunt: it also blocks legitimate
   corrections at creation time.
3. **Workflow validator / automation rule.** An automation rule that reverts changes to
   `Baseline Est` and comments on the issue. Strongest, most setup.

Also worth adding as an automation rule: **require `Delay Cause` when `Actual` > `Baseline Est`
on transition to Done.** That single rule is what keeps the experiment honest — it is the
difference between "we were late" and knowing *why*.

---

## 5. Board views to create

Filter the board by the Labels above:

- **By function** — swimlanes on Labels, so MKT/UA/LEGAL work is visible next to ENG rather than
  buried in a backlog
- **Active (M1.0)** — filter `Task ID ~ "M1*" OR "T*"` — current work only
- **Estimate accuracy** — a filter of Done issues showing Baseline / Actual / Delay Cause side by
  side. This is the report the whole exercise exists to produce
- **Open CRs** — issue type = Change Request, status != rejected

---

## 6. After the fields exist

Send me the custom field IDs (`customfield_10xxx`) — visible in **Settings → Issues → Custom
fields → ⋯ → View field information**, in the URL. With those I can create all 117 issues
(92 post-MVP + 25 MVP/TestFlight/voice) with every field populated, epics linked, and blocked-by
links set.

Until then the repo remains the system of record, and nothing is lost by waiting.
