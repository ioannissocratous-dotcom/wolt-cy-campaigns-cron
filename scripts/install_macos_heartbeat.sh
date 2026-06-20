#!/usr/bin/env bash
# Install launchd jobs that ping the pinger repo twice daily (Cyprus time).
# Push → GitHub Actions → snapshot dispatch. Does not rely on GitHub schedule cron.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HEARTBEAT="${ROOT}/scripts/heartbeat.sh"
LABEL="com.wolt.cy-campaign-heartbeat"
PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"
LOG="/tmp/wolt-cy-heartbeat.log"

if [[ ! -x "$HEARTBEAT" ]]; then
  chmod +x "$HEARTBEAT"
fi

if ! command -v gh >/dev/null || ! gh auth status >/dev/null 2>&1; then
  echo "ERROR: gh CLI must be installed and logged in (gh auth login)" >&2
  exit 1
fi

mkdir -p "${HOME}/Library/LaunchAgents"

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>${LABEL}</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>-lc</string>
    <string>${HEARTBEAT} >> ${LOG} 2>&1</string>
  </array>
  <key>StartCalendarInterval</key>
  <array>
    <dict>
      <key>Hour</key><integer>13</integer>
      <key>Minute</key><integer>20</integer>
    </dict>
    <dict>
      <key>Hour</key><integer>15</integer>
      <key>Minute</key><integer>30</integer>
    </dict>
  </array>
  <key>StandardOutPath</key><string>${LOG}</string>
  <key>StandardErrorPath</key><string>${LOG}</string>
</dict>
</plist>
EOF

launchctl bootout "gui/$(id -u)" "$PLIST" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"
launchctl enable "gui/$(id -u)/${LABEL}" 2>/dev/null || true

echo "Installed ${PLIST}"
echo "Runs daily at 13:20 and 15:30 Cyprus time."
echo "Log: ${LOG}"
echo "Test now: ${HEARTBEAT}"
