#!/usr/bin/env bash
# Deletes only the named disposable local spike database after its marker is verified.
set -euo pipefail

SPIKE_DB="hindsight_f03_spike_20260730"
if [[ -n "${PGHOST:-}" || -n "${PGPORT:-}" || -n "${PGSERVICE:-}" || -n "${DATABASE_URL:-}" ]]; then
  echo "Refusing non-default PostgreSQL connection settings." >&2
  exit 64
fi
if [[ "$(psql -X -d postgres -Atqc "select inet_server_addr() is null")" != "t" ]]; then
  echo "Refusing a non-local PostgreSQL server." >&2
  exit 65
fi
exists="$(psql -X -d postgres -Atqc "select exists(select 1 from pg_database where datname = '${SPIKE_DB}')")"
if [[ "$exists" = "f" ]]; then
  echo "SPIKE_CLEANUP=ABSENT"
  exit 0
fi
marker="$(psql -X -d "$SPIKE_DB" -Atqc "select exists(select 1 from information_schema.tables where table_schema = 'hindsight_spike' and table_name = 'spike_marker') and exists(select 1 from hindsight_spike.spike_marker where marker = 'hindsight_f03_postgres_integrity_spike')")"
if [[ "$marker" != "t" ]]; then
  echo "Refusing to delete an unmarked database." >&2
  exit 66
fi
psql -X -d postgres -v ON_ERROR_STOP=1 -qc "alter database ${SPIKE_DB} with allow_connections false"
psql -X -d postgres -v ON_ERROR_STOP=1 -qc "select pg_terminate_backend(pid) from pg_stat_activity where datname = '${SPIKE_DB}' and pid <> pg_backend_pid()"
psql -X -d postgres -v ON_ERROR_STOP=1 -qc "drop database ${SPIKE_DB}"
echo "SPIKE_CLEANUP=REMOVED"
