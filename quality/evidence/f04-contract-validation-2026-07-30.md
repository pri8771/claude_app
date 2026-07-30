# F0.4 local contract-validation evidence — 2026-07-30

**Lifecycle:** `verification_pending`

## Scope

Validated the proposed vendor-neutral `Contracts/social-v1.openapi.yaml` and the synthetic F0.4 fixture declarations. No runtime service, identity provider, generated client, vendor SDK, or participant data was used.

## Exact commands and results

```text
$ bash Scripts/social_v2_contract_ci.sh
PASS: OpenAPI structure, references, security, idempotency, schemas, and examples
PASS: 2 positive fixture expectations validated
PASS: 16 negative fixture expectations validated

$ ruby -c Scripts/validate_social_contract.rb
Syntax OK

$ bash -n Scripts/social_v2_contract_ci.sh
(exit 0; no output)

$ git diff --check -- Contracts/README.md Contracts/Fixtures Scripts/validate_social_contract.rb Scripts/social_v2_contract_ci.sh
(exit 0; no output)
```

The validator uses only Ruby standard-library `YAML` and `JSON`. It verifies OpenAPI 3.1 structure, local reference resolution, unique operation IDs, required `Idempotency-Key` headers for write operations, global/operation security, component-backed JSON response/error schemas, and secret-like contract examples. Fixture metadata is checked recursively for secret-like values and prohibited content fields; two positive expectations and all sixteen negative expectations from Domain Contract section 7 have recognized outcomes and allowed reason codes. This is declaration validation, not evidence that a backend executed those outcomes.

## Limitations / remaining verification

This is not a full external OpenAPI linter, a generated-client compatibility check, a backend/runtime authorization test, a schema-fuzzing suite, or proof that a deployed service returns these responses. The fixtures contain synthetic request metadata and expected outcomes only; authorization, atomic locking, cursor reconciliation, server time, and cross-environment isolation require later backend/hosted evidence after the F0.3/F0.5/F0.7 gates are accepted.
