# Before you leave — 5-minute setup (no Mac needed)

Right now the diary only updates when **your Mac is on** (launchd heartbeat).
Do this once before you go — then it runs in the cloud every day.

## Step 1 — cron-job.org account (2 min)

1. Open https://console.cron-job.org/signup
2. Sign up (free) and confirm your email
3. Go to **Settings** → copy your **API key**

## Step 2 — Run the setup script (1 min)

In Terminal, paste (replace the two `...` values):

```bash
cd ~/wolt-cy-campaigns-cron   # or wherever you cloned it
CRON_JOB_ORG_API_KEY='paste-api-key-here' \
GITHUB_DISPATCH_PAT='paste-github_pat-token-here' \
./scripts/setup_external_cron.sh
```

**GITHUB_DISPATCH_PAT** = your `wolt-cy-heartbeat` token from GitHub  
(https://github.com/settings/personal-access-tokens — create a new one if you lost it)

Permissions needed: **Actions: Read+Write** on `wolt-cy-campaigns-cron` only.

You should see `OK — job #...` twice (13:20 and 15:30 Cyprus).

## Step 3 — Verify (optional)

```bash
curl -sS -X POST \
  -H "Authorization: Bearer YOUR_GITHUB_PAT" \
  -H "Accept: application/vnd.github+json" \
  -d '{"event_type":"daily-snapshot"}' \
  https://api.github.com/repos/ioannissocratous-dotcom/wolt-cy-campaigns-cron/dispatches
```

No output + exit 0 = success. Then check:
https://github.com/ioannissocratous-dotcom/wolt-cy-campaigns-cron/actions

---

## Optional backup — Boltable cloud app

If you also paste the same GitHub token in Boltable Portal:

1. NetBird VPN on
2. https://portal.boltable.eu/repos → **wolt-cy-cron-heartbeat** → **Secrets**
3. `GITHUB_DISPATCH_TOKEN` = same GitHub PAT → Save

---

## What runs each day

| Time (Cyprus) | What triggers it |
|---------------|------------------|
| ~13:20 | cron-job.org → GitHub Actions |
| ~15:30 | cron-job.org backup (skips if snapshot exists) |

Site: https://wolt-campaigns-diary.boltable.eu

## Recent snapshot log

Check `snapshots/` in https://github.com/boltable/wolt-campaigns-diary

If a day is missing, manual run:
https://github.com/ioannissocratous-dotcom/wolt-cy-campaigns-cron/actions/workflows/daily-campaign-snapshot.yml → **Run workflow**
