# Hindsight API Contracts

`social-v1.openapi.yaml` is the vendor-neutral, proposed OpenAPI 3.1 boundary for the Social v2 Phase 1 foundation. It is not a commitment to a backend vendor, SDK, production endpoint, generated client, or legal/privacy policy.

Use [the domain contract](../Docs/SOCIAL_V2_DOMAIN_API_CONTRACT.md) for authorization semantics, state machines, retention, audit, realtime reconciliation, and negative fixtures. The OpenAPI schema intentionally represents only the minimum identity/session boundary, private groups, invites, events, forecasts, resolution, leaderboard, and Receipt reads/writes needed to plan Phase 1.

Before implementation: accept F0.3/F0.5/F0.7 gates, choose an API generator/linter, validate generated-client compatibility, add synthetic fixtures/contract tests, and replace all `TBD` policy values through recorded decisions. Do not expose provider/database table APIs or place credentials/tokens in this repository.

## Local structural validation

Run `Scripts/social_v2_contract_ci.sh` to validate the checked-in OpenAPI document and synthetic fixture metadata without network access or third-party gems. It checks OpenAPI 3.1 structure, internal references, unique operation IDs, idempotency headers on writes, explicit security, stable JSON/error schemas, and secret/content-free examples. It also validates the expected outcome and reason metadata for the positive fixtures and all 16 Section 7 negative fixture declarations.

This is intentionally not a full OpenAPI linter, runtime authorization test, generated-client compatibility check, or backend integration test. The fixtures are contract-test inputs/expectations only; they do not assert a live service.
