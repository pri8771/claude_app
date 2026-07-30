# F0.3 local PostgreSQL integrity spike — 2026-07-30

**Status:** `code_complete` for the isolated local PostgreSQL portion only; the backend ADR remains proposed.

## Scope and isolation

- Ran only against PostgreSQL 16.13 over the default local Unix socket (`inet_server_addr() is null`).
- Created a specifically named disposable database, `hindsight_f03_spike_20260730`, with a marker check required before cleanup.
- Used synthetic opaque identifiers and no prediction content, credentials, external account, network host, iOS code, SDK, or dependency.
- Scripts refuse `PGHOST`, `PGPORT`, `PGSERVICE`, and `DATABASE_URL`, then verify the server has no TCP address. Cleanup can delete only the exact marked spike database.
- Setup also refuses to reuse an identically named existing database unless the exact spike marker
  is already present.

## Verified result

After lead-agent review corrected an assertion-state reset and strengthened the existing-database
marker guard, `Backend/Spike/Postgres/setup.sh` and `test.sh` were rerun and completed with exit
status 0.

| Check | Result |
|---|---|
| Active group member may lock before the server deadline | pass |
| Server time is used and supplied client timestamps are ignored | pass |
| Same key/same canonical payload replays the same forecast result | pass |
| Same key/different payload and a second key for the same actor/event reject | pass |
| Lock transaction writes one forecast and one audit event | pass (counts: 1 / 1) |
| Forecast and audit update/delete attempts reject | pass |
| Outsider, removed-member, and late submissions reject | pass |
| Append-only resolution and score-placeholder ledgers reject rewrite | pass (counts: 1 / 1) |
| Test output and application error messages are content-free | pass |

## Explicitly untested

- Sign in with Apple token nonce, audience, signature, expiry, revocation, and replay verification.
- Supabase RLS, Broadcast/Realtime authorization/reconnect behavior, and hosted edge/server function behavior.
- APNs dispatch, retry, and payload privacy.
- Hosted backup/export/restore rehearsal and cross-project development/QA/production isolation.
- Concurrency load/race testing across separate database sessions at the deadline.

## Evidence commands

```sh
Backend/Spike/Postgres/setup.sh
Backend/Spike/Postgres/test.sh
Backend/Spike/Postgres/cleanup.sh
```

The third command was run after validation and reported `SPIKE_CLEANUP=REMOVED`; a direct
`pg_database` query then returned `false` for the spike database.
