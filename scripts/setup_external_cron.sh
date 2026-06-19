#!/usr/bin/env bash
# Register a daily external ping on cron-job.org (backup when GitHub schedule is skipped).
#
# One-time setup:
#   1. Create a free account at https://console.cron-job.org/
#   2. Settings → API key → generate
#   3. GitHub → Settings → Developer settings → Fine-grained PAT
#      - Repository access: ioannissocratous-dotcom/wolt-cy-campaigns-cron only
#      - Permissions: Actions (Read and write), Metadata (Read)
#   4. Run:
#        CRON_JOB_ORG_API_KEY='...' GITHUB_DISPATCH_PAT='...' ./scripts/setup_external_cron.sh
#
set -euo pipefail

API_KEY="${CRON_JOB_ORG_API_KEY:-}"
GITHUB_PAT="${GITHUB_DISPATCH_PAT:-}"
REPO="ioannissocratous-dotcom/wolt-cy-campaigns-cron"
JOB_TITLE="Wolt CY campaign diary daily snapshot"
# 10:20 UTC = 13:20 Cyprus (EEST) — after Wolt carousel refresh window
HOUR=10
MINUTE=20

if [[ -z "$API_KEY" || -z "$GITHUB_PAT" ]]; then
  echo "ERROR: Set CRON_JOB_ORG_API_KEY and GITHUB_DISPATCH_PAT" >&2
  exit 1
fi

PAYLOAD=$(python3 <<PY
import json, os
pat = os.environ["GITHUB_PAT"]
print(json.dumps({
  "job": {
    "title": "${JOB_TITLE}",
    "url": "https://api.github.com/repos/${REPO}/dispatches",
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
      "hours": [${HOUR}],
      "minutes": [${MINUTE}],
      "mdays": [-1],
      "months": [-1],
      "wdays": [-1]
    }
  }
}))
PY
)

echo "Creating cron-job.org daily ping at ${HOUR}:$(printf '%02d' "$MINUTE") UTC…"
RESP=$(curl -sS -X PUT "https://api.cron-job.org/jobs" \
  -H "Authorization: Bearer ${API_KEY}" \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD")

if echo "$RESP" | grep -q '"jobId"'; then
  JOB_ID=$(echo "$RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['jobId'])")
  echo "OK — cron-job.org job #${JOB_ID} created."
  echo "External backup runs daily at ${HOUR}:$(printf '%02d' "$MINUTE") UTC."
else
  echo "ERROR: cron-job.org API response:" >&2
  echo "$RESP" >&2
  exit 1
fi
