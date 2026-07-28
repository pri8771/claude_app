# Prompt 2 for Claude in Chrome — fix HIND field configuration

The projects and custom fields were created successfully. But **no issue can be created in HIND**:
30 fields are marked required, including ~20 that belong to other projects entirely.

Confirmed by an API create attempt, which failed with:

```
Execution Agent is required. Agent Plan is required. Commit SHA(s) is required.
Delegation Mode is required. Actual Model / Effort Used is required.
Accountable Human is required. Source of Truth is required. Branch Name is required.
Execution Profile is required. Deferred Disposition is required. Approvers is required.
Acceptance Criteria is required. Requirements is required. Current State is required.
Estimated Start Date is required. Estimated Time to Complete is required.
External Reference ID is required. Change type / risk / reason is required.
Actual start / Actual end is required. Environment is required.
Components is required. Fix versions is required. Affects versions is required.
Due date is required. Actual is required. Delay Cause is required.
```

---

```
Two things need fixing in my Jira site
(https://priyanshchordia-1779372280524.atlassian.net) before I can create issues
in the HIND (Hindsight) project. Right now issue creation fails completely.

THE PROBLEM
The HIND project is using a shared field configuration and screen scheme that
belong to my other projects. Two consequences:

1. About 20 fields from unrelated projects are attached to HIND's screens and
   marked REQUIRED — things like "Execution Agent", "Agent Plan", "Commit
   SHA(s)", "Delegation Mode", "Accountable Human", "Branch Name", "Approvers",
   "Acceptance Criteria". These have nothing to do with this project.

2. Several fields that SHOULD be optional are marked required, including
   "Actual", "Delay Cause", "Due date", "Components", "Fix versions", and
   "Affects versions".

Point 2 matters beyond convenience: "Actual" and "Delay Cause" are only
meaningful once a task is FINISHED. Forcing them at creation time would mean
every issue is born with a made-up actual and a made-up delay cause, which
destroys the exact measurement this project exists to produce.

FIX 1 — Give HIND its own field configuration
- Settings → Issues → Field configurations
- Copy the configuration HIND currently uses; name the copy
  "Hindsight Field Configuration"
- In that copy, set field requirement as follows:

  REQUIRED (only these three):
    Summary
    Task ID
    Baseline Est
  (Making Baseline Est required is deliberate — a task should not exist without
  an estimate. That is the discipline being tested.)

  OPTIONAL (everything else), explicitly including:
    Current Est, Actual, Delay Cause, Risk
    Due date, Components, Fix versions, Affects versions, Environment
    and every field belonging to another project (Execution Agent, Agent Plan,
    Commit SHA(s), Delegation Mode, Actual Model / Effort Used, Accountable
    Human, Source of Truth, Branch Name, Execution Profile, Deferred
    Disposition, Approvers, Acceptance Criteria, Requirements, Current State,
    Estimated Start Date, Estimated Time to Complete, External Reference ID,
    Change type, Change risk, Change reason, Actual start, Actual end)

- Settings → Issues → Field configuration schemes → create
  "Hindsight Field Configuration Scheme", mapping ALL issue types to
  "Hindsight Field Configuration"
- Project settings → HIND → Fields → associate that scheme with HIND

FIX 2 — Give HIND its own clean screens
The foreign fields should not appear on HIND's screens at all, not merely be
optional.

- Settings → Issues → Screens → create a screen named "Hindsight Screen"
  containing ONLY:
    Summary, Description, Assignee, Priority, Labels, Linked Issues, Parent,
    Due date, Components, Fix versions,
    Task ID, Baseline Est, Current Est, Actual, Delay Cause, Risk
- Create "Hindsight Screen Scheme" using that screen for Create, Edit and View
- Create an issue type screen scheme mapping all HIND issue types to it, and
  associate it with the HIND project
- For the "Change Request" issue type specifically, also include: Est Delay,
  Actual Delay, Lesson

VERIFY BEFORE REPORTING BACK
Open the Create Issue dialog in HIND and confirm:
- It shows Task ID, Baseline Est, Current Est, Actual, Delay Cause, Risk
- It does NOT show Execution Agent, Agent Plan, Commit SHA(s), or any other
  field from my other projects
- Only Summary, Task ID and Baseline Est are marked required
- You can actually create a test issue filling in ONLY those three required
  fields. Create one, confirm it saves, then DELETE it.

IMPORTANT — do not damage my other projects
Field configurations, screens and schemes are shared objects. Always COPY and
create new ones for HIND; never edit the existing shared configuration, screen,
or scheme in place, because AIP, DT, MALA, OR, PCH and UN depend on them. If you
find yourself about to modify a shared object that another project uses, stop
and tell me instead.

Do not apply any of this to the AURA project yet — HIND only.

REPORT BACK
(a) Confirmation that a test issue created successfully with only the three
    required fields, and that you deleted it
(b) The names of the new field configuration / scheme / screen objects you created
(c) Confirmation that no shared object used by another project was modified
(d) Anything you could not complete and why
```
