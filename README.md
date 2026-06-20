# Wolt CY campaign cron

Runs daily snapshot → pushes to `boltable/wolt-cy-campaigns` → Boltable deploys.

## Why not GitHub `schedule`?

GitHub **often skips entire days** of scheduled runs on personal/private repos (no error, zero runs). Do not rely on `on: schedule` alone.

## How it runs (reliable)

| Layer | Mechanism |
|-------|-----------|
| **Mac heartbeat** (recommended) | `scripts/install_macos_heartbeat.sh` — launchd at **13:20** and **15:30 Cyprus** pushes `.last-ping` → [wolt-cy-cron-pinger](https://github.com/ioannissocratous-dotcom/wolt-cy-cron-pinger) → Actions **push trigger** → dispatch snapshot |
| **External cron** (optional, 24/7 cloud) | `scripts/setup_external_cron.sh` + [cron-job.org](https://console.cron-job.org/) |
| **Manual** | [Run workflow](https://github.com/ioannissocratous-dotcom/wolt-cy-campaigns-cron/actions/workflows/daily-campaign-snapshot.yml) |

The fetch job (`daily-campaign-snapshot.yml`) only runs via **dispatch**. If today's JSON already exists, it exits quickly.

## One-time Mac setup

```bash
gh auth login
cd wolt-cy-campaigns-cron   # this repo
chmod +x scripts/*.sh
./scripts/install_macos_heartbeat.sh
./scripts/heartbeat.sh      # test now
```

Log: `/tmp/wolt-cy-heartbeat.log`

## Secrets

| Secret | Purpose |
|--------|---------|
| `BOLTABLE_REPO_TOKEN` | Push to boltable repo |
| `WOLT_ACCESS_TOKEN` / `WOLT_REFRESH_TOKEN` | Logged-in carousel |
| `DISPATCH_PAT` | On pinger repo — dispatches snapshot |
