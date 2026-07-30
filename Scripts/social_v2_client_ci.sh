#!/usr/bin/env bash
# Deterministic local/CI gate for the current iOS client and Social v2 delivery metadata.
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'USAGE'
Usage: Scripts/social_v2_client_ci.sh --destination DESTINATION [options]

Required:
  --destination DESTINATION  xcodebuild destination, e.g. platform=iOS Simulator,id=UUID

Options:
  --derived-data PATH        DerivedData location (default: /tmp/hindsight-social-v2-derived-data)
  --result-bundle PATH       Result bundle location (default: /tmp/hindsight-social-v2-tests.xcresult)
  --manifest PATH            Filled Social v2 manifest to validate before tests
  --branch REF               Git ref used with --manifest (defaults to current branch)
  --allow-localhost          Permit local endpoints for a development manifest only
  --skip-xcode               Run repository/manifest gates only (not a release gate)
  -h, --help                 Show this help

The script adds no dependencies. It runs diff/JSON/privacy gates and the shared Hindsight scheme,
which includes unit and UI tests. A real simulator destination is mandatory unless --skip-xcode is
used. Do not pass credentials as arguments.
USAGE
}

destination=""
derived_data="/tmp/hindsight-social-v2-derived-data"
result_bundle="/tmp/hindsight-social-v2-tests.xcresult"
manifest=""
branch="$(git branch --show-current 2>/dev/null || true)"
allow_localhost=0
skip_xcode=0
while (($#)); do
  case "$1" in
    --destination) destination="${2:-}"; shift 2 ;;
    --derived-data) derived_data="${2:-}"; shift 2 ;;
    --result-bundle) result_bundle="${2:-}"; shift 2 ;;
    --manifest) manifest="${2:-}"; shift 2 ;;
    --branch) branch="${2:-}"; shift 2 ;;
    --allow-localhost) allow_localhost=1; shift ;;
    --skip-xcode) skip_xcode=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 64 ;;
  esac
done

[[ -n "$branch" ]] || { echo "error: supply --branch when HEAD is detached" >&2; exit 64; }
if [[ "$skip_xcode" -eq 0 && -z "$destination" ]]; then
  echo "error: --destination is required unless --skip-xcode is used" >&2; exit 64
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo_root"

git diff --check
jq -e . Config/SocialV2/environment-manifest.example.json >/dev/null
Scripts/privacy_no_network_audit.sh Hindsight
if [[ -n "$manifest" ]]; then
  validation_args=(--manifest "$manifest" --branch "$branch")
  [[ "$allow_localhost" -eq 1 ]] && validation_args+=(--allow-localhost)
  Scripts/validate_social_environment.sh "${validation_args[@]}"
fi

if [[ "$skip_xcode" -eq 1 ]]; then
  echo "client CI repository gates passed; Xcode tests intentionally skipped"
  exit 0
fi

xcodebuild test -quiet \
  -project Hindsight.xcodeproj \
  -scheme Hindsight \
  -destination "$destination" \
  -derivedDataPath "$derived_data" \
  -resultBundlePath "$result_bundle" \
  -retry-tests-on-failure \
  -test-iterations 2 \
  CODE_SIGNING_ALLOWED=NO
echo "client CI passed; result bundle: $result_bundle"
