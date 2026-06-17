#!/usr/bin/env bash
# External backup trigger (e.g. cron-job.org daily at 13:20 Asia/Nicosia).
# Needs a GitHub PAT with repo + workflow scope on wolt-cy-campaigns-cron.
set -euo pipefail

TOKEN="${WORKFLOW_TRIGGER_PAT:-${GITHUB_TOKEN:-}}"
if [ -z "$TOKEN" ]; then
  echo "Set WORKFLOW_TRIGGER_PAT or GITHUB_TOKEN" >&2
  exit 1
fi

curl -sf -X POST \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/ioannissocratous-dotcom/wolt-cy-campaigns-cron/dispatches \
  -d '{"event_type":"daily-snapshot"}'

echo "Triggered repository_dispatch daily-snapshot"
