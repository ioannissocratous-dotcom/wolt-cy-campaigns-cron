#!/usr/bin/env bash
# Register cron-job.org to dispatch the snapshot daily (external to GitHub schedule).
#
# 1. https://console.cron-job.org/ → Settings → API key
# 2. GitHub fine-grained PAT → Actions: Read+Write on wolt-cy-campaigns-cron
#
#   CRON_JOB_ORG_API_KEY='...' GITHUB_DISPATCH_PAT='...' ./scripts/setup_external_cron.sh
#
set -euo pipefail

API_KEY="${CRON_JOB_ORG_API_KEY:-}"
GITHUB_PAT="${GITHUB_DISPATCH_PAT:-}"
REPO="ioannissocratous-dotcom/wolt-cy-campaigns-cron"
JOB_TITLE="Wolt CY daily snapshot dispatch"
HOUR=10
MINUTE=22

if [[ -z "$API_KEY" || -z "$GITHUB_PAT" ]]; then
  echo "ERROR: Set CRON_JOB_ORG_API_KEY and GITHUB_DISPATCH_PAT" >&2
  exit 1
fi

PAYLOAD=$(GITHUB_PAT="$GITHUB_PAT" python3 <<'PY'
import json, os
pat = os.environ["GITHUB_PAT"]
print(json.dumps({
  "job": {
    "title": "Wolt CY daily snapshot dispatch",
    "url": "https://api.github.com/repos/ioannissocratous-dotcom/wolt-cy-campaigns-cron/dispatches",
    "enabled": True,
    "saveResponses": True,
    "requestMethod": 1,
    "extendedData": {
      "headers": {
        "Authorization": f"Bearer {pat}",
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/json"
      },
      "body": json.dumps({"event_type": "daily-snapshot"})
    },
    "schedule": {
      "timezone": "UTC",
      "expiresAt": 0,
      "hours": [10],
      "minutes": [22],
      "mdays": [-1],
      "months": [-1],
      "wdays": [-1]
    }
  }
}))
PY
)

echo "Creating cron-job.org dispatch at ${HOUR}:$(printf '%02d' "$MINUTE") UTC…"
RESP=$(curl -sS -X PUT "https://api.cron-job.org/jobs" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

if echo "$RESP" | grep -q '"jobId"'; then
  JOB_ID=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['jobId'])")
  echo "OK — cron-job.org job #${JOB_ID} (13:22 Cyprus in summer)"
else
  echo "ERROR:" >&2
  echo "$RESP" >&2
  exit 1
fi
