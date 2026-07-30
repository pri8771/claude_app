#!/usr/bin/env bash
# Validate a filled, non-secret Social v2 environment manifest before promotion.
# This deliberately rejects the checked-in example template and must run on CI/release hosts.
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'USAGE'
Usage: Scripts/validate_social_environment.sh --manifest PATH --branch REF [--allow-localhost]

Validates JSON syntax, mandatory fields, environment/ref/bundle/APNs mapping, HTTPS endpoints,
non-placeholder values, prohibited secret fields, and obvious cross-environment values. The
manifest is metadata only: pass credentials through the deployment platform's secret store, never
through this file or command line. --allow-localhost is only for a development local manifest.
USAGE
}

manifest=""
branch=""
allow_localhost=0
while (($#)); do
  case "$1" in
    --manifest) manifest="${2:-}"; shift 2 ;;
    --branch) branch="${2:-}"; shift 2 ;;
    --allow-localhost) allow_localhost=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 64 ;;
  esac
done

fail() { echo "environment validation failed: $*" >&2; exit 1; }
[[ -n "$manifest" && -n "$branch" ]] || { usage >&2; exit 64; }
[[ -f "$manifest" ]] || fail "manifest does not exist: $manifest"
command -v jq >/dev/null 2>&1 || fail "jq is required"
jq -e . "$manifest" >/dev/null || fail "invalid JSON"

required_paths=(
  '.manifest_version' '.environment_id' '.git_ref'
  '.backend.project_id' '.backend.region' '.backend.api_base_url' '.backend.auth_issuer_url'
  '.backend.realtime_host' '.backend.database_schema_version' '.backend.api_contract_version'
  '.backend.scoring_version' '.ios.bundle_id' '.ios.app_id' '.ios.apns_topic'
  '.storage.bucket_id' '.storage.host' '.domains.web_host' '.domains.universal_link_host'
  '.feature_flags.configuration_version' '.observability.telemetry_schema_version'
  '.observability.slo_policy_version' '.observability.alert_policy_version'
  '.promotion.client_build_number' '.promotion.backend_release_id'
  '.promotion.migration_plan_version' '.promotion.approval_record'
)
for path in "${required_paths[@]}"; do
  value="$(jq -er "$path" "$manifest")" || fail "missing required field $path"
  [[ -n "$value" && "$value" != "null" ]] || fail "empty required field $path"
done

# Credentials must never be serialized in a promotion manifest, even under an unfamiliar key.
if jq -e 'paths(scalars) as $p | ($p | map(tostring | ascii_downcase) | join(".")) | test("secret|password|token|private_key|apikey|api_key|credential")' "$manifest" >/dev/null; then
  fail "manifest contains a prohibited secret-like field name"
fi
if jq -e '.. | strings | select(test("REPLACE_WITH|<[^>]+>|changeme|example\\.com"; "i"))' "$manifest" >/dev/null; then
  fail "manifest still contains a placeholder/example value"
fi

environment="$(jq -r '.environment_id' "$manifest")"
git_ref="$(jq -r '.git_ref' "$manifest")"
bundle_id="$(jq -r '.ios.bundle_id' "$manifest")"
apns_topic="$(jq -r '.ios.apns_topic' "$manifest")"
case "$environment" in
  development)
    [[ "$git_ref" == "dev" && "$branch" == "dev" ]] || fail "development requires git_ref and --branch dev"
    [[ "$bundle_id" == *.dev ]] || fail "development bundle_id must end in .dev"
    ;;
  qa)
    [[ "$git_ref" == "qa" && "$branch" == "qa" ]] || fail "qa requires git_ref and --branch qa"
    [[ "$bundle_id" == *.qa ]] || fail "qa bundle_id must end in .qa"
    ;;
  production)
    [[ "$git_ref" == refs/tags/v* && "$branch" == "$git_ref" ]] || fail "production requires an immutable refs/tags/v* ref"
    [[ "$bundle_id" != *.dev && "$bundle_id" != *.qa ]] || fail "production bundle_id must not use a dev/qa suffix"
    ;;
  *) fail "environment_id must be development, qa, or production" ;;
esac
[[ "$apns_topic" == "$bundle_id" ]] || fail "APNs topic must equal the iOS bundle ID"

endpoints=()
while IFS= read -r endpoint; do
  endpoints+=("$endpoint")
done < <(jq -r '.backend.api_base_url, .backend.auth_issuer_url, .backend.realtime_host, .storage.host, .domains.web_host, .domains.universal_link_host' "$manifest")
for endpoint in "${endpoints[@]}"; do
  if [[ "$endpoint" == http://localhost* || "$endpoint" == http://127.0.0.1* || "$endpoint" == https://localhost* || "$endpoint" == https://127.0.0.1* ]]; then
    [[ "$environment" == "development" && "$allow_localhost" -eq 1 ]] || fail "localhost endpoint is only allowed for development with --allow-localhost"
  elif [[ "$endpoint" != https://* ]]; then
    fail "endpoint must use HTTPS: $endpoint"
  fi
done

# Environment labels must not appear in foreign service IDs/hosts; this catches most copy/paste mistakes.
all_values="$(jq -r '.. | strings' "$manifest" | tr '[:upper:]' '[:lower:]')"
case "$environment" in
  development) [[ "$all_values" != *".qa"* && "$all_values" != *"-qa"* && "$all_values" != *"production"* ]] || fail "development manifest contains QA/production marker" ;;
  qa) [[ "$all_values" != *".dev"* && "$all_values" != *"-dev"* && "$all_values" != *"production"* ]] || fail "QA manifest contains development/production marker" ;;
  production) [[ "$all_values" != *".dev"* && "$all_values" != *"-dev"* && "$all_values" != *".qa"* && "$all_values" != *"-qa"* ]] || fail "production manifest contains development/QA marker" ;;
esac

for flag in social_read_enabled social_write_enabled private_sync_opt_in_enabled migration_start_enabled background_sync_enabled; do
  jq -e ".feature_flags.${flag} | type == \"boolean\"" "$manifest" >/dev/null || fail "feature flag $flag must be boolean"
done
jq -e '.observability.content_logging_permitted == false' "$manifest" >/dev/null || fail "content logging must remain false"

echo "environment validation passed: $environment ($git_ref), bundle $bundle_id"
