#!/usr/bin/env bash
# Deterministic, local-only preflight for the personal Hindsight release.
# It intentionally does not archive, upload, access credentials, or contact a network service.
set -euo pipefail
IFS=$'\n\t'

usage() {
  cat <<'USAGE'
Usage: Scripts/personal_release_candidate_check.sh

Optional environment:
  SIMULATOR_DESTINATION  xcodebuild destination (default: platform=iOS Simulator,name=iPhone 17 Pro)
  DERIVED_DATA_PATH      isolated DerivedData path (default: /tmp/hindsight-personal-release-candidate-derived-data)

Runs local manifest, privacy, appearance, test-registration, complete unit/UI-test,
and unsigned generic-iOS Release-build checks. It neither uploads nor uses credentials.
USAGE
}

case "${1:-}" in
  "") ;;
  -h|--help) usage; exit 0 ;;
  *) echo "error: unknown argument: $1" >&2; usage >&2; exit 64 ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

simulator_destination="${SIMULATOR_DESTINATION:-platform=iOS Simulator,name=iPhone 17 Pro}"
derived_data_path="${DERIVED_DATA_PATH:-/tmp/hindsight-personal-release-candidate-derived-data}"
project="Hindsight.xcodeproj"
scheme="Hindsight"

require_command() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "error: required command not found: $1" >&2
    exit 69
  }
}

require_file() {
  [[ -f "$1" ]] || {
    echo "error: required release artifact is missing: $1" >&2
    exit 66
  }
}

setting_value() {
  local key="$1"
  awk -F ' = ' -v key="$key" '$1 ~ "^[[:space:]]*" key "$" { print $2; exit }' <<<"$build_settings"
}

require_command plutil
require_command rg
require_command xcodebuild

required_artifacts=(
  ".factory/project-context.json"
  ".factory/standard-lock.json"
  ".factory/AGENTS.factory.md"
  "quality/quality-manifest.json"
  "quality/feature-contracts/build1-testflight.json"
  "quality/feature-contracts/future-postcards-v3-personal-core.json"
  "Docs/ADULT_DECISION_OBSERVATORY_PRODUCT_CONTRACT.md"
  "Docs/RELEASE_CHECKLIST.md"
  "Hindsight-Info.plist"
  "Hindsight/PrivacyInfo.xcprivacy"
  "$project/project.pbxproj"
  "Scripts/privacy_no_network_audit.sh"
)
for artifact in "${required_artifacts[@]}"; do
  require_file "$artifact"
done

plutil -lint Hindsight-Info.plist Hindsight/PrivacyInfo.xcprivacy \
  "$project/project.xcworkspace/xcshareddata/IDEWorkspaceChecks.plist" >/dev/null

echo "Checking privacy boundary..."
Scripts/privacy_no_network_audit.sh Hindsight

echo "Checking system appearance support..."
# A personal-release app must respect the person's light/dark appearance. Keep previews
# honest too, so a forced scheme cannot be accidentally moved into shipping code unnoticed.
forced_appearance_matches="$({
  rg -n --glob '*.swift' \
    '\.(preferredColorScheme[[:space:]]*\(|overrideUserInterfaceStyle)' Hindsight || true
  rg -n -i --glob '*.plist' --glob '*.xcprivacy' 'UIUserInterfaceStyle' Hindsight Hindsight-Info.plist || true
} )"
if [[ -n "$forced_appearance_matches" ]]; then
  echo "error: app code or manifest forces a color scheme:" >&2
  printf '%s\n' "$forced_appearance_matches" >&2
  exit 1
fi

echo "Checking test target registration..."
project_file="$project/project.pbxproj"
for target in HindsightTests HindsightUITests; do
  rg -Fq -- "name = $target;" "$project_file" || {
    echo "error: required test target is not registered: $target" >&2
    exit 1
  }
done

essential_test_sources=(
  "HindsightTests/ClarityScoreTests.swift"
  "HindsightTests/DataLifecycleExportTests.swift"
  "HindsightTests/DemoDataSafetyTests.swift"
  "HindsightTests/HStepperSelectionSemanticsTests.swift"
  "HindsightTests/ModelPersistenceTests.swift"
  "HindsightTests/PersistenceBoundaryTests.swift"
  "HindsightTests/QuickCaptureTests.swift"
  "HindsightTests/ResolutionTests.swift"
  "HindsightTests/SampleDataTests.swift"
  "HindsightTests/SocialV2RolloutPolicyTests.swift"
  "HindsightTests/StatisticsTests.swift"
  "HindsightTests/StoreBootstrapTests.swift"
  "HindsightUITests/HindsightCaptureFlowUITests.swift"
)
for test_source in "${essential_test_sources[@]}"; do
  require_file "$test_source"
  test_name="$(basename "$test_source")"
  rg -Fq -- "/* $test_name in Sources */" "$project_file" || {
    echo "error: essential test source is not registered in an Xcode Sources phase: $test_source" >&2
    exit 1
  }
done

echo "Reading Release identity from Xcode build settings..."
build_settings="$(xcodebuild -project "$project" -target Hindsight -configuration Release -sdk iphoneos -showBuildSettings)"
bundle_identifier="$(setting_value PRODUCT_BUNDLE_IDENTIFIER)"
marketing_version="$(setting_value MARKETING_VERSION)"
build_number="$(setting_value CURRENT_PROJECT_VERSION)"
for identity in bundle_identifier marketing_version build_number; do
  value="${!identity}"
  [[ -n "$value" ]] || {
    echo "error: Release $identity is empty in xcodebuild settings" >&2
    exit 1
  }
done
[[ "$bundle_identifier" == "com.pchordia.hindsight" ]] || {
  echo "error: unexpected Release bundle identifier: $bundle_identifier" >&2
  exit 1
}

echo "Running all HindsightTests and HindsightUITests..."
xcodebuild test -quiet \
  -project "$project" \
  -scheme "$scheme" \
  -destination "$simulator_destination" \
  -derivedDataPath "$derived_data_path" \
  -only-testing:HindsightTests \
  -only-testing:HindsightUITests \
  CODE_SIGNING_ALLOWED=NO

echo "Building unsigned generic-iOS Release product..."
xcodebuild build -quiet \
  -project "$project" \
  -scheme "$scheme" \
  -configuration Release \
  -sdk iphoneos \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=""

printf 'PASS personal release preflight: %s %s (%s); manifests, privacy, appearance, test registration, all tests, and unsigned Release build passed.\n' \
  "$bundle_identifier" "$marketing_version" "$build_number"
