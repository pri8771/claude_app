# F0.7 hosted CI definition — 2026-07-30

- **Lifecycle:** `verification_pending`.
- **Definition:** `.github/workflows/social-v2-foundation.yml` runs on pull requests targeting `dev` or `qa`, pushes to those branches, and manual dispatch. It has immutable/read-only `contents: read` permissions and cancels superseded runs for the same PR or ref.
- **Validation gates:** tracked JSON syntax, workflow YAML syntax, every tracked shell and Ruby script syntax, range-aware `git diff --check` using the PR base or pre-push commit, Social v2 contract and privacy-payload gates, the current no-network/privacy audit, and a conservative credential-like scan.
- **Apple test gate:** the workflow calls `Scripts/resolve_social_ci_destination.sh`, which queries the selected Xcode's `simctl` JSON for an available iPhone and emits an ID-based destination. The workflow then runs the existing shared `Hindsight` scheme through `Scripts/social_v2_client_ci.sh`; that scheme includes `HindsightTests` and `HindsightUITests` (unit/integration and UI-smoke coverage). No simulator name or UUID is hardcoded.
- **Failure evidence:** an `.xcresult` is uploaded only after a failed run, for seven days. The workflow uses only official GitHub artifact/checkout actions. They are pinned to documented major tags (`actions/checkout@v4`, `actions/upload-artifact@v4`) because their immutable SHAs cannot be verified locally; this remains a supply-chain review limitation.
- **Explicit non-scope:** the workflow does not run `Scripts/social_v2_postgres_parity_ci.sh`, because its local PostgreSQL/container architecture is not established as compatible with GitHub-hosted macOS. It provisions no secrets, backends, deployments, promotion, provider dependencies, or third-party runtime packages.
- **Evidence status:** local checks and the first green qualifying hosted execution are recorded below. Cloud/provider provisioning and rollback evidence remain outside this workflow.

## Local checks

- Passed: Ruby/Psych parsed `.github/workflows/social-v2-foundation.yml`; `bash -n Scripts/resolve_social_ci_destination.sh`; resolver `--help`; `ruby -c` for the contract and privacy validators; `Scripts/social_v2_contract_ci.sh`; `Scripts/social_v2_privacy_ci.sh`; `Scripts/privacy_no_network_audit.sh Hindsight`; and local `git diff --check`.
- Passed after accessing the per-user CoreSimulator device set outside the restricted workspace
  sandbox: resolver `--dry-run` emitted a valid ID-based iPhone destination, the focused rollout
  suite passed 7/7, and the full shared scheme passed 80/80.

## Hosted check

- Green run: [Social v2 foundation run 30591583112](https://github.com/pri8771/hindsight/actions/runs/30591583112), commit `6990e60`, job `91034860572`, completed in 6m48s on 2026-07-30.
- Passed: JSON/YAML/shell/Ruby syntax, range-aware whitespace, contract structure with 2 positive
  and 16 negative fixture expectations, all 13 privacy fixtures, no-network/privacy audit,
  credential-like scan, dynamic ID-based iPhone simulator resolution, and the complete shared
  `Hindsight` Xcode scheme.
- The hosted runner does not provide `rg`; the audit was explicitly corrected to use a recursive
  `grep` fallback instead of silently succeeding when `rg` was absent.
- Two preceding red runs exposed independent UI-smoke timing defects: an obscured Dynamic Type
  selection and text entry before keyboard focus. Both were reproduced with their uploaded
  `.xcresult`, corrected, and passed locally before the green run. CI now retries only a failed
  test once; a repeatable defect still fails the job.
- The green log reports the full shared scheme passed. Because `xcodebuild -quiet` did not print
  an executed-test count, the hosted evidence does not claim the local 80-test count.
