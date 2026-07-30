# F0.7 hosted CI definition — 2026-07-30

- **Lifecycle:** `verification_pending`.
- **Definition:** `.github/workflows/social-v2-foundation.yml` runs on pull requests targeting `dev` or `qa`, pushes to those branches, and manual dispatch. It has immutable/read-only `contents: read` permissions and cancels superseded runs for the same PR or ref.
- **Validation gates:** tracked JSON syntax, workflow YAML syntax, every tracked shell and Ruby script syntax, range-aware `git diff --check` using the PR base or pre-push commit, Social v2 contract and privacy-payload gates, the current no-network/privacy audit, and a conservative credential-like scan.
- **Apple test gate:** the workflow calls `Scripts/resolve_social_ci_destination.sh`, which queries the selected Xcode's `simctl` JSON for an available iPhone and emits an ID-based destination. The workflow then runs the existing shared `Hindsight` scheme through `Scripts/social_v2_client_ci.sh`; that scheme includes `HindsightTests` and `HindsightUITests` (unit/integration and UI-smoke coverage). No simulator name or UUID is hardcoded.
- **Failure evidence:** an `.xcresult` is uploaded only after a failed run, for seven days. The workflow uses only official GitHub artifact/checkout actions. They are pinned to documented major tags (`actions/checkout@v4`, `actions/upload-artifact@v4`) because their immutable SHAs cannot be verified locally; this remains a supply-chain review limitation.
- **Explicit non-scope:** the workflow does not run `Scripts/social_v2_postgres_parity_ci.sh`, because its local PostgreSQL/container architecture is not established as compatible with GitHub-hosted macOS. It provisions no secrets, backends, deployments, promotion, provider dependencies, or third-party runtime packages.
- **Evidence status:** local syntax, gate, and resolver checks are recorded below. Hosted execution is pending until this definition is pushed to GitHub and a qualifying workflow run completes.

## Local checks

- Passed: Ruby/Psych parsed `.github/workflows/social-v2-foundation.yml`; `bash -n Scripts/resolve_social_ci_destination.sh`; resolver `--help`; `ruby -c` for the contract and privacy validators; `Scripts/social_v2_contract_ci.sh`; `Scripts/social_v2_privacy_ci.sh`; `Scripts/privacy_no_network_audit.sh Hindsight`; and local `git diff --check`. Hosted range-aware diff behavior remains pending with the workflow run.
- Passed after accessing the per-user CoreSimulator device set outside the restricted workspace
  sandbox: resolver `--dry-run` emitted a valid ID-based iPhone destination, the focused rollout
  suite passed 7/7, and the full shared scheme passed 80/80. These are local results, not a
  hosted-CI pass claim. GitHub-hosted execution remains pending until the workflow is pushed.
