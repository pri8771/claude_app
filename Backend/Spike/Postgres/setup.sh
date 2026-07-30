#!/usr/bin/env bash
# Creates only the exact disposable local database named below. No network host is accepted.
set -euo pipefail

SPIKE_DB="hindsight_f03_spike_20260730"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -n "${PGHOST:-}" || -n "${PGPORT:-}" || -n "${PGSERVICE:-}" || -n "${DATABASE_URL:-}" ]]; then
  echo "Refusing non-default PostgreSQL connection settings." >&2
  exit 64
fi

is_local_socket="$(psql -X -d postgres -Atqc "select inet_server_addr() is null")"
if [[ "$is_local_socket" != "t" ]]; then
  echo "Refusing a non-local PostgreSQL server." >&2
  exit 65
fi

exists="$(psql -X -d postgres -Atqc "select exists(select 1 from pg_database where datname = '${SPIKE_DB}')")"
if [[ "$exists" != "t" ]]; then
  psql -X -d postgres -v ON_ERROR_STOP=1 -qc "create database ${SPIKE_DB}"
else
  marker="$(psql -X -d "$SPIKE_DB" -Atqc "select exists(select 1 from information_schema.tables where table_schema = 'hindsight_spike' and table_name = 'spike_marker') and exists(select 1 from hindsight_spike.spike_marker where marker = 'hindsight_f03_postgres_integrity_spike')")"
  if [[ "$marker" != "t" ]]; then
    echo "Refusing to reuse an existing unmarked database." >&2
    exit 66
  fi
fi

psql -X -d "$SPIKE_DB" -v ON_ERROR_STOP=1 -f "$ROOT_DIR/schema.sql"
echo "SPIKE_SETUP=READY"
