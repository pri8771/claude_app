# F0.3 PostgreSQL parity spike

Run `./run.sh`. It discovers Homebrew PostgreSQL via `pg_config`, starts a private `mktemp`
cluster on a private Unix socket, creates synthetic dev/QA databases, and removes the entire
cluster via a trap. It refuses a non-Homebrew binary path and never reads connection variables.
No hosted service, app credentials, production data, or network listener is used.

The model tests native PostgreSQL RLS/function authorization, not Supabase RLS/Realtime, Apple
authentication, APNs delivery, or hosted-environment isolation.
