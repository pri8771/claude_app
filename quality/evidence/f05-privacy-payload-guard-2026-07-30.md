# F0.5 privacy payload guard evidence — 2026-07-30

## Status

`verification_pending`. This is local, deterministic validation evidence only; it is not privacy/legal approval, telemetry implementation, network transmission, APNs delivery evidence, hosted CI evidence, or physical-device evidence.

## Scope

- Added `Config/SocialV2/privacy-payload-policy.json`, a dependency-free closed allowlist for content-free product telemetry, operational telemetry, and generic APNs-shaped payloads.
- Added synthetic JSON fixtures under `Contracts/PrivacyFixtures/`.
- Added `Scripts/validate_social_privacy_payloads.rb` and `Scripts/social_v2_privacy_ci.sh`.
- The policy requires environment plus schema/build/API/schema versions, opaque identifiers, and enumerated event/result/error classes. Push payloads use an enumerated generic localization key and an enumerated opaque route ID; localization arguments are not allowed.
- The validator fails closed for unknown fields, forbidden content/key classes, URLs, email, precise coordinate shapes, secret-like values, foreign environment markers, oversized strings, invalid opaque IDs, and unapproved enum values.

## Checks run

Command:

```bash
ruby -c Scripts/validate_social_privacy_payloads.rb && bash Scripts/social_v2_privacy_ci.sh
```

Result: exit code `0`.

```text
Syntax OK
PASS allowed-generic-push.json: accepted
PASS allowed-operational-telemetry.json: accepted
PASS allowed-product-telemetry.json: accepted
PASS forbidden-freeform-oversized.json: rejected OVERSIZED_VALUE
PASS forbidden-freeform-thread-id.json: rejected INVALID_OPAQUE_ID
PASS forbidden-group-handle.json: rejected FORBIDDEN_FIELD
PASS forbidden-mixed-environment.json: rejected MIXED_ENVIRONMENT
PASS forbidden-precise-coordinate.json: rejected PRECISE_COORDINATE
PASS forbidden-prediction-text.json: rejected FORBIDDEN_FIELD
PASS forbidden-secret-like.json: rejected SECRET_LIKE_MATERIAL
PASS forbidden-token.json: rejected FORBIDDEN_FIELD
PASS forbidden-unknown-field.json: rejected UNKNOWN_FIELD
PASS forbidden-url.json: rejected RAW_URL
PASS: 13 deterministic privacy payload fixtures validated
```

## Limitations and remaining blockers

- No application telemetry, networking, provider SDK, push-token handling, APNs request, or delivery was added or exercised.
- This validator is a machine-enforced fixture/payload boundary, not a substitute for server-side scrubbing, runtime integration tests, hosted CI, production secret scanning, privacy/legal review, or F0.5 approval.
- Pattern checks are conservative and cannot prove that every future value is non-sensitive; any new field, event class, route, localization key, or payload shape requires an explicit policy/fixture update and review.
- Social v2 remains blocked on the unresolved approval and delivery gates recorded in the privacy policy and delivery runbook.
