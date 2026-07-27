# Message to Claude — Hindsight Product Review

Hi Claude. Codex has completed a code/product audit and drafted a new product
direction. Please act as an independent product and UX critic, not an
implementation agent.

## Token-efficient context

Do not scan the repository or reread its documentation for this task. Treat the
facts below as authoritative. Do not edit files.

Hindsight is a local-only SwiftUI/SwiftData iOS app that lets users record a
decision, predictions and confidence, then review the outcome later. It builds,
but the current experience requires a four-step wizard:

`Basics → at least 2 Options → at least 1 Prediction → Review Date → Save`

Outcome review is also long. Insights currently show generic totals and make
strong pattern claims from as few as 2–3 records. There is no test target.
Current repository constraints prohibit a backend and third-party dependencies.
Pending predictions are currently preselected as Correct during review, and the
existing "hit rate" is not a valid probabilistic calibration measure.

The proposed direction is:

- Reframe the core object as a **Call**: one falsifiable statement, confidence,
  and resolution date.
- Make capture one sheet and under 10 seconds after typing; everything else is
  optional enrichment.
- Make resolution Yes / Partly / No / Can't resolve, with optional reflection.
- Center Insights on confidence calibration: e.g. "At 80–89% confidence, the
  outcome happened 46% of the time (6/13), 37 points below expectation."
- Require sample-aware copy and drill-through.
- Use privacy-safe social **Receipts** generated locally: share a sealed call,
  then later share its outcome. The strongest later network loop is **Blind Call
  & Reveal**: a friend answers independently before either response is revealed.
  Defer groups/feed mechanics until solo retention is proven.
- Position initially for frequent high-agency decision makers such as founders,
  operators, investors, and product leaders.

The detailed proposal is in `Docs/PRODUCT_PLAN.md`, but you should not need to
read it unless one of the above points is ambiguous.

## Your task

Challenge the proposal. Respond compactly in chat with:

1. The three strongest ideas.
2. The three biggest product risks or wrong assumptions.
3. Your recommended minimum capture contract.
4. The single best social/viral loop and why users would share.
5. The five most valuable Insights, including sample thresholds.
6. A ruthless MVP cut: build now / later / never.
7. One positioning statement and three possible product names/nouns.
8. Up to five questions whose answers would materially change the plan.

Be specific and disagree where warranted. Optimize for product truth, retention,
and trust rather than feature count. Keep the response under 1,200 words.
