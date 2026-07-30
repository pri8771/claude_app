#!/usr/bin/env bash
# Emits a portable xcodebuild destination for an available iPhone simulator.
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: Scripts/resolve_social_ci_destination.sh [--dry-run]

Finds an available iPhone Simulator through simctl and prints an xcodebuild
destination using its runtime UUID. No device name or UUID is hardcoded.

Options:
  --dry-run  Resolve and print the destination without invoking xcodebuild.
  -h, --help Show this help.
USAGE
}

while (($#)); do
  case "$1" in
    --dry-run) shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 64 ;;
  esac
done

command -v xcrun >/dev/null || { echo "error: xcrun is required" >&2; exit 69; }
command -v jq >/dev/null || { echo "error: jq is required" >&2; exit 69; }

# Prefer a booted iPhone to avoid disrupting another simulator, otherwise use
# the first available iPhone reported by the currently selected Xcode.
udid="$(xcrun simctl list devices available -j | jq -r '
  [.devices[] | .[] | select(.isAvailable == true and (.name | startswith("iPhone")))]
  | (map(select(.state == "Booted")) + map(select(.state != "Booted")))
  | .[0].udid // empty
')"

[[ -n "$udid" ]] || {
  echo "error: no available iPhone simulator was found for the selected Xcode" >&2
  exit 69
}

printf 'platform=iOS Simulator,id=%s\n' "$udid"
