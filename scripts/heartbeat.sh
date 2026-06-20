#!/usr/bin/env bash
# Daily heartbeat — updates public pinger repo → push triggers snapshot dispatch.
# GitHub schedule cron is unreliable; push triggers are not.
set -euo pipefail

REPO="ioannissocratous-dotcom/wolt-cy-cron-pinger"
FILE=".last-ping"
TS=$(TZ=Asia/Nicosia date +%Y-%m-%dT%H:%M:%S%z)
CONTENT_B64=$(printf '%s' "$TS" | base64 | tr -d '\n')

SHA=""
if SHA=$(gh api "repos/${REPO}/contents/${FILE}" --jq .sha 2>/dev/null); then
  :
else
  SHA=""
fi

ARGS=(
  --method PUT
  "repos/${REPO}/contents/${FILE}"
  -f "message=heartbeat ${TS}"
  -f "content=${CONTENT_B64}"
)
if [[ -n "$SHA" ]]; then
  ARGS+=(-f "sha=${SHA}")
fi

gh api "${ARGS[@]}"
echo "Heartbeat pushed (${TS}) — pinger workflow should dispatch snapshot."
