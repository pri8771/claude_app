# Claude Design Prompt — Hindsight Social v2

Copy everything below into Claude Design.

---

Design a production-quality, high-fidelity mobile experience for **Hindsight Social v2**, an iOS-first social prediction app. Deliver an organized Figma file and an interactive prototype. This is a design and behavior specification task, not an engineering or product-research task: do not invent backend capabilities, policies, metrics, user research, or technical guarantees that are not stated here. Where a backend-dependent behavior is unresolved, represent it as an explicit UI state or annotation, not as a claim that it exists.

## 1. Product promise and target user

**Promise:** “Make a call in seconds, lock it with a timestamp, compare forecasts with friends or the world, and learn who is genuinely well calibrated.”

Primary user: a socially motivated, mobile-native forecaster who wants a fast, satisfying way to make a prediction with friends, return for the reveal, and see evidence-based improvement. The first-session promise is: understand the product and make or join a prediction without learning a journal workflow.

Primary Phase-1 loop:

```text
Invite/open app -> understand prompt -> make a forecast -> server-confirmed lock
-> wait/reveal -> see group and personal result -> share a privacy-safe Receipt
```

The premium feeling should come from clarity, confidence, restraint, editorial hierarchy, and a rewarding reveal—not from visual noise, gambling cues, or fake social proof.

## 2. Non-negotiable product and trust rules

- A social forecast is not “locked” until server confirmation. Design distinct draft, sending, confirmed, offline/queued, failed, and retry states.
- Use a server-issued timestamp conceptually; do not imply client time is authoritative.
- Show visibility before submission: `Private`, `Group`, `Unlisted link`, or `Public`. Phase 1 focuses on private groups; do not design a public feed as a core MVP destination.
- Hide other votes and aggregate percentages until the person submits, except a clearly labelled open-poll event. Never use blurred results as a tease that implies data is already visible.
- Forecast history is immutable. Before lock, corrections make a new revision; after lock, additions are notes, not silent edits.
- Existing private journal content stays local unless the owner explicitly consents to sync or converts a specific item. Include a clear migration/consent concept, never a silent import.
- Public rankings use calibration/proper scoring, not raw wins, posting volume, or confidence theater. Every stat needs a visible denominator/sample state. Low-sample users are `Emerging` or `Unranked`, not labelled good or bad.
- Subjective private-group outcomes never visually imply verified public rank.
- Public-event, moderation, and backend operations are later phases. Do not make their policy or operational UI look already shipped.
- No precise location or real-time location. If a local/community concept appears, make coarse opt-in location and its privacy boundary explicit.
- Reporting, blocking, deletion, account recovery, offline, permission, conflict, rate-limit, cancellation, loading, empty, and server-error states require intentional UI patterns.
- Never include real-person data, undisclosed fake success data, fabricated resolver evidence, or claims of completed research.

## 3. Information architecture

Design and annotate a four-destination shell:

1. **Home** — immediate composer, due/reveal queue, recent activity, one helpful personal insight.
2. **Groups** — private groups, group feed, group creation, membership/invites, group leaderboard.
3. **Discover** — phase-aware discovery entry. For MVP, show a clearly labelled future/empty or curated preview state; do not turn it into a public social feed.
4. **Profile** — personal calibration, sample-aware insights, privacy/account controls, history.

Use a persistent, obvious create affordance. Separate local/private journal records from shared social predictions in hierarchy and labels. Define route names, deep-link destinations, modal versus push transitions, return destinations, and back behavior.

## 4. Required screens and states

Create the following at iPhone 16 Pro Max size plus a smallest-supported-iPhone layout for the essential flows. Provide light and dark mode for the core loop.

### A. Acquisition and onboarding

1. **Invite landing / universal-link handoff**: group context, privacy-safe invitation explanation, sign-in/create-account path, invalid/expired/revoked invite, already-a-member, and offline states.
2. **Welcome / value proposition**: one concise explanation, no early permission wall.
3. **Account identity and profile setup**: Sign in with Apple-ready placeholder, display-name/handle boundary, avatar optional state, validation/error states.
4. **Existing-user migration consent**: explain local history remains local by default; allow `Keep local`, `Review items`, and explicit opt-in sync/conversion. Include interrupted/retry/declined state.
5. **Interactive sample prediction**: clearly labelled preview/demo, excluded from personal stats, with a path into the real loop.
6. **Contextual permission prompts**: notification rationale only after a meaningful event; denied and settings-recovery states.

### B. Fast capture and forecast response

7. **Universal one-screen prediction composer**: statement, binary/custom outcomes, explicit confidence, close/reveal horizon, audience selector, and one primary `Lock it in` action. Optional context/category/evidence/notes are progressive disclosure.
8. **Composer variants**: personal local save, group prediction, invalid fields, keyboard visible, custom-outcome editing, date ordering error, no network, submitting, confirmed, server rejection, duplicate-tap prevention, and retained-draft retry.
9. **Vote sheet for an existing binary prediction**: two choices plus submit as the primary path; other forecasts hidden before submission; explicit confidence; locked deadline and visibility explanation.
10. **Locked confirmation / Receipt preview**: server timestamp, selected outcome and confidence, audience, what changes are allowed, share action, and non-social local-save distinction.

Interaction target: after entering the statement, a returning user makes a valid binary prediction in **no more than four deliberate actions**. Joining an existing binary prediction requires **choice + submit** (with confidence available as an explicit, unobtrusive control when required by the contract). Do not hide required trust information to meet the tap target.

### C. Private group loop

11. **Groups list**: empty, loading, error/retry, recent groups, invitations, and create-group entry.
12. **Create private group**: purpose/name, privacy explanation, members/invitation entry, validation, create-in-progress/failed/confirmed states.
13. **Group home/feed**: open, closing soon, locked, waiting for resolution, resolved, voided/disputed cards; member-safe activity; empty state; removed-access state.
14. **Prediction detail**: prompt, outcome choices, deadline, resolution rule, participant’s own state, visibility policy, forecast form or lock state, evidence/resolution area, reporting/blocking entry where relevant.
15. **Invite sharing and join confirmation**: privacy-safe share preview, invite token-sensitive state (never expose raw token unnecessarily), pending/accepted/declined/expired/revoked states.
16. **Group leaderboard**: calibration-first rank, denominator/sample gates, period filter, `Emerging`/`Unranked`, group versus individual comparison, and a transparent scoring explainer. Do not visually reward volume or certainty alone.

### D. Reveal, analytics, and sharing

17. **Resolution and reveal**: result, evidence/source placeholder, status (`resolving`, `resolved`, `disputed`, `corrected`, `voided`), user forecast versus outcome, score-impact explanation, reduced-motion static equivalent.
18. **Personal insight**: engaging but honest calibration analysis, including patterns such as “When you were 80%+ confident, you were right 46% of the time” only when sample threshold is met; otherwise present `not enough resolved forecasts yet` and show the path to earn the insight. Always show denominator, date range, and scoring explanation.
19. **Privacy-safe Receipt card**: a beautiful shareable artifact containing only the audience-appropriate prompt/result/statistics. Design private-group-safe and public-safe variants; never disclose group name, other users, invite data, or hidden forecasts unless the audience policy permits it.
20. **Native-share handoff**: share preview and cancellation/success return state; do not assert iMessage extension implementation exists yet.

### E. Trust, account, and resilience

21. **Profile and reliability state**: profile, calibration history, sample gates, account/delete/export entry points, no-data/loading/error states.
22. **Privacy/visibility controls**: explain each scope in plain language; conversion confirmation; no accidental broadening of audience.
23. **Block/report flows**: report category, confirmation, blocked-member consequences, success/failure; keep these usable without revealing moderator operations.
24. **Offline/sync/recovery patterns**: local-only success, queued social action, sending, confirmed, rejected, conflict, retry, and account/sign-out recovery. Show state in text, not color alone.

## 5. Premium design-system deliverables

Create a reusable system rather than isolated screens:

- Figma variables/tokens for semantic light/dark color, typography, spacing, radius, elevation, stroke, icon sizing, and states. Name by intent, not raw color (for example `surface.primary`, `text.muted`, `status.locked`).
- Type scale with roles, weights, line heights, truncation/wrapping rules, and Dynamic Type behavior.
- Components with variants and interactive states: navigation, buttons, text fields, composer fields, confidence control, horizon chips, audience selector, cards, prediction-status badge, outcome selector, avatars, group list rows, charts, leaderboard rows, banners, sheets, dialogs, toast/inline error, skeletons, empty states, privacy labels, and Receipt card.
- Confidence must have a text equivalent such as `75% confident`; do not use hue, graph shape, or haptics as the only carrier of meaning.
- Define chart grammar: all charts show labels, date range, denominator/sample size, accessible summary text, low-sample state, and a detail/explainer route.
- Define lock/reveal visual language and restrained motion/haptics. Motion must reinforce state change, never obscure it.
- Include redlines/annotations for 44×44-point targets, safe areas, keyboard behavior, loading occupancy, and content overflow.

Avoid generic fintech dashboards, casino/market language, noisy gradient surfaces, gamified streak pressure, and opaque “AI insight” styling. The tone should be composed, intelligent, warm, and consequential.

## 6. Accessibility and inclusive behavior

- Design for smallest supported iPhone portrait, iPhone 16 Pro Max portrait, iPad portrait/landscape where the app supports it, keyboard visible, largest accessibility Dynamic Type, VoiceOver, dark mode, and Reduce Motion.
- Keep all primary controls at least 44×44 points. Provide a logical VoiceOver/focus order and visible focus treatment.
- Every locked, queued, error, invite, audience, confidence, resolution, and score state must be readable as text.
- Support text wrapping and vertical expansion; do not solve Dynamic Type by truncating critical dates, audience, outcome, or confirmation text.
- Reduced Motion must show an informationally equivalent static lock/reveal state. Haptics/sound are optional and never sole confirmation.
- Meet contrast requirements and provide non-color cues for status and charts.

## 7. Prototype flows and usability criteria

Build interactive prototypes for:

1. New invitee: invite landing -> onboarding/account -> join a private group -> submit a forecast -> server-confirmed lock.
2. Returning creator: Home -> one-screen composer -> group audience -> lock -> Receipt share preview.
3. Group member: group feed -> hidden-vote prediction -> submit -> see own locked state, not other votes.
4. Reveal: notification/deep link -> resolved prediction -> personal/group result -> calibration insight -> safe Receipt share.
5. Failure/recovery: offline or failed submission -> retained draft/queued state -> retry -> confirmed lock.
6. Existing user: migration offer -> decline sync -> use local record without any social upload.

Annotate prototype success measures; do not claim they were achieved. The later usability test should ask uncoached participants to complete the flows and measure:

- Time from statement entry to valid forecast (target median: under 10 seconds).
- Deliberate actions after text entry (target: four or fewer for binary creation).
- Whether participant understands what is locked, who can see it, and when other votes become visible.
- Whether participant can distinguish a local save, queued state, and server-confirmed lock.
- Whether at least 4 of 5 participants can complete invite -> forecast -> reveal without explanation.

## 8. Figma organization and handoff requirements

Organize the file using these pages, in this order:

1. `00 Cover & Product Rules`
2. `01 IA & Flow Maps`
3. `02 Foundations & Tokens`
4. `03 Components`
5. `04 Core Screens — Light`
6. `05 Core Screens — Dark`
7. `06 States & Edge Cases`
8. `07 Prototype`
9. `08 Accessibility & Handoff`

Use consistent frame names: `[Area] / [Screen] / [State] / [Device]`, for example `Composer / Group binary / Server confirmed / iPhone 16 Pro Max`. Name components and variants semantically. Add implementation annotations alongside each primary screen: route, entry condition, visible data, state, events/actions, failure behavior, accessibility notes, and unresolved backend dependency. Use only clearly marked placeholder content, never disguised production data.

## 9. Explicit non-goals for this deliverable

- Do not design or imply shipped direct messages, follower feeds, monetization, betting/real-money mechanics, arbitrary public user events, creator economy, exact location sharing, or an iMessage extension implementation.
- Do not redesign the backend, choose a backend vendor, expose database schemas, or invent APIs.
- Do not claim legal approval, accessibility certification, research results, App Store approval, or operational moderation capacity.
- Do not replace the private journal with social posting or silently migrate user content.

## 10. Required final response format

When finished, respond with exactly these headings and concise bullets:

1. `Figma file and prototype` — links/locations and the pages created.
2. `Design-system inventory` — tokens, components, and variants.
3. `Core flows covered` — each prototype flow and included states.
4. `Accessibility coverage` — layouts/states explicitly addressed.
5. `Implementation handoff` — named frames/annotations that an iOS implementation model should consume first.
6. `Open decisions and assumptions` — only unresolved items; do not fill gaps with invented behavior.
7. `Usability-test script` — the uncoached tasks and measurement fields, labelled as proposed.

Do not include a long narrative, fabricated outcomes, or claims that code, backend behavior, research, or policy approval has been completed.
