# F0.3 PostgreSQL parity spike — 2026-07-30

**Lifecycle:** `verification_pending`. This is disposable local PostgreSQL evidence only; it does
not accept ADR-008 or select/operate a backend.

## Scope and safety

- Added only `Backend/Spike/PostgresParity/` and this evidence file. The prior
  `Backend/Spike/Postgres/` spike was not changed.
- `run.sh` discovers the installed Homebrew PostgreSQL 16.13 binary directory with
  `/opt/homebrew/opt/postgresql@16/bin/pg_config --bindir`, refuses a non-Homebrew path, and
  verifies every required binary before use.
- It creates an unpredictable `mktemp` directory, checks its specific name, initializes a new
  cluster, and uses a socket within that directory with `listen_addresses=''`. It does not accept
  or use a shared database/service, a TCP listener, credentials, app code, network, or production
  data. A trap immediately stops the cluster and removes only that validated directory.
- Fixtures contain synthetic environment-prefixed opaque IDs only. The outbox schema deliberately
  has no notification-content field; errors are fixed codes.

## Exact command and redacted result

```sh
Backend/Spike/PostgresParity/run.sh
```

The command exited `0` and produced these result lines (the temporary socket/directory were not
recorded):

```text
BASE_TEST=PASS
PARITY_RESULT=PASS
RACE_FORECAST_AUDIT=1/1
OUTBOX_RECLAIM=PASS
FEED_RECONCILIATION=2
RESTORE_COUNT_CHECKSUM=2:18489366fc3a91181fdd13fa86740141
```

The same run printed `rls_outsider_cannot_read_alpha = 1` and
`rls_member_can_read_alpha = 1`; each is a SQL assertion result, not a record count.

## Verified locally

| Requirement | Result |
|---|---|
| Database RLS read policies plus actor-function authorization | Pass: outsider cannot read the protected group; active member can. Forecast functions reject outsider, removed member, and a `qa:` resource identifier used against the `dev` database. |
| Server-authoritative UTC deadline | Pass: a future client timestamp cannot submit `dev:e_late`; function compares `clock_timestamp()` to the stored UTC deadline. |
| Idempotency | Pass: same key/same canonical payload replays; changed payload is rejected as `IDEMPOTENCY_KEY_REUSED`. |
| True concurrent sessions | Pass: two separate `psql` processes run concurrently against one event/actor. The event-row lock and unique constraint leave exactly one forecast and one audit row (`1/1`). |
| Immutable ledgers | Pass: SQL update/delete attempts on forecast, audit, and resolution rows raise `IMMUTABLE_RECORD`. |
| Generic durable notification retry/reclaim | Pass: committed lock creates an outbox envelope with only topic/resource ID; a claimed row is failed, reclaimed by ID, then acknowledged. |
| Missed ephemeral notification reconciliation | Pass: the member calls durable `reconcile(0)` and receives two authorized change-feed records; delivery transport is not treated as truth. |
| Separate synthetic dev/QA databases | Pass: separate databases are seeded with their own environment-prefixed IDs; cross-environment resource submission rejects `NOT_FOUND`. |
| Logical backup restore | Pass: `pg_dump -Fc`, `pg_restore` to a fresh database, then forecast count/checksum equality: `2:18489366fc3a91181fdd13fa86740141`. |

## Not claimed / still required

- Apple authentication, nonce/audience/signature/expiry/replay checks.
- Supabase RLS, Supabase Broadcast/Realtime, hosted edge/API behavior, or hosted project isolation.
- APNs delivery or provider retry behavior.
- Production backup/recovery objectives, production schema migration strategy, credentials,
  monitoring, or policy gates.

This evidence remains `verification_pending` because those ADR/contract acceptance conditions
remain outside this dependency-free local spike.
