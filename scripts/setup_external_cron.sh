#!/usr/bin/env bash
# Register cron-job.org to dispatch the daily snapshot (works without Mac or VPN).
#
# One-time setup:
#   1. https://console.cron-job.org/ → sign up → Settings → API key
#   2. GitHub PAT (wolt-cy-heartbeat) → Actions: Read+Write on wolt-cy-campaigns-cron
#
#   CRON_JOB_ORG_API_KEY='...' GITHUB_DISPATCH_PAT='...' ./scripts/setup_external_cron.sh
#
set -euo pipefail

API_KEY="${CRON_JOB_ORG_API_KEY:-}"
GITHUB_PAT="${GITHUB_DISPATCH_PAT:-}"

if [[ -z "$API_KEY" || -z "$GITHUB_PAT" ]]; then
  echo "ERROR: Set CRON_JOB_ORG_API_KEY and GITHUB_DISPATCH_PAT" >&2
  echo "  Get API key: https://console.cron-job.org/settings" >&2
  exit 1
fi

# Cyprus summer (EEST = UTC+3): 13:20 and 15:30 local
SLOTS=(
  "10:20|Wolt CY snapshot 13:20 Cyprus"
  "12:30|Wolt CY snapshot 15:30 Cyprus (backup)"
)

create_job() {
  local hour="$1"
  local minute="$2"
  local title="$3"

  local payload
  payload=$(GITHUB_PAT="$GITHUB_PAT" JOB_TITLE="$title" HOUR="$hour" MINUTE="$minute" python3 <<'PY'
import json, os
pat = os.environ["GITHUB_PAT"]
h = int(os.environ["HOUR"])
m = int(os.environ["MINUTE"])
print(json.dumps({
  "job": {
    "title": os.environ["JOB_TITLE"],
    "url": "https://api.github.com/repos/ioannissocratous-dotcom/wolt-cy-campaigns-cron/dispatches",
    "enabled": True,
    "saveResponses": True,
    "requestMethod": 1,
    "extendedData": {
      "headers": {
        "Authorization": f"Bearer {pat}",
        "Accept": "application/vnd.github+json",
        "Content-Type": "application/json",
        "X-GitHub-Api-Version": "2022-11-28"
      },
      "body": json.dumps({"event_type": "daily-snapshot"})
    },
    "schedule": {
      "timezone": "UTC",
      "expiresAt": 0,
      "hours": [h],
      "minutes": [m],
      "mdays": [-1],
      "months": [-1],
      "wdays": [-1]
    }
  }
}))
PY
)

  echo "Creating cron-job.org: ${title} (${hour}:$(printf '%02d' "$minute") UTC)…"
  local resp
  resp=$(curl -sS -X PUT "https://api.cron-job.org/jobs" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$payload")

  if echo "$resp" | grep -q '"jobId"'; then
    local job_id
    job_id=$(echo "$resp" | python3 -c "import sys,json; print(json.load(sys.stdin)['jobId'])")
    echo "  OK — job #${job_id}"
  else
    echo "  ERROR:" >&2
    echo "$resp" >&2
    return 1
  fi
}

echo "Testing GitHub dispatch PAT…"
test_resp=$(curl -sS -o /dev/null -w "%{http_code}" -X POST \
  "https://api.github.com/repos/ioannissocratous-dotcom/wolt-cy-campaigns-cron/dispatches" \
  -H "Authorization: Bearer ${GITHUB_PAT}" \
  -H "Accept: application/vnd.github+json" \
  -H "Content-Type: application/json" \
  -d '{"event_type":"daily-snapshot"}')
if [[ "$test_resp" != "204" ]]; then
  echo "ERROR: GitHub dispatch returned HTTP ${test_resp} — check your PAT permissions" >&2
  exit 1
fi
echo "  OK — dispatch accepted (204)"

for slot in "${SLOTS[@]}"; do
  IFS='|' read -r utc_time title <<< "$slot"
  IFS=':' read -r hour minute <<< "$utc_time"
  create_job "$hour" "$minute" "$title"
done

echo ""
echo "Done. cron-job.org will trigger the snapshot daily at 13:20 & 15:30 Cyprus."
echo "Check runs: https://github.com/ioannissocratous-dotcom/wolt-cy-campaigns-cron/actions"
