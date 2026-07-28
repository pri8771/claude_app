# Prompt for Claude in Chrome — Jira project + field setup

Paste the block below into Claude in Chrome. It does admin/configuration work only;
issue creation happens afterwards via API.

**Assumed spellings:** "Hindsight" (key `HIND`) and "AuraFit" (key `AURA`). Correct before running
if wrong — project keys are painful to change later.

---

```
I need you to set up two Jira projects and a shared custom field schema in my
Atlassian site: https://priyanshchordia-1779372280524.atlassian.net

This is admin/configuration work ONLY. Do NOT create any issues or tickets —
those get created separately via API afterwards.

CONTEXT (so you can make sensible judgment calls)
I'm running a deliberate test of planning accuracy across my projects. Every task
gets an immutable baseline estimate; actuals are measured against it and every
delay is attributed to a cause. The schema below exists to support that
measurement. If a choice comes up that isn't covered here, prefer whatever
preserves the ability to (a) keep a baseline value unedited and (b) report
actual-vs-baseline across many issues.

STEP 1 — Create two projects
Both must be COMPANY-MANAGED (classic), NOT team-managed. This is not optional:
I need global custom fields shared across both projects, workflow validators, and
automation rules — all of which are limited or absent in team-managed projects.
My existing projects AIP, DT, MALA and PCH are company-managed if you need a
reference for what the creation flow looks like.

  Project 1 — Key: HIND | Name: Hindsight | Template: Kanban
  Project 2 — Key: AURA | Name: AuraFit   | Template: Kanban

If Jira does not offer a company-managed option, STOP and tell me before creating
anything. Do not silently fall back to team-managed.
If either project key is already taken, STOP and tell me — do not invent a
different key.

STEP 2 — Create 9 global custom fields
Settings → Issues → Custom fields → Create field.

Because these projects are company-managed, custom fields are GLOBAL — create
each field ONCE and associate it with BOTH projects. Do not create duplicates
per project.

Fields 1-6 apply to Task / Story / Bug:

1. Name: "Task ID"        | Type: Text Field (single line)
   Description: Stable cross-system ID, e.g. M1.1, E4.3, T6. Never renumber.

2. Name: "Baseline Est"   | Type: Number Field
   Description: Ideal days. IMMUTABLE — set once at baseline, never edited.

3. Name: "Current Est"    | Type: Number Field
   Description: Revised estimate. Any change requires a linked Change Request.

4. Name: "Actual"         | Type: Number Field
   Description: Ideal days actually spent, recorded at completion.

5. Name: "Delay Cause"    | Type: Select List (single choice)
   Description: Required when Actual exceeds Baseline Est.
   Options — exactly these six, lowercase and hyphenated as written:
     change-request
     underestimate
     dependency
     external-blocker
     rework
     discovery

6. Name: "Risk"           | Type: Select List (single choice)
   Description: Confidence in the estimate.
   Options: LOW, MED, HIGH

Fields 7-9 apply to the Change Request issue type created in Step 4:

7. Name: "Est Delay"      | Type: Number Field
   Description: Delay in days estimated AT THE TIME THE CR IS RAISED. Never revised.

8. Name: "Actual Delay"   | Type: Number Field
   Description: Delay in days actually incurred.

9. Name: "Lesson"         | Type: Text Field (multi-line / paragraph)
   Description: What should the next baseline do differently?

STEP 3 — Associate fields with screens (IMPORTANT — most setups fail here)
Creating a custom field is not enough. In company-managed projects a field is
invisible and cannot be set via the API until it is added to the relevant
screens. For all nine fields, ensure they are on the Create, Edit, and View
screens for BOTH the HIND and AURA projects.

The field creation wizard usually offers a screen-association step. If you
skipped it, go to Settings → Issues → Screens and add them manually.

VERIFY THIS: open the Create Issue dialog in HIND, then again in AURA, and
confirm the fields actually appear. If any are missing, fix the screen
configuration before moving on. Do not report this step complete without having
looked at both dialogs.

STEP 4 — Create a "Change Request" issue type
- Settings → Issues → Issue types → Add issue type
- Name: Change Request
- Level: Standard (NOT sub-task)
- Add it to the issue type scheme for BOTH HIND and AURA.

Give it a workflow with these statuses: proposed → accepted / rejected / deferred.
Also make the existing "Delay Cause" and "Task ID" fields available on this issue
type, and add fields 7-9 to its screens.

STEP 5 — Automation rule (the single most important rule)
Settings → Automation → Create rule. Apply to both projects (or create it twice):
- Trigger: Issue transitioned to Done
- Condition: "Actual" is greater than "Baseline Est"
- Action: if "Delay Cause" is empty, block the transition, or if blocking is not
  available as an action, add a comment and flag the issue.
Tell me which approach you were able to configure.

STEP 6 — Board views
On the HIND board create these saved filters/views:
- "By function" — swimlanes grouped by Labels
- "Active (M1.0)" — filter: Task ID starts with M1, T, or V
- "Estimate accuracy" — Done issues showing Task ID, Baseline Est, Actual, Delay Cause
- "Open CRs" — issue type = Change Request, status != rejected

On the AURA board, create just "Estimate accuracy" and "Open CRs" for now —
AuraFit has no task breakdown yet.

I will use built-in Labels for function tags (ENG, QA, DESIGN, MKT, UA, SALES,
OPS, LEGAL, PM) and built-in issue links for dependencies. Do NOT create custom
fields for those.

STEP 7 — Report back
When finished, give me:
(a) The custom field ID for all 9 fields, as customfield_10xxx. Find each at
    Settings → Issues → Custom fields → ⋯ menu → View field information; the ID
    is in the page URL.
(b) Confirmation that all 9 fields appear in the Create Issue dialog in BOTH
    HIND and AURA.
(c) Confirmation that both projects are company-managed.
(d) Which automation approach you configured in Step 5.
(e) Anything you could not complete, and why.

RULES
- Do not create, edit, or delete any issues.
- Do not modify my existing projects: AIP, DT, MALA, OR, PCH, UN.
- Custom fields are global and shared across the whole site. If a field name
  already exists, STOP and tell me — do not reuse, rename, or edit an existing
  field, since that could affect my other projects.
- Ask before anything destructive, and before changing any global setting whose
  blast radius extends beyond HIND and AURA.
- Do not guess at values I haven't specified. If a required setting isn't
  covered above, ask me.
- Report what actually happened, including partial failures. Do not report a
  step as complete unless you verified it in the UI.
```
