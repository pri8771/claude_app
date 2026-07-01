#!/usr/bin/env bash
#
# Fails if the app source appears to introduce networking, tracking, or
# third-party analytics symbols. Keep this intentionally conservative.
#
set -euo pipefail

ROOT="${1:-Hindsight}"

patterns=(
  'URLSession'
  'URLRequest'
  'NWConnection'
  'NWPathMonitor'
  'Network\.framework'
  'WKWebView'
  'SFSafariViewController'
  'Firebase'
  'Supabase'
  'Analytics'
  'Crashlytics'
  'Amplitude'
  'Mixpanel'
  'Segment'
  'AppTrackingTransparency'
  'http://'
  'https://'
)

found=0
for pattern in "${patterns[@]}"; do
  if rg -n --glob '*.swift' --glob 'Package.swift' "$pattern" "$ROOT"; then
    found=1
  fi
done

if [[ "$found" -ne 0 ]]; then
  echo "privacy audit failed: review the matches above before claiming no networking/tracking" >&2
  exit 1
fi

echo "privacy audit passed: no networking/tracking symbols found in $ROOT"
