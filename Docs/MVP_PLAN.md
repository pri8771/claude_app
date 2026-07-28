# MVP → TestFlight Plan — Baseline M1.0

**Baseline frozen:** 2026-07-28
**Status:** BASELINE — estimates immutable. Change flows through `CHANGE_REQUEST_LOG.md`.
**Precedes:** `POST_MVP_MASTER_PLAN.md` (Baseline v1.0), which starts after this ships.

---

## Where we are today

| | State |
|---|---|
| **App** | Original Decision journal. 4-step wizard, original analytics screen. Builds and runs. |
| **Tests** | 59 unit tests passing |
| **Device** | Installed on iPhone 16 Pro Max via dev signing — **expires ~2026-08-03** |
| **Branches** | `dev` current · `qa` behind · `archive/call-pivot-complete` holds the reverted pivot |
| **Already done** | Privacy manifest ✓ · 15 app icons ✓ · launch screen ✓ · haptics ✓ · onboarding ✓ |
| **Version** | 1.0 (build 1) — never uploaded to App Store Connect |
| **Gap** | Capture takes too many taps. That is the whole reason for this plan. |

---

## The core decision: two TestFlight builds, not one

**Ship TestFlight Build 1 without voice.**

Voice is 16 days of the highest-risk work in the plan (unverified API, device-capability gating,
parsing accuracy). The TestFlight pipeline itself also has unknowns — distribution signing, App
Store Connect, Beta App Review. **Do not debug both at once.**

Build 1 proves the pipeline and tests the actual bet — *does anyone close the loop?* — using
tap-based quick capture. Build 2 adds voice once the pipeline is boring and the loop is validated.

If quick capture alone doesn't get people resolving predictions, voice would not have saved it,
and you will have learned that 16 risky days earlier.

**Corollary worth banking:** the App Group store migration (`E1.1`/`E1.2`, the single
highest-risk item in the post-MVP baseline) is **not needed for either MVP build.** In-app voice
runs in the app's own process. That migration is only required for widgets and Siri extensions,
which are post-MVP.

---

## Build 1 — Quick capture MVP

Goal: capture in under ten seconds, first payoff within days.

| ID | Task | Fn | Est | Risk | Notes |
|---|---|---|---|---|---|
| M1.1 | Quick Capture sheet — statement, confidence, "ask me again when" | ENG | 3 | MED | Writes `Decision` + one `Prediction`. **No schema change** (verified) |
| M1.2 | Entry point: prominent capture button on Today | ENG | 1 | LOW | Wizard demoted to "add detail" |
| M1.3 | Short-horizon date chips (tomorrow / this week / month / 6mo) | ENG | 1 | LOW | Short options first |
| M1.4 | First-session nudge toward one short-horizon call | DESIGN | 1 | MED | The retention lever |
| M1.5 | Clarity score reframe — invitation, not grade | DESIGN | 1 | MED | Quick captures currently score 33 → "Sketchy" |
| M1.6 | Resolve ritual — fast card stack for everything due | ENG | 3 | MED | The payoff moment. Reference impl on archive branch |
| M1.7 | Overconfidence stat on Insights | ENG | 2 | LOW | "You say 90%, you're right 70%" |
| M1.8 | Gentle reveal copy pass | DESIGN | 1 | MED | Being wrong must not feel like punishment |
| M1.9 | MVP test coverage | QA | 3 | MED | Capture, resolve, stat correctness |
| M1.10 | Manual VoiceOver pass on new surfaces | QA | 2 | MED | Carried over, still outstanding |

**Subtotal: 18 days**

---

## TestFlight release track

Runs partly in parallel with Build 1. **Internal testing needs no App Review** — that is the fast
path to real devices.

| ID | Task | Fn | Est | Risk | Notes |
|---|---|---|---|---|---|
| T1 | Register bundle ID + create App Store Connect record | OPS | 0.5 | LOW | Needs your paid account |
| T2 | Distribution certificate + provisioning profile | OPS | 0.5 | MED | Separate from the dev signing in use now |
| T3 | Release config audit — version/build, no debug flags, UI-test args inert | ENG | 1 | MED | Verify `-uiTestReset` cannot fire in Release |
| T4 | Privacy nutrition labels in App Store Connect | LEGAL | 0.5 | MED | Required at upload |
| T5 | Privacy policy — write + host at a public URL | LEGAL | 1 | MED | Required for **external** testing |
| T6 | First archive + upload + internal testers | OPS | 1 | **HIGH** | First upload always surprises |
| T7 | TestFlight beta description + feedback email | MKT | 0.5 | LOW | |
| T8 | External testing: Beta App Review submission | OPS | 0.5 | MED | +1–2 calendar days of review |

**Subtotal: 5.5 days** (plus review latency)

**Critical distinction:** internal testers (up to 100, on your team) get builds immediately with
no review. External testers require Beta App Review and a live privacy policy URL. Start internal.

---

## Build 2 — Voice capture

| ID | Task | Fn | Est | Risk | Notes |
|---|---|---|---|---|---|
| V1 | On-device speech + Foundation Models API spike | ENG | 2 | **HIGH** | Verify against current Apple docs — post-dates training data |
| V2 | Record + on-device transcription | ENG | 3 | **HIGH** | Must force on-device; never fall back to network |
| V3 | Parse utterance → Decision + Prediction draft | ENG | 4 | **HIGH** | |
| V4 | Confirmation / correction UI | ENG | 3 | MED | Never save a parse silently |
| V5 | Confidence follow-up (unset is honest; never fabricate) | ENG | 2 | MED | |
| V6 | Fallback for non-Apple-Intelligence devices | ENG | 2 | MED | Transcribe to notes |
| V7 | Voice test coverage | QA | 2 | MED | |

**Subtotal: 18 days**

---

## Totals and predictions

| Track | Days |
|---|---|
| Build 1 (quick capture MVP) | 18 |
| TestFlight release track | 5.5 |
| **To first TestFlight build** | **23.5** |
| Build 2 (voice) | 18 |
| **To voice-complete MVP** | **41.5** |

These are **ideal days** — uninterrupted work. Calendar time depends entirely on hours per week.

**Estimates deliberately padded.** Baseline v1.0's first measured error was an 18% undercount of
an already-written list (`CR-000c`). These numbers carry that lesson; if they still come in low,
that is itself the finding.

**Falsifiable predictions for this baseline:**

| # | Prediction | Confidence |
|---|---|---|
| M-P1 | First TestFlight upload (T6) exceeds its 1-day estimate | 80% |
| M-P2 | Build 1 actual exceeds 18 days | 75% |
| M-P3 | V3 (utterance parsing) is the largest single overrun in the plan | 70% |
| M-P4 | At least one Build 1 task is cut to reach TestFlight sooner | 65% |
| M-P5 | Beta App Review passes first submission | 70% |

---

## Sequence

```
Week 1   M1.1 M1.2 M1.3        ‖  T1 T2      (capture works end-to-end; signing ready)
Week 2   M1.6 M1.7 M1.5 M1.4   ‖  T3 T4 T7   (loop closes; release config clean)
Week 3   M1.8 M1.9 M1.10       ‖  T6         ── INTERNAL TESTFLIGHT
Week 4   observe + fix         ‖  T5 T8      ── EXTERNAL TESTFLIGHT
Then     V1…V7                              ── BUILD 2
```

**Ship gate for Build 1:** a stranger can capture a prediction in under ten seconds and resolve
one without instruction.

**The metric that matters:** what fraction of testers resolve at least one prediction within 14
days. Not installs, not captures — resolutions. If that number is bad, stop and rethink before
building voice.

---

## Immediate next actions

1. **You:** confirm the paid account can create an App Store Connect record (unblocks T1/T2).
2. **Me:** M1.1 Quick Capture sheet — the single highest-leverage change in the plan.
3. **Both:** re-sign the dev build before ~2026-08-03 or the app stops launching on your phone.
