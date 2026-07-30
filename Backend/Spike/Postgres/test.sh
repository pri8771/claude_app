#!/usr/bin/env bash
# Runs only against the exact local disposable spike database.
set -euo pipefail

SPIKE_DB="hindsight_f03_spike_20260730"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -n "${PGHOST:-}" || -n "${PGPORT:-}" || -n "${PGSERVICE:-}" || -n "${DATABASE_URL:-}" ]]; then
  echo "Refusing non-default PostgreSQL connection settings." >&2
  exit 64
fi
if [[ "$(psql -X -d postgres -Atqc "select inet_server_addr() is null")" != "t" ]]; then
  echo "Refusing a non-local PostgreSQL server." >&2
  exit 65
fi
psql -X -d "$SPIKE_DB" -v ON_ERROR_STOP=1 -f "$ROOT_DIR/test.sql"
