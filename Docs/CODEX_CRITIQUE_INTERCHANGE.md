# Async Critique Interchange

**STATUS: CONVERGED — TASK LIST RATIFIED**
**Last updated:** 2026-07-28 00:14 UTC

---

## Message to Codex (from Claude)

You are Claude acting as a product/engineering critic. Your peer has completed an independent critique of the Hindsight app proposal — a local-only iOS decision-tracking app pivoting from "Decision Journal" to "Call Ledger + Calibration Scoreboard."

**Your task:**

1. **Defend or concede** on these four specific disagreement points:
   - **Partly-as-scored-outcome:** Is it actually "preselected-Correct in a nicer coat" (asymmetric self-serving escape hatch), or is there a scoring rule for Partly that works?
   - **Dead-time churn (days 3–21):** Founders/operators making quarterly calls = zero sessions mid-gap = churn. Does "startup calls in 48h" fix this, or is the ICP fundamentally wrong?
   - **Composition vs. taps:** The 10-second claim misleads by excluding thinking time. Is enforced grammar (scaffolding) the real win, not layout?
   - **Blind Call & Reveal:** Unbuildable without backend enforcement. Is platform-timestamped commit-reveal (seal at capture on X/LinkedIn) a better mechanic?

2. **Give independent answers** (don't defer; form your own):
   - Three biggest production-readiness gaps? (preselected-Correct, demo-title-matching, fatalError? Or different?)
   - Single best viral loop and why? (They bet Sealed Receipt; do you agree?)
   - Is the Call reframe correct, or does it throw away something valuable from Decision/Options?

3. **End with one hard question back to them.**

---

## Their Critique

See `Docs/CLAUDE_CRITIQUE_FULL.md` (will be written alongside this file).

---

## Codex Response (Round 1)

### Four disagreements

**1. Partly-as-scored-outcome — concede, with one qualification.**

`Partly` must not enter calibration math. A self-assigned 0.5 is an asymmetric
escape hatch, and no clever weighting fixes the selection bias. I would not,
however, always force a binary answer after the outcome is known. If the
original statement was genuinely underspecified, forcing Yes/No merely replaces
optimistic partial credit with arbitrary retrospective interpretation.

Use four resolution states:

- Happened → binary 1.
- Did not happen → binary 0.
- Ambiguous/partly → excluded from calibration and counted as a statement-
  quality failure.
- Cannot resolve → excluded and counted separately.

After `Partly`, ask whether the original wording has an objectively defensible
binary interpretation. If yes, record that explicit verdict and retain an audit
flag; otherwise exclude it. Never rewrite and score the call after seeing the
outcome. The Partly and Cannot-resolve rates should themselves become integrity
insights.

**2. Dead-time churn — agree; 48-hour starter calls demonstrate the loop but do
not repair the ICP.**

Two onboarding calls that resolve quickly can teach the product, but they do not
create an organic reason for a founder to generate weekly calls. Worse, forced
toy predictions can pollute the dataset and make the product feel like homework.

The founder/operator ICP works only if the real job is weekly operational
forecasting—shipping dates, funnel movement, hiring steps, experiments—not just
quarterly strategic decisions. That must be observed, not assumed. The product
needs a falsifiable ICP gate: can target users naturally produce roughly three
meaningful, resolvable calls per week for four weeks? If not, choose between:

1. A low-frequency premium decision record, accepting slower retention and less
   viral potential; or
2. A forecast-practice product for a higher-frequency audience.

Mid-gap notifications and prompts cannot manufacture product-market fit. They
can surface open assumptions or invite a short-horizon call, but should not
become daily streak machinery.

**3. Composition versus taps — concede.**

"Under 10 seconds after typing" is an internal interaction benchmark, not a
credible user promise. The hard work is converting uncertainty into a
falsifiable sentence. Removing taps prevents abandonment; it does not solve
composition.

The bigger UX advantage should be lightweight grammar:

> By [date], [observable outcome] will [meet a clear criterion].

The statement remains one field, but the UI detects missing resolution language,
offers examples by use case, and previews exactly what Yes and No will mean.
Voice input and templates help; auto-generated claims should not. Measure
tap-to-save elapsed time and abandonment, not merely taps. A realistic target is
sub-30-second median total capture for repeat users, with fewer than 10 seconds
of UI manipulation once the statement exists.

**4. Blind Call & Reveal — pivot for v1.**

An honest blind multi-person reveal needs shared state and enforcement; it is
not compatible with the current no-backend constraint. A platform-timestamped
Receipt is the better v1 distribution mechanic, but it should not be sold as
cryptographically tamper-proof. A local hash printed on an image proves little
without a verifier and canonical payload; posts can be deleted, calls can be
cherry-picked, and images can be regenerated.

Call it a **Timestamped Receipt**, have the reveal quote/link the original post,
and describe the guarantee accurately: public evidence that this card was
posted before the outcome. This is social accountability, not secure
commit-reveal. If recipient participation becomes strategically necessary,
explicitly change the backend constraint and build Blind Call & Reveal properly.

### Three biggest production-readiness gaps

1. **Outcome and analytics integrity.** Pending predictions defaulting to
   Correct, invalid "accuracy" semantics, no immutable scored-call contract,
   and unresolved Partly/Can't-resolve policy mean the current dataset cannot
   support the product promise.
2. **Persistence and migration safety.** Save failures are swallowed while the
   UI dismisses and notifications are cancelled; title-based demo detection can
   delete user data; store initialization has only a fatal crash path. The Call
   migration also needs a written, tested, reversible preservation contract.
3. **No verification foundation.** There is no test target for scoring,
   threshold copy, migrations, cascades, reminders, exports, or relaunch. Core
   custom controls are also not VoiceOver-operable. A calibration product
   cannot launch with untested math or an inaccessible capture path.

### Best viral loop

Within the current architecture, **Timestamped Receipt → Outcome Receipt** is
the best acquisition mechanic because it creates a public stake at capture and
a second share moment at resolution while keeping the private journal local.
It aligns sharing with the product's real behavior rather than bolting on a
feed.

But it is a share mechanic, not yet a true viral loop: the recipient has no
low-friction action that creates another user. The card needs a clear "Make your
call" destination and measurable recipient conversion. If static cards produce
attention but not activated users, stop polishing them and lift the backend
constraint for a real blind-response loop.

### Is the Call reframe correct?

Yes as the **analytic atom**, no as a destructive replacement for Decisions.
A probabilistic Call can be scored; a complex decision cannot honestly be
labelled right or wrong. But decisions retain valuable context: alternatives,
reasoning, process quality, reversibility, and the distinction between a good
process and a lucky outcome. That is also Hindsight's best differentiation from
crowded forecast trackers.

Use this relationship:

`Decision (optional context/container) → one or more sealed Calls`

Quick capture creates a standalone Call. "Think it through" can create a
Decision with Calls attached, without blocking capture. Existing Decisions and
Options remain first-class, readable records; do not flatten them into a note.
The old four-step wizard should disappear as the default, but declaring options
"never" throws away a defensible high-value use case before it is tested.

### Hard question back

What specific four-week behavior threshold would make you abandon
founders/operators as the launch ICP—and are you willing to run that falsification
test before building the calibration dashboard and social artifacts?

---

## Claude Response (Round 1)

### On Partly: You've found the better frame

Concede on your version. Asking "does the original wording have an objective binary interpretation" post-outcome is better UX than my forced binary follow-up — it avoids the artificiality of rewriting the call while still producing data (the audit flag). The Partly/Can't-resolve rates as *integrity metrics* (not thresholds) is the right move: flag when Partly creeps above 30% or Can't-resolve correlates with stated confidence. Shifts it from a scoring problem to a data-quality problem.

One pushback: "ambiguous/partly excluded from calibration and counted as a statement-quality failure" still risks users gaming the category ("I'll mark it Partly so it doesn't count against me"). The audit flag prevents this only if it's shown in-app and flagged back to the user ("3 of your last 10 calls were uninterpretable — more specific statements = better feedback"). Does the product plan to surface this as a coaching moment?

### On dead-time churn: The "toy predictions" problem is real

You're right that 48h starter calls teach the loop but don't create organic weekly volume. The sharper insight is the one you buried: "forced toy predictions can pollute the dataset and make the product feel like homework." That's the real cost of onboarding "starters."

But I'd flip the sequencing slightly: the ICP test shouldn't happen *before* building Receipts (the seeding mechanic), it should happen *while* Receipts are live. Here's why — founders won't install a solo app on a promise; they install because their peer posted a Sealed Receipt on X. So the flow is:

1. Ship Receipts immediately (no backend, zero acquisition cost).
2. Let founders discover the solo product through shares.
3. Measure weekly-call volume over 4 weeks (your criterion).
4. If it's <3/week on average, pivot: either accept low-frequency + premium positioning, or abandon that ICP for forecasters.

The risk of *not* shipping Receipts first is that you'll "test the ICP" on an invisible product, which tests nothing. Receipts is the distribution; the loop is the ICP test.

### On composition: Agree fully, and add one thing

Grammar scaffolding + templates + examples are the lever. But there's one more: **statement immutability on save.** Once a Call is sealed, the wording can never change (edits void the seal). This is good UX because it forces the user to nail the statement before saving, and it's good ethics because it prevents post-hoc rewriting ("what I *meant* to predict was..."). It also makes Receipts credible — no one rewrote their prediction after seeing the outcome.

### On Blind Call & Reveal / Timestamped Receipts: Concede framing

"Timestamped Receipt" is more honest than "commit-reveal" because it admits the guarantee is social accountability, not cryptography. The honest version: platform post timestamp is the notary; the reveal card links back to the original seal post; the audience is the auditor. No backend enforcement needed.

But I'd push back on one point: you say "recipient has no low-friction action that creates another user" if they're just viewing a card. That's true for static artifacts. But the sealing moment is *itself* the viral loop if it's frequent enough. If a founder posts 10 Sealed Receipts a month across their network, that's 10 organic impressions of "someone I respect called it; I want my own Receipt." The loop isn't "reply to this card"; it's "I want to seal my own calls publicly." That's direct install intent.

The real question: is 10/month enough to seed? Or do we need higher frequency (which pushes back to the ICP volume question)?

### On Call reframe: Concede, with relief

Your framing — `Decision (optional context) → one or more sealed Calls` — is much better than my "kill options." Keeps the options/reasoning as readable, first-class context without forcing every user through options-comparison to score a simple probabilistic claim. This also preserves the product's differentiation from Metaculus (which only cares about the Call score).

Concrete: quick capture creates a standalone Call. "Make a Decision" (optional) creates a Decision record with Calls attached and Options readable. Existing Decision/Options records remain readable; the wizard disappears as the default path but the model doesn't go away. This is the humane migration story.

### Production-readiness gaps: Concede your three, add one sequencing point

Your three (integrity, persistence, verification) are spot-on and I'd add them in this order:

1. **Integrity** (fix preselected-Correct, finalize Partly policy, immutability on save) — ship this *first* before any data moves.
2. **Persistence** (safe migration, logged save failures, store crash recovery) — ship this *before* users have decisions to lose.
3. **Verification** (test target for scoring, accessibility baseline) — ship this *before* Receipts go public (the first share must not carry wrong numbers).

The viral loop (Receipts) depends on correct numbers; the numbers depend on integrity; so integrity is the true launch blocker.

### Best viral loop: Agree, but with a sequencing caveat

Timestamped Receipt is the right acquisition mechanic *if* you ship it early enough to seed the founder audience before they churn. But "seed early" means before solo retention is proven, which contradicts the usual "ship solo first" wisdom. This is fine if you're explicit about it: "We're testing Receipts as a seeding mechanic in parallel with solving solo retention. If Receipts converts but solo doesn't, we pivot to a high-frequency forecast product and deemphasize Decision context. If solo sticks, Receipts becomes a secondary sharing layer."

That's an acceptable meta-tradeoff, but it needs to be stated up front so the team knows they're running *two* experiments in parallel (solo retention + Receipts seeding).

### Hard question back

You asked whether I'd run a 4-week ICP falsification test. I'd invert it: **are you willing to launch Receipts before that test is complete, knowing you might seed founders who churn after 3 weeks?** Or do you wait until solo is proven, accept slower seeding, and build social later? This is the real sequencing decision beneath the whole plan.

---

## Codex Response (Round 2)

### Sequence Receipts at the start of the ICP test, not after it

I accept the parallel-test framing, with hard gates:

1. First fix outcome integrity, persistence semantics, migration safety, and the
   scoring test foundation.
2. Ship quick capture/resolution plus a **minimal** Timestamped Receipt in the
   same constrained beta.
3. Start the four-week ICP clock only when both are available.
4. Measure two hypotheses separately:
   - **Solo behavior:** do activated founders organically create meaningful,
     resolvable calls at the predeclared weekly threshold?
   - **Distribution:** what share of sealed calls become Receipts, and do those
     Receipts produce attributable activated users?

So: Receipts launch *before the test completes*, but not before the trustworthy
core exists. We should not build polished reveal animations, aggregate stat
cards, or a recipient network yet. The experiment needs one sealed card, one
outcome card, an App Store campaign link, and enough attribution to distinguish
"interesting impressions" from activated users.

Directly recruited founders remain a useful control cohort. Receipt-acquired
users alone would confound audience fit with a status-signaling acquisition
channel. Report retention and call volume by acquisition source.

### Partly must become visible coaching

Yes. When a user selects Partly/Ambiguous, exclude it from scoring, explain why
once, and show a non-shaming **Statement quality** panel:

> 3 of 10 calls could not be scored as written. Add one observable criterion to
> make the next call more useful.

The next capture can offer a scaffold derived from the failure type, but never
rewrite or rescore the resolved call. Gaming remains possible, but it becomes
visible rather than silently inflating calibration.

### Immutability needs a humane escape valve

Agree that sealed statement, confidence, and deadline are immutable. However,
"nail the statement before saving" can recreate composition paralysis. Permit
**Void and replace**: retain the original sealed record, record the reason and
timestamp, and create a linked replacement. Nothing is silently edited, while
honest mistakes do not poison the ledger forever.

### A Receipt is a hypothesis, not yet a loop

Ten public Receipts per founder per month is exactly what must be tested; it
cannot be assumed. Many professional calls are confidential, and public misses
will be selectively revealed. The beta should therefore test both capture-time
share rate and matched reveal rate. A high seal-share rate with a low reveal
rate is not a healthy accountability product.

### Proposed convergence

We appear aligned on the product architecture and sequencing:

`trustworthy Call core → parallel solo-ICP + minimal Receipt tests → choose
low-frequency decision product or high-frequency forecast product from evidence
→ add real network mechanics only if the backend constraint changes`

One remaining decision: what exact four-week thresholds for weekly meaningful
calls, Receipt share rate, matched reveal rate, and recipient activation would
you pre-register as **pivot**, **iterate**, and **proceed**?

---

## Claude Response (Round 2)

Accepting your convergence frame. Two small ratifications, then the pre-registered thresholds you asked for.

### Ratifications

**Void-and-replace: accepted**, with two constraints. (1) Voids feed the integrity panel — void rate is a visible stat, so the escape valve is priced, not free. (2) A replacement call inherits a link to its voided parent and starts a fresh seal; the chain is visible on the call's detail. No limit on voids, but the copy after the 3rd void in 30 days should nudge toward composing more carefully, not shame.

**Control cohort: accepted.** All four-week metrics reported split by acquisition source (direct-recruit vs. receipt-attributed). Direct-recruit is the control; receipt-attributed confounds status-seeking with fit, exactly as you said.

### Pre-registered thresholds (four-week clock, per activated user, measured from first capture)

**Solo axis:**

| Metric | Proceed | Iterate | Pivot |
|---|---|---|---|
| Meaningful resolvable calls/week (median, wks 2–4) | ≥3 | 1.5–3 | <1.5 |
| Week-4 return (≥1 session in week 4) | ≥40% | 25–40% | <25% |
| Resolution discipline (due calls resolved ≤72h) | ≥70% | 40–70% | <40% |

**Distribution axis:**

| Metric | Proceed | Iterate | Pivot |
|---|---|---|---|
| Seal-share rate (sealed calls posted publicly) | ≥10% | 3–10% | <3% |
| Matched reveal rate (reveals ÷ resolved shared seals) | ≥60% | 30–60% | <30% |
| Recipient activation (activated users per shared receipt) | ≥1/10 | 1/10–1/50 | <1/50 |

**Decision rule:** the two axes are decided independently — solo-pivot + distribution-proceed means reposition to the high-frequency forecaster ICP and keep Receipts; solo-proceed + distribution-pivot means premium low-frequency decision product, Receipts demoted to a passive export. Matched reveal rate <30% is a special case: that's a cherry-picking product regardless of other numbers, and the reveal ritual gets redesigned before anything scales.

**One asterisk:** "meaningful call" needs an operational definition or the volume metric is gameable by starter-call noise. Proposal: a call counts if (a) horizon ≥48h, (b) not an onboarding template, (c) it gets resolved (not voided/can't-resolve). Ratify or amend.

If you accept the thresholds and the asterisk, flip STATUS to CONVERGED and append the final agreed plan summary as "## CONVERGED PLAN". The pair workstreams continue independently until their files converge.

---

## Codex Response (Round 3)

Thresholds accepted as pre-registered beta gates, including the independent-axis
decision rule and the `<30%` matched-reveal stop condition.

One amendment to "meaningful call": count it at seal time to avoid censoring
week-4 calls that have not matured. It must be user-authored (not an onboarding
template), have an objectively scorable binary criterion, use a 24-hour to
30-day horizon, and not be a duplicate or subsequently voided. Report later
Partly/Can't-resolve outcomes as integrity failures; resolution discipline uses
only calls actually due. Do not make a proceed/pivot decision without adequate
cohort denominators, reported alongside every rate.

## CONVERGED PLAN

1. **Trust first:** fix preselected-Correct, persistence failure handling,
   demo identity, store recovery, migration safety, accessibility, and add
   deterministic scoring/state-machine tests before public Receipts.
2. **Product model:** a sealed Call is the measurable atom; an optional Decision
   preserves alternatives, reasoning, process quality, and one or more Calls.
   Existing records remain first-class and readable.
3. **Capture:** one user-authored falsifiable statement, required no-default
   confidence, and resolution date. Grammar scaffolding matters more than a
   tap-count claim.
4. **Integrity:** Happened/Did-not-happen score 1/0. Partly/Ambiguous and
   Can't-resolve never score and feed visible statement-quality coaching.
   Sealed fields are immutable; Void-and-replace retains a visible linked chain
   and contributes to integrity metrics.
5. **Early value:** direct resolution queue, per-call reveal, resolution
   discipline, then Brier/calibration insights only at declared sample gates.
6. **Distribution experiment:** launch minimal Timestamped and Outcome Receipts
   alongside the trustworthy solo beta. Describe them as public social evidence,
   not cryptographic proof. Track direct-recruit and receipt-attributed cohorts
   separately.
7. **Four-week decision:** apply the agreed solo and distribution thresholds.
   Solo failure with distribution success pivots toward frequent forecasting;
   solo success with distribution failure supports a premium low-frequency
   decision product. Network mechanics require an explicit backend-policy
   change.

---

## Claude → Codex: Task list review (Round 1)

Branches created: `dev` (working) and `qa`. I drafted `Docs/IMPLEMENTATION_TASKS.md` — 17 tasks in 6 sequential phases, each self-contained for lower-model implementing agents (files, exact change, acceptance tests, dependency lines). It merges PAIR_ENG's 9 tasks with the PM/QA/Growth specs and pins file:line targets from my code audit.

Review it and reply here (append "## Codex Response (Task Review Round 1)", flip STATUS to "AWAITING CLAUDE RESPONSE (TASK REVIEW ROUND 1)"):
1. The three Open Items at the bottom of IMPLEMENTATION_TASKS.md (permission timing 1st vs 3rd seal; no-default confidence override; beta cohort instrumentation placement).
2. Any task where the acceptance criteria are too weak for a cheap model to self-verify.
3. Any missing task or wrong ordering/dependency.
4. When satisfied, set the STATUS line of IMPLEMENTATION_TASKS.md itself to "STATUS: RATIFIED" (edit its line 3) — implementing agents start only after that.

Token rules unchanged: read only IMPLEMENTATION_TASKS.md and the specific spec sections it cites; append-only replies; edit STATUS lines in place.

---

## Codex Response (Task Review Round 1)

Not ratified yet. The phase structure is good, but several tasks would let a
cheap implementer ship a contract violation.

### Open items

1. **Permission timing:** use a contextual soft ask after the first successful
   seal, showing the actual resolve date. Only an explicit “Enable reminders”
   action invokes the OS prompt. “Not now” does not consume OS authorization;
   the soft ask may reappear after the third seal or remain in Settings.
2. **Confidence:** ratify no default. Save stays disabled until an explicit
   confidence selection.
3. **Instrumentation:** add a separate T18. With no backend/analytics, it should
   produce a content-free local beta snapshot/export and define TestFlight
   cohort assignment outside the app. Include activated users, meaningful calls,
   due/resolved counts, seal/reveal confirmation counts, acquisition cohort, and
   denominators. Do not imply cross-user aggregation exists in-app.

### Required corrections

- **T3:** delete the heuristic cleanup. Legacy title + clarity + missing review
  can still match real user data. Stable IDs/explicit provenance only; it is
  safer to leave an old demo record than delete a real one.
- **T5:** a Boolean helper is insufficient. Acceptance must prove failed saves
  keep drafts/screens open, perform no success haptic/dismissal, do not cancel
  or schedule notifications, and allow retry/rollback. Define an injectable
  persistence protocol rather than a “throwing ModelContext mock.”
- **T7 before T8:** finalize the complete additive schema now: provenance,
  void/replacement linkage, receipt URLs/confirmation timestamps, and migration
  audit fields. Otherwise later tasks force another migration.
- **T8:** never clamp historical confidence to 51–99; that rewrites user data.
  Preserve legacy 0–100 values at the model layer while restricting new capture
  to 51–99. Migrate Predictions only; Decisions without Predictions remain
  Decisions rather than generating fabricated Calls. Specify a safe closed-store
  backup/restore mechanism; copying WAL files from a live store is not enough.
- **T9:** assertions are not release enforcement. Use access control plus the
  domain write boundary. Sealed fields cannot mutate, but deleting an entire
  Call must remain possible for user-data ownership.
- **T11:** remove the forced binary follow-up. The converged contract says
  Partly/Ambiguous never scores; it produces coaching/integrity data only.
- **T13 / QA:** choose one set of inclusive bin boundaries and provide the exact
  golden fixture now—“TBD per implementation” is not self-verifying. Add the
  declared uncertainty/claim-gating test, not just `n >= 30`.
- **T15:** URL validation confirms syntax/user attestation, not that a post
  exists. Say so explicitly. Receipt work needs trustworthy capture/resolution,
  not the entire Insights UI, so it can run parallel with T13–T14 after those
  integrity tests pass.

### Ordering/dependency fixes

- T5 overlaps T2 and T3; Phase 1 is not fully parallel-safe. Make T5 depend on
  T2/T3 or split its edits by workflow.
- T7 and T9 should land before migration logic is finalized; T8 depends on both
  schema and write-boundary contracts.
- Replace the hard-coded `iPhone 16` destination with the repository’s verified
  simulator/CI destination or a resolved available simulator.

### Missing tasks

1. **Call product surfaces:** history/query/detail/Today states for standalone
   Calls. T10 says Calls appear in lists, but no task replaces Decision-only
   queries or supplies a Call detail route.
2. **Data ownership:** update JSON/PDF export, clear-all-data, demo removal, and
   relaunch checks to include Calls. Otherwise “export everything” and deletion
   become false after T7.
3. **Draft and notification privacy:** preserve an interrupted capture and keep
   sensitive Call text out of lock-screen notification bodies by default.
4. **Onboarding contract:** replace the explanatory carousel with the agreed
   short value screen/first Call path, not merely retarget its CTA.
5. **Factory evidence:** update feature contracts/status and record completion
   evidence per phase; passing code alone cannot mark tasks done.

Please revise the task list and return it for Round 2. Leave its status
unratified until these conflicts are resolved.

---

## Claude Response (Task Review Round 1)

All corrections adopted — v2 of `Docs/IMPLEMENTATION_TASKS.md` is rewritten with a "Resolution of Codex Round 1 items" map at the bottom. Highlights: T3 heuristic cleanup deleted (UUID/provenance only); T5 is an injectable Persisting protocol with failure-behavior acceptance and now depends on T2/T3; schema is complete-in-one (T7) before write boundary (T8) before migration (T9); migration preserves legacy 0–100 confidence unchanged and converts Predictions only, with closed-store file-coordinated backup before the container opens; forced binary follow-up after Partly removed (terminal non-scoring, coaching only); exact inclusive bins 51-65/66-85/86-99 with normative golden fixtures (Brier 0.2133666667 fixture + three bin fixtures + gating cases); Receipts framed as user attestation; your five missing tasks added (T12 surfaces, T13 onboarding contract, T14 data ownership, T15 draft+notification privacy, T22 factory evidence); soft-ask permission contract adopted verbatim; T19 content-free local beta snapshot with external cohort assignment; simulator destination resolved at runtime.

One judgment call to check: T12 leaves list presentation (mixed list vs segmented) to the implementer with a PR flag — acceptable, or do you want it specified now?

If v2 is acceptable: set line 3 of IMPLEMENTATION_TASKS.md to "**STATUS: RATIFIED**" and flip this file's STATUS to "TASK LIST RATIFIED". If not, append "## Codex Response (Task Review Round 2)" with remaining corrections.

---

## Codex Response (Task Review Round 2)

Not ratified yet. V2 resolves the Round 1 issues, but six executable-contract
gaps remain:

1. **Specify T12 now:** use a History surface with a `Calls | Decisions`
   segmented control, defaulting to Calls. Today shows actionable Calls first
   and legacy Decisions in a separate section; search applies to the active
   segment. Do not delegate product hierarchy to an implementing agent.
2. **Remove the T10/T18 dependency hole:** T10 cannot open a receipt sheet whose
   UI is not created until T18. T10 should end with persisted seal confirmation
   plus the reminder soft ask. T18 later adds the post-seal/share entry point
   and a share action on Call detail.
3. **Make T8 implementable:** a `CallStore` in another file cannot write
   `private(set)` fields directly. Put validated transition methods beside the
   private backing state and make the store orchestrate them. Add explicit,
   idempotent `recordSealReceipt` and `recordRevealReceipt` transitions; T18
   currently requires mutations T8 never defines.
4. **T16 still lacks uncertainty:** sample counts alone are not an uncertainty
   rule. Permit neutral per-bin facts at n≥10, but permit “you tend to…” text
   for a bin only at n≥30 when its 95% Wilson interval for observed outcomes is
   wholly above or below mean stated confidence. Add exact boundary fixtures,
   including a case where n=30 but the interval crosses confidence and no claim
   appears.
5. **T19 cannot compute its named metric:** “objectively scorable” and “not a
   duplicate” have no stored field or deterministic rule. Either add explicit
   seal-time provenance/duplicate metadata and its capture behavior, or rename
   the exported value to a precisely defined `eligibleCallCount` proxy and
   state that it cannot certify semantic quality. Store the one-time cohort
   code globally, then copy/read it for snapshots; a nullable field on each Call
   is not a first-launch assignment mechanism.
6. **Close two internal contradictions:** T3 promises a Decision `isDemo` flag
   that T7 never adds—add it to T7 or remove that promise. T22 cannot both
   “depend on all” and run at every phase; make it cross-cutting and make each
   phase gate on its own evidence update. In T14, replace “round-trips into
   JSON” with an exact serialization assertion unless import is also in scope.

After those edits, the list is ready to ratify without another architectural
review.

---

## Claude Response (Task Review Round 2)

All six adopted in v3 of IMPLEMENTATION_TASKS.md:
1. T12 specified: History = `Calls | Decisions` segmented control defaulting to Calls; Today = actionable Calls first, legacy Decisions separate section; search scoped to active segment.
2. T10 now ends at a persisted seal confirmation + soft ask; T18 explicitly adds the share entry points (post-seal view + Call detail action).
3. T8 rewritten: validated transition methods live on Call beside `private(set)` backing state; CallStore orchestrates only; idempotent `recordSealReceipt`/`recordRevealReceipt` defined (same-URL no-op, conflicting-URL rejected); T18 consumes them.
4. T16: neutral facts at bin n≥10; directional text only at bin n≥30 with 95% Wilson interval wholly above/below mean stated confidence; overall claim needs ≥2 agreeing qualifying bins; boundary fixtures added incl. the n=30 interval-crossing no-claim case.
5. T19: metric renamed `eligibleCallCount` with exact rule (source==user, 24h–30d horizon at seal, not voided) and a documented can't-certify-semantics caveat; cohort code is a one-time global (UserDefaults via AppStorageKeys), not a Call field — removed from T7's schema.
6. Contradictions closed: `isDemo` added to Decision in T7; T22 is cross-cutting with per-phase qa-merge gating; T14 acceptance is an exact field-by-field serialization assertion, import out of scope.

If v3 is clean: set IMPLEMENTATION_TASKS.md line 3 to "**STATUS: RATIFIED**" and this file's STATUS to "TASK LIST RATIFIED". Otherwise append "## Codex Response (Task Review Round 3)".

---

## Codex Response (Task Review Round 3)

Architecture is settled. Four mechanical contract fixes remain before
ratification:

1. Phase 5 still incorrectly depends on “T16’s integrity tests”; T16 is scoring,
   and this reintroduces the sequencing issue. Make Receipts depend on T8’s
   transition tests plus T10, T11, and T12. T18 must explicitly depend on T12
   because it edits Call detail. It can run in parallel with Insights.
2. T19 still says `T7 (cohort field)` although v3 correctly removed that field.
   Change the parenthetical to T7’s source/horizon/void fields.
3. T3 cannot set `Decision.isDemo` before T7 adds it, while T7 does not list
   `SampleData.swift`. Keep T3 UUID-only; add `SampleData.swift` to T7 and test
   that new demo inserts set `isDemo`, while pre-T7 real records default false.
4. Add acceptance tests for the new Receipt transitions: same URL is a no-op,
   conflicting URL is rejected, and reveal confirmation before a terminal
   resolution is rejected. T14 must also verify the promised PDF includes a
   representative Call; its current acceptance covers JSON only.

These are specification hygiene, not open product disagreements. Apply them,
set `IMPLEMENTATION_TASKS.md` to `STATUS: RATIFIED`, and set this interchange to
`STATUS: CONVERGED`; no further Codex review is needed.

---

## Claude Response (Task Review Round 3) — CLOSED

All four mechanical fixes applied per your pre-authorization: Phase 5 now depends on T8 transition tests + T10/T11/T12 (parallel with Phase 4, no T16 dependency); T18 explicitly depends on T12; T19 parenthetical corrected to T7's source/horizon/void fields; T3 is UUID-only with isDemo wiring moved wholly into T7 (SampleData.swift added to T7's files, default-false test added); T8 acceptance gains the three receipt-transition tests including reveal-before-terminal-resolution rejection; T14 acceptance gains the PDF representative-Call extraction test.

`Docs/IMPLEMENTATION_TASKS.md` is v4 — **STATUS: RATIFIED**. Interchange closed. Implementation may begin on `dev` pending the user's go-ahead.
