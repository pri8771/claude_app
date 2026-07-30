# Hindsight: Long-Term Plan

> **Direction update — 2026-07-30:** Path B (networked social product) is now accepted. The
> detailed, implementation-ready replacement roadmap is
> `SOCIAL_PRODUCT_V2_IMPLEMENTATION_PLAN.md`. This document remains useful strategy/history; its
> local-vs-social fork is no longer an open decision.

**Status:** Strategy document — opinionated, with open questions named as open.
**Date:** 2026-07-28

---

## 1. What this product actually is

Four different products are currently tangled together in the codebase:

| Framing | Embodied by | Promise |
|---|---|---|
| **Memory device** | the name, the review notification | You cannot remember what you actually believed |
| **Calibration trainer** | Brier score, bins, confidence | You get better at judging probability |
| **Decision-quality tool** | the 4-step wizard, clarity score | Structure makes you decide better |
| **Social prediction game** | duels, shared receipts | Being right in public is status |

They cannot all be the spine. My read:

> **The memory device is the emotional hook. Calibration is the mechanic that delivers it.
> The wizard is a mode, not the front door. Social is distribution.**

The defensible insight is hindsight bias: **you genuinely cannot recall what you believed before
you knew the answer.** It is universal, invisible, and quietly corrosive — people relitigate their
own past as though they always knew. Everyone else in this space is either forecasting-nerd
tooling (Metaculus, Manifold) or generic journaling. *Consumer receipts on your own mind* is open
territory.

The cultural version, and the reason this could be big rather than nice: in a world of confident
takes, **the person with actual receipts has status.** That is what the Timestamped Receipt work
was reaching for.

---

## 2. The moat is time — and everything follows from that

Hindsight has no technical moat. The Brier maths is textbook, the UI is copyable, and there is no
network effect in the solo product.

The moat is **accumulated personal history.** A user with two years of resolved predictions cannot
switch — the data is irreplaceable and the value compounds. A user at week one has nothing
invested and churns for free.

Three consequences, and they should govern the roadmap:

1. **Early retention is not a metric, it is the entire strategy.** Every month a user survives
   makes them permanently harder to lose.
2. **Time-to-first-payoff is the single most important number in the product.** This is why
   short-horizon predictions matter far more than they look.
3. **Never make history hard to leave with.** Counterintuitively, strong export makes the moat
   *more* credible — it proves the lock-in is value, not hostage-taking.

---

## 3. The horizons

### Horizon 1 (0–3 months) — Prove the loop closes

Quick capture, voice, short horizons, fast resolve ritual.

**Question:** does anyone actually close the loop?
**Metric:** share of users who resolve ≥1 prediction within 14 days.
**Kill criterion:** if people capture happily and never resolve, the product does not work, and no
amount of social or gamification fixes it. Better to learn this in month two than month twenty.

### Horizon 2 (3–9 months) — Habit, and find the real user

Hands-free capture (Siri, widget, Control Centre, Action Button). The insight engine becomes real
once H1 has produced volume. Resolution streaks. Year in Review.

**Question:** who is this actually for?
**Metric:** week-4 retention, predictions per active user per week.

This is where the ICP question gets settled with data instead of argument (see §5).

### Horizon 3 (9–18 months) — Distribution

Duels, shared receipts, second opinions, anonymous benchmarks. This is where the privacy posture
changes — deliberately, not by drift.

**Question:** does it spread?
**Metric:** invite rate; share of new users arriving from a duel or a shared receipt.

### Horizon 4 (18+ months) — Compounding

Year-over-year insight ("your 2027 self vs your 2026 self"), domain-level calibration, anonymous
population benchmarks. These are only possible with accumulated data, and they are exactly what a
competitor cannot copy on day one.

---

## 4. The fork that shapes everything

At Horizon 3 the product splits, and the two paths are hard to walk simultaneously.

**Path A — Local-only, forever.**
No backend, no accounts, no server costs. Marginal cost per user is approximately zero, which
makes a **one-time purchase** genuinely sustainable — rare and increasingly attractive to users.
Privacy is a real, honest differentiator. Growth is word-of-mouth only. Realistic outcome: a
profitable, durable indie app serving tens of thousands of people who love it.

**Path B — Social, at scale.**
Duels require a rendezvous server; that means infrastructure, accounts, and recurring costs, which
in turn require **subscription revenue**, which requires scale. The privacy promise weakens from
"nothing leaves" to "nothing leaves unless you send it." Growth becomes viral. Realistic outcome:
a much larger business, with meaningfully more operational and trust risk.

**This is a values-and-ambition decision, not a technical one, and it should be made
consciously.** The failure mode is drifting into Path B one feature at a time and discovering the
privacy promise died somewhere along the way without anyone deciding it should.

**A middle path exists and is worth taking seriously:** keep the journal strictly local, and let
*only explicitly-shared items* touch a server. A tiny duel-scoped store, nothing else syncing.
"Your journal stays on your device; only duels you start leave it" is defensible, honest, and
preserves most of the differentiation while unlocking the growth mechanism.

---

## 5. Who is this for — the unresolved question

Three candidate users have been in play, and they want different products:

| ICP | Volume | Willingness to pay | Virality | Fit |
|---|---|---|---|---|
| **College students** | High, casual | Low | **High** | The voice/AirPods scenario, duels |
| **Founders / operators** | Low, weighty | **High** | Low | The wizard, status receipts |
| **Forecasting enthusiasts** | **High, serious** | Medium | Low | Brier, bins, calibration depth |

The app currently has features for all three and focus for none.

**My recommendation: students are the acquisition wedge; operators are the retained user.**
People arrive young and casual, and the ones who stick become serious about it over years — the
Strava pattern. That story is coherent, it explains why both the fast path and the deep path exist,
and it means the MVP should optimise for *fast and fun* without deleting the depth.

Settle it with H2 data, not another debate.

---

## 6. What kills this

- **Nobody closes the loop.** The H1 risk, and the reason H1 exists.
- **Confronting being wrong is unpleasant.** This is the deepest product risk. Duolingo works
  because being wrong is trivial; here being wrong is *identity-threatening*. The core action is
  mildly painful, which argues hard for low-stakes short-horizon practice, gentle copy, and
  rewarding honesty rather than accuracy.
- **Vitamin, not painkiller.** Nobody is in acute pain from bad calibration. Products in this
  category die of indifference, not of competition.
- **Apple ships it.** Journal already nudges reflection. A calibration feature there would hurt.
  The defence is depth and accumulated history, not features.
- **Privacy drift.** Losing the differentiator by accident while chasing growth.

---

## 7. Decide now vs. defer

**Decide now (they shape the MVP):**
- Is the spine the memory device? *(I believe yes.)*
- Are quick captures visibly distinct from wizard decisions, or the same object captured faster?
- Does the MVP include Siri, or is Siri the immediate follow-on?

**Defer until H2 data exists:**
- The ICP.
- Path A vs Path B — but revisit deliberately, on a date, not when a feature forces it.
- Monetisation. Note that Path A supports a one-time purchase and Path B effectively requires a
  subscription, so this decision is downstream of the fork.

**Never revisit:**
- Fabricating a confidence value the user did not give.
- Rewarding accuracy over honesty.
- Sending journal content off-device without an explicit, per-item user action.
