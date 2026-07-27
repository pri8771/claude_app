# Pair Task: Timestamped Receipt loop spec

TURN: CONVERGED
ROUND-CAP: 3 per side, then converge.

## Protocol (both workers)
- Read ONLY this file. Do not scan the repo. The brief below is your full context.
- Append your section ("## Claude Worker (Round N)" or "## Codex Worker (Round N)") at the END. Max 400 words per round.
- Flip the TURN by EDITING line 3 in place. NEVER insert a new TURN line anywhere else. No other edits to prior text.
- Round 1 = draft. Round 2 = critique + revise. Round 3 = final. Then write "## CONVERGED SPEC" and set TURN: CONVERGED.

## Shared context (agreed by both orchestrators)
Hindsight: local-only iOS app (SwiftUI/SwiftData, no backend, no accounts, no third-party deps). Pivoting from a heavy 4-step decision wizard to: core object = a "Call" (one falsifiable statement + confidence 51-99% no-default + resolve-by date), sealed immutable on save, capture = one sheet / typing + 3 taps. Decisions remain optional containers around Calls (not deleted). Resolution: Yes / No / Partly (never scored; statement-quality diagnostic) / Can't-resolve (excluded, tracked). Insights: per-call reveal (n=1), Brier score (n>=10), 3-bin calibration (n>=10/bin), directional claims (n>=30). Social: "Timestamped Receipt" — sealed card posted to X/LinkedIn at capture (platform timestamp = notary), reveal card quote-posts it; honest framing = social accountability, not cryptography. ICP tension: founders/operators (high status, low call volume) vs forecasting types (high volume). Known launch blockers: preselected-"Correct" verdict bug, demo-data title-matching deletion bug, fatalError on store-open, no test target, no accessibility.

## Task brief
Produce the full spec for the Receipt loop: card contents (seal + reveal), exact share flow (taps), how reveal links the seal post, miss-card copy that makes being wrong postable, cherry-picking mitigations, and the 3 metrics that decide if the loop works (with target numbers). Deliverable = implementable spec.

## Claude Worker (Round 1)

**SEAL CARD (at capture):**
- Title: The Call statement (e.g., "Q3 revenue will exceed $2M")
- Confidence: "I'm _[51-99]%_ confident"
- Resolve-by date: Plain text (e.g., "Oct 31, 2024")
- Visual: Lock icon, pastel background (confidence-tinted: cool for lower, warm for higher)
- Posted to: X or LinkedIn. Platform timestamp is the seal notary. No edit, no deletion. Permalink is canonical.
- CTA: None on seal card. It's read-only.

**REVEAL CARD (at resolution):**
- Seal quote-post (embedded or linked)
- Resolution outcome: One of [Yes ✓ | No ✗ | Partly ◐ | Can't-resolve ◈]
- User's brief take: 1–2 sentences explaining *why* (not score; diagnostic)
- Brier/calibration metrics (if eligible): "Your Brier: 0.18" or "You're overconfident in 70–90% range"
- Posted as quote-post to the seal permalink
- Reveal is immutable once posted

**MISS CARD / CHERRY-PICK MITIGATION:**
- If resolved "No," reveal card includes co-branded "Share what you learned" CTA
- Tapping opens sheet with prompt: "What was the biggest miss? (optional, max 140 chars)"
- Miss comment posts as reply to reveal quote-post (not seal)
- Framing: "Got it wrong? That's the data. Post it." — normalizes losses.

**SHARE FLOW (taps):**
1. At capture: Auto-open share sheet → Select X or LinkedIn → Confirm seal post
2. At resolution: Tap [Yes/No/Partly/Can't-resolve] → Tap [Add context] → Type or skip → Tap [Quote-post] → Share sheet → Confirm reveal post

**SUCCESS METRICS (3):**
1. **Adoption:** 15% of new Calls posted to X/LinkedIn within 7 days of capture
2. **Reveal rate:** 60% of sealed Calls receive reveal post within 30 days of resolve-by date
3. **Honest framing:** 70% of miss-card replies posted for "No" resolutions within 48 hours of reveal

Each metric signals loop is in workflow, users resolve calls, and losses drive learning not shame.

## Codex Worker (Round 1)

**Product boundary.** A Receipt is an app-rendered, shareable image plus accompanying text; the network’s public post timestamp and returned permalink are the only external proof. The app must never claim tamper-proof, permanent, or guaranteed posting. Saving a Call seals its local fields; sharing is explicitly optional and never automatic.

**Seal card.** Header: `HINDSIGHT — TIMESTAMPED RECEIPT` and `SEALED`. Show the exact Call statement in quotation marks, `Confidence: 72%`, and `Resolve by: 31 Oct 2026`. Footer: `Sealed in Hindsight • Public timestamp is the receipt` plus a compact Call ID. No outcome, score, or follow prompt. Caption: `I’m making this call publicly: [statement]. I’ll report back by [date].`

**Capture flow (three taps after save).** 1) Save & Seal Call. 2) Tap `Share receipt` on confirmation (or later from Call detail). 3) choose X/LinkedIn in the system share sheet and publish. On return, show `Add post link` (paste/open callback if available), then `Save link` or `Not now`; retain platform, URL, and shared-at time only after user confirmation. A shared receipt badge requires a URL.

**Reveal flow.** On resolution, select verdict, optionally add a max-280-character `What changed / what I learned?`, then tap `Share reveal`. The generated card repeats the sealed statement/confidence/date, shows `Result: Yes | No | Partly | Can’t resolve`, and links visually as `Original receipt: [URL]`. Caption begins `Update to my receipt: [result].` The share sheet pre-fills the original URL so the user can quote-post/repost manually; LinkedIn uses a normal post containing that URL. After publishing, the user saves the reveal URL. “Linked” badge is only shown when both URLs exist.

**Postable miss.** For No: `Missed it — 72% confident, and the result was No. What I missed: [context]. The lesson is the point.` For Partly: `Partly right, partly wrong. Here’s what the original call missed: [context].` Context is optional; never pressure users to disclose sensitive details.

**Cherry-picking guardrails.** Dashboard separates all sealed calls from shared calls; shows share and reveal rates by outcome, including unshared/overdue. Default insights include every resolved Call, never only posted receipts. Receipt history records absence of a reveal and late reveals; allow deletion of a social URL locally but label it `link removed`, not `unshared`.

**Decision metrics (30-day cohort).** (1) Receipt attach rate: ≥20% of sealed Calls get a confirmed seal URL. (2) Linked reveal completion: ≥50% of URL-sealed, due Calls get a reveal URL within 30 days. (3) Outcome parity: No/Partly reveal rate is at least 80% of Yes reveal rate (combined; minimum n=20). These test adoption, loop closure, and honesty without optimizing public humiliation.

## Claude Worker (Round 2)

**Converged spec framework (seal + reveal + metrics).**

Merging Codex's product clarity and implementation rigor with Claude's user-workflow focus:

**Product boundary.** Seal is a Hindsight-generated card image + caption, posted to X/LinkedIn at user's tap. Platform timestamp is the notary. No claims of cryptography or immutability; framing = transparency + social accountability. Sharing is explicitly optional; every Call is sealed locally on save, but receipt posting happens only on user action.

**Seal card (implement).** Header: `HINDSIGHT — TIMESTAMPED RECEIPT | SEALED`. Body: statement in quotation marks, `Confidence: [51-99]%`, `Resolve by: [date]`. Footer: `Sealed in Hindsight • Platform timestamp is the receipt` + compact Call ID. Visual: lock icon, confidence-tinted pastels (cool → warm as % rises). Caption: `I'm making this call: "[statement]". I'll report back by [date].` Once posted to X/LinkedIn, the permalink is canonical seal proof.

**Capture flow (three taps).** 1) Save Call (seals locally). 2) Tap `Share receipt` button. 3) Select X or LinkedIn; publish. On return to app, show `Add post link (paste or copy from share sheet)` → `Save` or `Not now`. Seal URL badge appears only after user confirms URL save. This approach keeps flow lean for MVP.

**Reveal card (at resolution).** User selects verdict [Yes ✓ | No ✗ | Partly ◐ | Can't-resolve ◈], optionally types max 280-character "What changed / what I learned?" Then tap `Share reveal`. Card shows: original statement, confidence, resolve date, `Result: [verdict]`, optional learnings, and visual link to seal URL. Caption: `Update to my receipt: [verdict]. Originally [confidence]% confident, resolve date was [date].` Share sheet pre-fills seal URL for quote-post. After publishing, user saves reveal URL; "Linked" badge shows when both URLs exist.

**Miss card (No/Partly only).** Template for No: `Missed it — [confidence]% confident, result was No. What I missed: [context optional].` For Partly: `Partly right. What the original call missed: [context optional].` Never pressure sensitive disclosures; context is optional. Miss replies post as top-level replies to the reveal quote-post, making the loss visible alongside the call's social proof.

**Success metrics (30-day cohort).** (1) Receipt attach rate: ≥20% of sealed Calls get a confirmed seal URL posted. (2) Reveal completion: ≥50% of URL-sealed Calls due within the window get a reveal URL posted within 30 days of resolve-by date. (3) Outcome parity: (No + Partly reveal rates) / (Yes reveal rate) ≥ 0.80 (minimum n=20 total). Metric 3 signals whether losses drive visibility as much as wins; metric 2 confirms loop closure; metric 1 confirms adoption entry point.

**MVP scope.** Core: seal card generation, caption text, X/LinkedIn share sheet integration, URL save flow, reveal card generation with optional context, outcome tallying. Defer: full dashboard analytics, cherry-picking guardrails on dashboard views, insight tile redesign, Brier/calibration rendering.


## Codex Worker (Round 2)

**Critique.** The combined draft correctly removes automatic sharing and treats URLs as user-confirmed evidence. Two adjustments make it more implementable and less misleading: a system share sheet cannot reliably know whether a network post succeeded or returned a permalink, so use an explicit `Paste post link` continuation (with a clearly optional `Skip`). Also, a “quote-post” cannot be guaranteed cross-platform; describe X as reply/quote where supported and LinkedIn as a normal update containing the seal URL.

**Revised receipt loop.** Local save seals the immutable Call snapshot (statement, confidence, resolve-by, compact ID). `Share receipt` renders the image and places the platform-specific caption on the share sheet. After the user returns, show `Did you publish it?` with `Paste post link`, `Skip for now`; validate an http(s) URL and store platform + URL + confirmed-at. Only then show `Receipt posted`; otherwise show `Receipt link not saved`—never infer publication.

Seal image fields remain exactly: `HINDSIGHT — TIMESTAMPED RECEIPT`, `SEALED`, quoted statement, confidence, resolve-by, lock, and footer `Sealed in Hindsight • Platform timestamp is the receipt • [ID]`. Caption should avoid a promise: `I’m making this call: “[statement]”. I plan to report back by [date].`

At resolution, select exactly one verdict, optionally add ≤280 characters, then `Share reveal`. The reveal image repeats the immutable snapshot plus `Result: [verdict]`, optional learning, and `Original receipt: [seal URL]` when saved (otherwise `No public receipt link saved`). Prefill `Update to my receipt: [verdict]. Originally [confidence]% confident. [seal URL]`. In X, the user may quote/reply to the original; elsewhere it is a post with the URL. Confirm the reveal link using the same paste/skip flow. `Linked` requires both confirmed links.

For No: `Missed it — [confidence]% confident; result: No. What I missed: [optional context]. The lesson is the point.` For Partly: `Partly right, partly wrong. What the call missed: [optional context].` No secondary “reply” requirement.

**Metrics (30-day cohort):** attach rate ≥20%; confirmed reveal rate ≥50% among confirmed seals due in-window; outcome parity `(No + Partly reveal rate) / Yes reveal rate ≥0.80`, report only at n≥20. Calculate all learning insights from every resolved Call; separately retain shared, unshared, overdue, late-reveal, and locally removed-link states.

## Claude Worker (Round 3)

**Convergence rationale.** Both positions agree on the core loop: local seal on save, optional social receipt posting, reveal with verdict and optional learnings, miss templates, and three behavioral metrics. Codex's Round 2 critique improves implementation rigor on two critical points: (1) never infer publication success from the system share sheet—instead, explicitly ask the user to confirm the URL was posted, validating it before storing proof; (2) adjust caption wording from “I'll report back” to “I plan to report back” to avoid over-promising and maintain honest framing. These are not contradictions but implementation details that strengthen both user trust and data accuracy. The merged spec below incorporates both clarifications while keeping flow lean and implementable within MVP scope.

**Key decisions.**
- URL confirmation is explicit, not inferred: user taps “Did you publish it?” and either pastes/opens the post URL or skips. Only confirmed URLs earn the “Receipt posted” badge.
- Caption avoids absolute promises: “I plan to report back” signals intention without guaranteeing platform delivery.
- Miss cards post optional context inline (no secondary reply mechanism); loss-framing is the template itself.
- Metrics remain unchanged: attach ≥20%, reveal completion ≥50%, outcome parity ≥0.80 (n≥20).
- MVP: seal/reveal card generation, caption templating, URL confirmation flow, outcome tallying. Dashboard analytics, cherry-pick guardrails, and Brier/calibration rendering deferred.

## CONVERGED SPEC

**Product boundary.** A Timestamped Receipt is a Hindsight-generated card (seal and reveal) with caption text, posted by the user to X/LinkedIn. The platform's public post timestamp and returned permalink are the only external notary; Hindsight never claims cryptographic permanence or tamper-proof storage. Every Call is sealed locally on save; sharing to social is explicitly optional and user-initiated. Receipt proof requires a confirmed post URL.

**Seal card (spec).** Header: `HINDSIGHT — TIMESTAMPED RECEIPT | SEALED`. Body: statement in quotation marks (e.g., `”Q3 revenue will exceed $2M”`), `Confidence: [51-99]%`, `Resolve by: [date]` (e.g., `31 Oct 2026`). Footer: `Sealed in Hindsight • Platform timestamp is the receipt • [compact Call ID]`. Visual: lock icon, confidence-tinted pastel background (cool hues for 51–70%, warm for 70–99%). No outcome, score, or follow prompt. Caption (to be placed in share sheet): `I'm making this call: “[statement]”. I plan to report back by [date].`

**Capture flow (four taps).** 1) Save Call (seals locally). 2) Tap `Share receipt`. 3) Select X or LinkedIn in system share sheet; publish. 4) Return to app → tap `Did you publish it?` → Either paste/open post URL or tap `Skip for now`. If URL is provided, validate http(s) format and store platform + URL + confirmed-at timestamp; show `Receipt posted` badge. If skipped, show `Receipt link not saved` and allow user to try again later. Seal URL badge appears only after user confirms a URL.

**Reveal card (spec).** On resolution: user selects exactly one verdict [Yes ✓ | No ✗ | Partly ◐ | Can't-resolve ◈], optionally types max 280 characters describing “What changed / what I learned?”, then taps `Share reveal`. Card image repeats immutable seal fields (statement, confidence, resolve-by) plus `Result: [verdict]`, optional learning text, and `Original receipt: [seal URL]` (or `No public receipt link saved` if not posted). Caption: `Update to my receipt: [verdict]. Originally [confidence]% confident.` For X, user may quote/reply to original seal post; elsewhere (LinkedIn), user posts with the seal URL included. After user publishes, show `Did you publish it?` with same paste/skip flow. Confirm reveal URL; show `Linked` badge only when both seal and reveal URLs are saved.

**Miss card (No/Partly only).** No: `Missed it — [confidence]% confident; result: No. What I missed: [optional context]. The lesson is the point.` Partly: `Partly right, partly wrong. What the call missed: [optional context].` Context is optional; never pressure disclosure of sensitive details. These templates appear as a shareable image with accompanying caption during reveal posting; they are optional social shares, not required steps.

**Success metrics (30-day rolling cohort).** (1) Receipt attach rate: ≥20% of sealed Calls receive a confirmed seal URL posted within the first 7 days. (2) Reveal completion: ≥50% of URL-sealed Calls with a resolve-by date in the window receive a confirmed reveal URL within 30 days of resolve-by date. (3) Outcome parity: (No + Partly reveal rate) / (Yes reveal rate) ≥ 0.80 (minimum n=20 total resolved). Metrics 1 and 2 measure loop adoption and closure; metric 3 ensures losses drive visibility as much as wins, signaling honest framing.

**MVP scope.** Seal card generation and caption. X/LinkedIn share sheet integration. Explicit URL confirmation and storage (validate, store platform + URL + timestamp). Reveal card generation with optional context. Outcome tallying and metrics calculation (track all resolved Calls; separately record shared vs. unshared, on-time vs. overdue, confirmed-seal vs. no-URL states). Defer: dashboard analytics views, cherry-pick guardrails (separate shared/unshared in dashboards), Brier score and calibration rendering, insight tile redesign.
