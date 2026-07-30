#!/usr/bin/env bash
# Runs an isolated, synthetic cluster. It never contacts a shared service.
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PG_CONFIG="$(command -v pg_config || true)"
[[ -n "$PG_CONFIG" && "$PG_CONFIG" == /opt/homebrew/* ]] || { echo 'Homebrew PostgreSQL pg_config required' >&2; exit 69; }
BIN="$($PG_CONFIG --bindir)"; for x in initdb pg_ctl createdb psql pg_dump pg_restore; do [[ -x "$BIN/$x" ]] || { echo "Missing PostgreSQL binary: $x" >&2; exit 69; }; done
TMP_ROOT="$(mktemp -d "${TMPDIR:-/tmp}/hindsight-f03-parity.XXXXXXXX")"; [[ "$TMP_ROOT" == *hindsight-f03-parity.* && -d "$TMP_ROOT" ]] || exit 70
SOCK="$TMP_ROOT/socket"; mkdir "$SOCK"; PORT=$((40000 + ($$ % 10000)))
cleanup(){ "$BIN/pg_ctl" -D "$TMP_ROOT/data" -m immediate stop >/dev/null 2>&1 || true; [[ "$TMP_ROOT" == *hindsight-f03-parity.* ]] && rm -rf "$TMP_ROOT"; }
trap cleanup EXIT INT TERM
"$BIN/initdb" -D "$TMP_ROOT/data" --no-locale --encoding=UTF8 --auth=trust >/dev/null
"$BIN/pg_ctl" -D "$TMP_ROOT/data" -o "-k '$SOCK' -p $PORT -c listen_addresses=''" -w start >/dev/null
pg(){ "$BIN/psql" -X -v ON_ERROR_STOP=1 -h "$SOCK" -p "$PORT" "$@"; }
"$BIN/createdb" -h "$SOCK" -p "$PORT" hindsight_f03_dev; "$BIN/createdb" -h "$SOCK" -p "$PORT" hindsight_f03_qa
for env in dev qa; do pg -d "hindsight_f03_$env" -f "$ROOT_DIR/schema.sql"; pg -d "hindsight_f03_$env" -v environment="$env" -f "$ROOT_DIR/seed.sql"; done
pg -d hindsight_f03_dev -f "$ROOT_DIR/test.sql"
pg -d hindsight_f03_dev -f "$ROOT_DIR/concurrent.sql" >"$TMP_ROOT/a" & a=$!; pg -d hindsight_f03_dev -f "$ROOT_DIR/concurrent.sql" >"$TMP_ROOT/b" & b=$!; wait "$a"; wait "$b"
RACE_COUNT="$(pg -d hindsight_f03_dev -Atqc "select count(*) from parity.forecast where event_id='dev:e_race'")"; AUDIT_COUNT="$(pg -d hindsight_f03_dev -Atqc "select count(*) from parity.audit_ledger a join parity.forecast f using(forecast_id) where f.event_id='dev:e_race'")"; [[ "$RACE_COUNT/$AUDIT_COUNT" == '1/1' ]]
OUTBOX_ID="$(pg -d hindsight_f03_dev -Atqc 'select outbox_id from parity.claim_outbox()')"; pg -d hindsight_f03_dev -qc "select parity.fail_outbox($OUTBOX_ID)"; RECLAIM="$(pg -d hindsight_f03_dev -Atqc 'select outbox_id from parity.claim_outbox()')"; [[ "$OUTBOX_ID" == "$RECLAIM" ]]; pg -d hindsight_f03_dev -qc "select parity.ack_outbox($OUTBOX_ID)"
FEED="$(pg -d hindsight_f03_dev -Atqc "set role api_actor; set app.actor='dev:u_member'; select count(*) from parity.reconcile(0)")"; [[ "$FEED" -ge 2 ]]
"$BIN/pg_dump" -h "$SOCK" -p "$PORT" -Fc -d hindsight_f03_dev -f "$TMP_ROOT/dev.dump"; "$BIN/createdb" -h "$SOCK" -p "$PORT" hindsight_f03_restore; "$BIN/pg_restore" -h "$SOCK" -p "$PORT" -d hindsight_f03_restore "$TMP_ROOT/dev.dump" >/dev/null
SRC="$(pg -d hindsight_f03_dev -Atqc "select count(*)||':'||md5(string_agg(forecast_id||':'||event_id||':'||user_id,',' order by forecast_id)) from parity.forecast")"; DST="$(pg -d hindsight_f03_restore -Atqc "select count(*)||':'||md5(string_agg(forecast_id||':'||event_id||':'||user_id,',' order by forecast_id)) from parity.forecast")"; [[ "$SRC" == "$DST" ]]
printf 'PARITY_RESULT=PASS\nRACE_FORECAST_AUDIT=%s/%s\nOUTBOX_RECLAIM=PASS\nFEED_RECONCILIATION=%s\nRESTORE_COUNT_CHECKSUM=%s\n' "$RACE_COUNT" "$AUDIT_COUNT" "$FEED" "$SRC"
