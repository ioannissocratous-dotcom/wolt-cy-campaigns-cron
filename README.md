# Wolt CY campaign cron

Runs daily on **your personal GitHub Actions** (bypasses boltable org Actions block).

Pushes snapshots to `boltable/wolt-cy-campaigns` → Boltable auto-deploys.

## How it runs (3 layers)

| Layer | Workflow | When |
|-------|----------|------|
| **1. Dispatcher** | `scheduled-dispatcher.yml` | ~13:17–16:00 Cyprus (GitHub schedule) |
| **2. Watchdog** | `missed-snapshot-watchdog.yml` | ~16:15 Cyprus — fails if still missing |
| **3. External backup** | cron-job.org → `repository_dispatch` | 13:20 Cyprus (optional, most reliable) |

The heavy fetch job (`daily-campaign-snapshot.yml`) is **never scheduled directly** — only dispatched, so skipped GitHub crons don't block a clean retry.

## Manual run

https://github.com/ioannissocratous-dotcom/wolt-cy-campaigns-cron/actions/workflows/daily-campaign-snapshot.yml → **Run workflow**

## One-time external backup (recommended)

GitHub sometimes skips **all** scheduled runs on personal repos for a day. An external HTTP ping fixes that.

```bash
# After creating cron-job.org API key + GitHub fine-grained PAT (Actions write on this repo):
CRON_JOB_ORG_API_KEY='...' GITHUB_DISPATCH_PAT='...' ./scripts/setup_external_cron.sh
```

Console: https://console.cron-job.org/

## Secrets (repo Settings → Secrets)

| Secret | Purpose |
|--------|---------|
| `BOLTABLE_REPO_TOKEN` | Push snapshots to boltable repo |
| `WOLT_ACCESS_TOKEN` / `WOLT_REFRESH_TOKEN` | Logged-in carousel |
| `WORKFLOW_TRIGGER_PAT` | Legacy; dispatcher now uses `GITHUB_TOKEN` |
