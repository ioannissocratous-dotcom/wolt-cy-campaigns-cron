# Wolt CY campaign cron

Runs daily snapshot → pushes to `boltable/wolt-cy-campaigns` → Boltable deploys.

## Cloud scheduler (primary — no Mac needed)

**[boltable/wolt-cy-cron-heartbeat](https://github.com/boltable/wolt-cy-cron-heartbeat)** runs 24/7 on Boltable.

- Checks at **13:20** and **15:30 Cyprus**
- Dispatches this repo's snapshot workflow if today's JSON is missing
- URL: https://wolt-cy-cron-heartbeat.boltable.eu/health

### One-time Portal setup (required)

1. Create a fine-grained GitHub PAT: [Generate token](https://github.com/settings/personal-access-tokens/new)  
   - Repos: `ioannissocratous-dotcom/wolt-cy-campaigns-cron` (Actions: Read+Write), `boltable/wolt-cy-campaigns` (Contents: Read)
2. [Boltable Portal → wolt-cy-cron-heartbeat → Secrets](https://portal.boltable.eu/repos)
3. Add **`GITHUB_DISPATCH_TOKEN`** = paste the PAT → Save

Verify (on VPN):

```bash
curl https://wolt-cy-cron-heartbeat.boltable.eu/health
curl -X POST https://wolt-cy-cron-heartbeat.boltable.eu/trigger   # test dispatch
```

## Why not GitHub `schedule`?

GitHub **often skips entire days** on personal/private repos (zero runs, no error). Do not rely on `on: schedule`.

## Fallback: Mac heartbeat (optional)

If your Mac is on daily:

```bash
./scripts/install_macos_heartbeat.sh
```

## Manual run

[Run workflow](https://github.com/ioannissocratous-dotcom/wolt-cy-campaigns-cron/actions/workflows/daily-campaign-snapshot.yml)

## Secrets (this repo)

| Secret | Purpose |
|--------|---------|
| `BOLTABLE_REPO_TOKEN` | Push snapshots to boltable repo |
| `WOLT_ACCESS_TOKEN` / `WOLT_REFRESH_TOKEN` | Logged-in carousel |
