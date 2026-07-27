# Independent Critique: Hindsight Product Proposal

**Reviewed:** 2026-07-27  
**Context:** Six-agent panel (retention, trust/measurement, UX, artifact-virality, peer-to-peer networks, status/identity)  
**Scope:** The proposed Call reframe + one-sheet capture + calibration centerpiece + Receipts social loop

---

## 1. Three Strongest Ideas

### (1) The Call Reframe
Not because it's simpler, but because every Call carries a resolution date: a pre-committed future appointment with the app. Journaling apps die because they must invent reasons to return; a Call ledger has re-engagement built into the core object. The resolution moment is a genuine variable reward ("was past-me right?"), and variable reward is the only reward type that survives week 4. This also structurally kills the preselected-"Correct" fabrication bug rather than patching it — a verdict requires an explicit human choice.

### (2) Calibration as Honest Centerpiece, Sample-Aware Copy
The current hit-rate metric is invalid (averages correctness, ignores stated confidence). The n=3 pattern claims ("you tend to be overconfident") are worse — statistically indefensible and reputationally toxic if wrong. Making the app's core promise "a mirror that doesn't flatter you" is the right identity for this audience (founders, operators, forecasting-minded). But it requires brutal sample gating: no pattern claims below n=30+ resolved calls; show raw counts and "not enough data yet" until thresholds are met.

### (3) Deferring Groups/Feeds Until Solo Retention is Proven
Rare discipline. Most proposals reach for social to paper over a broken solo loop. This one says "ship an honest, working solo product first; network effects are a tax you pay once solo sticks." That's right.

---

## 2. Three Biggest Risks / Wrong Assumptions

### (1) The Founder/Operator Positioning is Retention Poison as Stated
That persona's meaningful calls resolve in months: "this hire works out," "the raise closes," "this market bet pays off." Long horizons are the single worst property a call can have in this product, because the resolution date is the app's *only* organic return trigger. A book full of Q4 resolutions means zero sessions in August and September. A November notification lands on a phone that deleted the app in September.

**The proposal optimizes day 0 (capture) and day N (resolution) and is silent about days 3–21, which is exactly where every journaling/tracking app dies.**

Evidence: the retention agent's sharpest disagreement says users who would actually retain are people who *enjoy being scored on frequent short-horizon claims* — forecasting-community types, sports and fantasy players, markets-obsessed analysts — who generate 5–10 resolutions a week and hit n≥15-per-bucket insight thresholds in a month instead of a year. The founder positioning maximizes the dead time.

**Mitigation:** Either (a) coach a short-horizon mix aggressively (onboarding forces 2–3 starter calls resolving within 48h so the loop closes in week one; nudge a <7-day call whenever nothing is due within 7 days), or (b) admit the truer ICP and reposition.

### (2) "Partly" as a Scored Outcome is the Preselected-"Correct" Bug Reborn
Self-graded partial credit is exercised asymmetrically: confident misses migrate to "Partly," wins never do. A user whose true record at 90% mean confidence is 6/12 (40-point gap, screaming signal) reclassifies four misses as half-credit and their measured hit rate becomes 67%; the gap reads 23 points. Nearly half the miscalibration — the exact thing this product exists to reveal — vanishes into a euphemism.

No partial-credit scheme survives self-grading. Metaculus-style fractions work only because a neutral party assigns the fraction.

**The fix costs nothing in UX:** keep the "Partly" button, but it never scores. Tapping it asks one forced follow-up: "As written, did it happen?" — and *that* binary answer enters the math. The Partly rate itself becomes a statement-quality diagnostic: "3 of your last 10 calls only partly resolved — tighter statements make a better mirror." Partly becomes a tool for better question-writing, not a solvent for inconvenient results.

If the team ships Partly-in-the-math, every downstream number inherits an optimistic bias of unknown size, and the honest answer to "is this calibration measure valid?" becomes no.

### (3) The Calibration Payoff Arrives After Users Have Already Churned
Bucketed calibration ("at 80–89% confidence, outcomes happened X% of the time") needs ~15 resolved calls *per bucket*. For a founder logging 2–3 calls a week with mixed horizons, that's 2–4 months. The proposal's flagship insight is a month-12 screenshot being sold as a month-1 experience.

Sample-aware copy makes the app honest but also makes early insight screens say "not enough data yet" — which reads like churn copy. An unattended user at day 20 seeing "resolve 5 more 80%+ calls before we can tell if you're overconfident" is an uninstall copy.

**Mitigation:** Ship interim rewards that are honest at small n:
- Per-call reveal (n=1, theatrical)
- Cumulative Brier score (n≥10)
- Resolution discipline stat (n≥5)
- Save bucketed calibration for when it's real (n≥100)

---

## 3. Minimum Capture Contract

**Entry:** Persistent "+" reachable from every screen (1 tap); sheet presents half-height with keyboard already up and cursor in statement field.

**Exactly three fields:**

1. **statement** — required, free text, one sentence (no newlines). Placeholder teaches grammar: "X will happen by [date]". No title/statement split — statement IS the title everywhere.

2. **confidence** — required, **NO DEFAULT**. Five chips in the keyboard accessory row: 55% / 65% / 75% / 85% / 95% (bin midpoints, no false precision). Save button stays disabled until one is tapped. Range 51–99: values ≤50% offer to flip the statement; 100% disallowed.

3. **resolveBy** — required, chips (2d / 1w / 1m / custom), DEFAULT = +30d preselected. Tapping "custom" opens a compact calendar (wheel picker never appears).

**Tap budget:** Typing + 3 taps (open, confidence, save). Worst common path (custom date) = 6. Anything above 6 is a regression.

**Sealed on save:** statement, confidence, date become immutable; any edit voids the seal (this is what makes future Receipts non-fabricatable).

**Enrichment (post-save only):** why/rationale, tags, stakes. One passive affordance on the save toast link ("Add why?") or a quiet "Add context" row post-save. Zero modals, zero "complete your call" badges.

**On first save:** Contextually request notification permission with the actual resolve date in the copy ("We'll remind you Aug 26"). Denied-permission users are dead users; prompt placement matters more than any other screen.

**Resolution flow:** Notification deep-links into a card stack. Card shows statement + stated confidence. Four buttons: Yes / No / Partly / Can't resolve, visually equal-weight for the first three; "Can't resolve" is honest but secondary. **Nothing preselected, ever.** One tap commits outcome; auto-advances to next due card. Optional "What did you learn?" is reachable via small link before advancing, never blocks, and MUST resurface later (at capture time on tag match) — a captured field that never returns is friction theater.

---

## 4. Best Social/Viral Loop

**The Sealed Receipt commit-reveal pair.**

**Mechanic:**
1. At capture save, render a dark, premium "SEALED" card: statement in large type, giant confidence number, resolution date as countdown band, seal motif, short content hash. One tap posts it to X/LinkedIn. **The platform's post timestamp is the notary** — X/LinkedIn is the free trusted timestamp server.
2. On resolution day, app notifies; user taps Yes/No/Partly, app renders the matching REVEAL card: original sealed card ghosted in background with diagonal rubber-stamp verdict (RIGHT / PARTLY / WRONG), "Sealed Mar 3 → Resolved Jul 21," plus one-line track record footer ("Career: 61% right at avg 74% stated, n=38").

**Why people share:**
- It productizes behavior the target ICP already performs: "calling it now" + screenshot-this. Seal = status-staking and courage signaling.
- Reveal = vindication (highest-status post a predictor can make) *or* graceful public humility ("I was 90% sure and wrong — updating"), which in rationalist/operator circles is also high status.
- Sealing creates a public obligation to return and resolve — you *will* come back because the reveal awaits.

**Constraint fit:**
- Fully local: card rendered on-device via ImageRenderer; hash is SHA-256 of canonical call string computed locally.
- Social platform (X, LinkedIn) provides timestamping, storage, and distribution.
- No accounts, no network code, privacy promise intact.

**Honest caveats:**
- Expect single-digit share rates, not virality; misses must be a designed, dignified ritual (lessons on the card) or only winners get revealed.
- Cherry-picking cannot be eliminated, only priced ("reveals are voluntary; the gaps speak for themselves").
- An image with no backend landing surface historically converts poorly; each share is a rare, high-value ad.

---

## 5. Five Most Valuable Insights

| Insight | Minimum Sample | Why |
|---|---|---|
| **Per-call reveal** (outcome vs. stated confidence, original statement + why-note + prior lesson resurfaced) | n=1 | This IS the product's actual retention reward. Make it theatrical. Fixes the buried mainLesson problem. |
| **Cumulative Brier score with trend** | Show at n≥10; trend at n≥20 | Single honest scalar that improves with practice; works before bucketed calibration is legitimate. |
| **3-bin calibration bars** (Leans 51–65 / Confident 66–85 / Sure 86–99) with locked bins showing progress | n≥10 per bin | Coarse, intuitive; shows depth before signal. Unpopulated bins greyed with "resolve N more to unlock." |
| **Directional claim** ("you tend to be overconfident") | n≥30 resolved + consistent-direction gap in ≥2 buckets; 95% CI excluding zero | Hardest gate in the app. Detecting a typical 10–15 point gap actually needs n=60–70. |
| **Integrity panel** (% resolved on-time, Can't-resolve rate, Partly rate) | n≥5–10 | Keeps the dataset honest. Flags when Can't-resolve correlates with stated confidence (bias signal). |

**Never ship:** Full decile curve below n≥100 (year-2 feature); pattern copy below sample thresholds; "hit rate" or any invalid metric.

---

## 6. Ruthless MVP Cut

### Build Now (Launch Blocker)
- Kill the preselected-"Correct" bug **today, independently** — not waiting for the redesign.
- One-sheet Call capture (3 fields, 3-tap default path, no-default confidence, seal on save).
- Resolve card stack with deep-link notification; nothing preselected ever.
- Contextual notification-permission ask at first save.
- Per-call reveal moment + Brier score + sample-gated record view.
- Onboarding that forces 2–3 starter calls resolving within 48–72h so the loop closes in week one.
- Resurrect the `mainLesson` field at verdict time (captured today, shown nowhere — free value).
- Migration: old Predictions → Calls; Decision + Options → read-only context note. **No user data deleted.**
- **Test target covering Brier math, bin gating, resolution state machine.** The app has already shipped one wrong statistic and one fabrication bug; this one stakes everything on arithmetic. Launch blocker.

### Build Later
- Receipts as locally rendered share images (seal-first mechanics).
- Lock Screen widget + App Intent (drops entry to 0 taps).
- Tags + lesson resurfacing at capture time.
- Statement scaffolds v2 (enforced grammar with date slot = resolveBy).
- Optional stakes field for weighting.
- Full decile curve (n≥100).
- Quarterly Wrapped (identity ritual).
- Blind Call & Reveal (only when backend constraint lifts or honor system is explicitly labeled).

### Never Ship
- The 4-step wizard as a capture path; any mandatory multi-step capture.
- Options/tradeoffs comparison UI (that job belongs to other tools; this app's unique job is the calibration ledger).
- Any preselected confidence value or 0–100 slider defaulting.
- Partly or Can't-resolve in calibration math (unless "Partly-never-scores" rule above is followed).
- Pattern-claim copy below sample thresholds.
- Daily-open streaks (event-driven product; a daily streak breaks through no fault of the user and converts guilt into uninstalls).
- Server-side social, accounts, or any network code while "100% on-device" stands.

---

## 7. Positioning Statement + Names

**Positioning:** *"The scoreboard for your own judgment. Make a call, seal it, and find out whether you can trust yourself."*

**Nouns/Names:**
- **Hindsight** (keep — powerful brand for the reveal moment)
- **Called It** (culture-fit for the ICP, but secondary)
- **Track Record** (descriptive, less evocative)

---

## 8. Critical Questions for Codex

1. **Is this a decision journal or a prediction scoreboard?** The Call pivot quietly abandons options/tradeoffs comparison. Probably right — but choose it, don't drift into it. What's lost?

2. **What's the evidence on call volume** for the true ICP (whoever they are)? Every retention threshold divides by weekly-volume. Founders at 2–5 calls/month never reach n=30; forecasters at 10+/week do.

3. **Will you commit to "Partly never scores"?** If not, what's the rule, and will it be shown in-app *before* users resolve?

4. **Is no-backend permanent or a v1 constraint?** Determines whether shared ledgers, Blind Duels, and live leaderboards ever exist.

5. **What does the migration owe existing captured decisions?** "No user data deleted" needs to be a written contract before the model changes ship.

---

## Open Disagreement: The Real ICP

The proposal's sharpest tension is between the stated positioning (founders/operators) and the retention mechanics (short-horizon calls on a resolution-date trigger). These audiences have nearly opposite properties:

- **Founders/operators:** high-agency, high-attention-scarcity, quarterly-horizon goals, already half-do this in Notion. Long dead time between capture and resolution. **But:** they're influential, they have networks, they *love* credibility scores and calibration narratives. They're the seeding audience for Receipts virality.

- **Forecasting-adjacent:** enjoy frequent calibration checks, comfortable with small-stakes predictions, generate 5–10 calls/week, hit insight thresholds in weeks. **But:** lower network reach, niche audience, already have Metaculus/Hypermind.

**The answer might be:** seed with founders (Receipts culture on X/LinkedIn is the moat), but coach them aggressively toward short-horizon calls and weekly nudges so they don't churn in the dead time. The two audiences aren't incompatible if onboarding and mid-life touches are brutal about it.

---

## Summary Disagreements with Codex (if any)

1. **Partly:** I say never-scores, forced binary follow-up. You should defend or concede.
2. **Dead time:** I say it's real and the ICP matters. You should assess whether 48h starter calls fix it or whether the pitch needs to shift.
3. **Composition friction:** I say "10 seconds after typing" is misleading. You should push back or agree.
4. **Blind Call & Reveal:** I say it's unbuildable without backend, platform-timestamped commit-reveal is better. You should defend or pivot.

---
