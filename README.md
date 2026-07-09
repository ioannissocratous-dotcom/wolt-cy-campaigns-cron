# Wolt CY campaign cron

Runs daily snapshot → pushes to `boltable/wolt-campaigns-diary` → Boltable deploys.

## How it runs (no Mac needed)

| Layer | What | When |
|-------|------|------|
| **1. Public pinger** | [`wolt-cy-cron-pinger`](https://github.com/ioannissocratous-dotcom/wolt-cy-cron-pinger) scheduled workflow | ~11:00–17:00 Cyprus (5 slots) |
| **2. Boltable heartbeat** | [`wolt-cy-cron-heartbeat`](https://github.com/boltable/wolt-cy-cron-heartbeat) | Retries 08:00–20:00 Cyprus every 15 min |
| **3. Mac heartbeat** (optional) | `./scripts/install_macos_heartbeat.sh` | 13:20 & 15:30 if Mac is on |

The heavy fetch job (`daily-campaign-snapshot.yml`) runs only via `repository_dispatch`. It skips if today's snapshot already exists.

## Manual run

[Run workflow](https://github.com/ioannissocratous-dotcom/wolt-cy-campaigns-cron/actions/workflows/daily-campaign-snapshot.yml)

## Secrets (this repo)

| Secret | Purpose |
|--------|---------|
| `BOLTABLE_REPO_TOKEN` | Push snapshots to boltable repo |
| `WOLT_ACCESS_TOKEN` / `WOLT_REFRESH_TOKEN` | Logged-in carousel |

## Boltable heartbeat token

Portal → `wolt-cy-cron-heartbeat` → Secrets → `GITHUB_DISPATCH_TOKEN` (fine-grained PAT, Actions write on this repo).
