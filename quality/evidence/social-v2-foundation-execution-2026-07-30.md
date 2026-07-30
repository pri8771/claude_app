# Social v2 Foundation Execution Evidence — 2026-07-30

## Scope and truthful status

This evidence covers the locally executable portion of Social v2 foundation tasks F0.1–F0.7 on
branch `dev`. It proves that the planning/contracts and local safety tooling integrate with the
existing iOS app. It does **not** complete the foundation, approve ADR-008, provision a cloud
backend, validate a design with users, satisfy legal review, or authorize Phase 1 feature code.

Lifecycle: `verification_pending`.

No production credentials, external users, real user content, backend account, Social v2 app
feature code, Xcode dependency, or third-party runtime dependency was introduced.

## Artifacts produced

- `Docs/CLAUDE_DESIGN_PROMPT.md`
- `Docs/SOCIAL_V2_PRODUCT_CONTRACT.md`
- `Docs/SOCIAL_V2_BACKEND_EVALUATION.md`
- `Docs/ADR-008-SOCIAL-BACKEND.md`
- `Docs/SOCIAL_V2_DOMAIN_API_CONTRACT.md`
- `Contracts/social-v1.openapi.yaml`
- `Contracts/README.md`
- `Docs/SOCIAL_V2_PRIVACY_SAFETY_POLICY.md`
- `Docs/SOCIAL_V2_LEGAL_STORE_CHECKLIST.md`
- `Docs/SOCIAL_V2_MIGRATION_SYNC_PLAN.md`
- `Docs/SOCIAL_V2_DELIVERY_RUNBOOK.md`
- `Docs/SOCIAL_V2_EXECUTION_TRACKER.md`
- `Config/SocialV2/environment-manifest.example.json`
- `Scripts/validate_social_environment.sh`
- `Scripts/social_v2_client_ci.sh`
- `Backend/Spike/Postgres/`

## Verification results

### PostgreSQL integrity slice

The corrected disposable local PostgreSQL spike passed with synthetic identities and data:

```text
SPIKE_TEST_RESULT=PASS
FORECAST_COUNT=1
AUDIT_COUNT=1
RESOLUTION_COUNT=1
SCORE_PLACEHOLDER_COUNT=1
SPIKE_CLEANUP=REMOVED
```

It demonstrated active-membership authorization, server-clock deadlines, idempotent same-payload
replay, rejection of changed payloads and second forecasts, atomic forecast-plus-audit creation,
immutable forecast/audit records, rejection of outsiders/removed members/late writes, append-only
resolution, and a deliberately formula-less score placeholder. Cleanup removed the exact
marker-owned database; a direct catalog query returned `false` for its continued existence.

Detailed evidence: `quality/evidence/f03-postgres-integrity-spike-2026-07-30.md`.

### Contract and local delivery checks

- Bash syntax validation passed for every script under `Backend/Spike/Postgres/` plus
  `Scripts/validate_social_environment.sh` and `Scripts/social_v2_client_ci.sh`.
- JSON parsing passed for the App Factory context, quality manifest, Social v2 feature contract,
  and example environment manifest.
- `Contracts/social-v1.openapi.yaml` parsed as YAML; required OpenAPI top-level structure was
  present and all 204 internal `$ref` values resolved.
- The example environment manifest was rejected as intended because placeholder/example values
  cannot be promoted.
- A generated, non-secret development fixture was accepted by the environment validator and was
  not retained in the repository.
- `Scripts/privacy_no_network_audit.sh Hindsight` passed: the current local client contains no
  networking or tracking APIs.
- Repository diff, JSON, and privacy gates passed through
  `Scripts/social_v2_client_ci.sh --skip-xcode`.
- No trailing whitespace was found in the changed artifacts.

### Existing iOS regression

Command:

```bash
Scripts/social_v2_client_ci.sh \
  --destination 'platform=iOS Simulator,id=ECE07C31-F8DD-4936-A59D-05390000E57B' \
  --derived-data /private/tmp/hindsight-social-v2-foundation-derived-20260730 \
  --result-bundle /private/tmp/hindsight-social-v2-foundation-20260730.xcresult
```

Result:

```text
result: Passed
totalTestCount: 73
passedTests: 73
failedTests: 0
skippedTests: 0
device: iPhone 17 Pro simulator
OS: iOS 26.5
```

The result includes all three UI tests: Quick Capture, Quick Capture at the largest accessibility
text size, and the retained detailed capture wizard.

## Required evidence still missing

- Product-owner approval of F0.1 scope, metric formulas, thresholds, and open decisions.
- Claude Design/Figma output, design sign-off, and five real uncoached prototype sessions.
- Hosted Apple-token validation, provider RLS, realtime reconnect, APNs recovery, backup/export,
  development/QA isolation, and true multi-session deadline/load proof.
- Explicit ADR-008 acceptance or rejection.
- Full pinned OpenAPI lint/generation and generated-client compatibility.
- Joint engineering, privacy, safety, and legal review of retention, age/minors, moderation,
  account deletion/export, consent, and migration decisions.
- Real isolated environments, secret stores, hosted CI/security gates, dashboards/budget alerts,
  promotion manifests, and a QA restore/rollback game day.

Until these exist, all Phase 1 Social v2 implementation tasks remain queued and `qa` must remain
at the last verified Build 1 baseline.
