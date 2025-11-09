#!/usr/bin/env bash
set -euo pipefail

# Run as ncsync if started as root
if [ "$(id -u)" = "0" ]; then
  exec su-exec ncsync:ncsync /usr/local/bin/entrypoint.sh "$@"
fi

NC_URL="${NC_URL:-}"
NC_USER="${NC_USER:-}"
NC_PASS="${NC_PASS:-}"
NC_REMOTE_PATH="${NC_REMOTE_PATH:-/}"
NC_INTERVAL="${NC_INTERVAL:-600}"
NC_ARGS="${NC_ARGS:-}"

if [ -z "$NC_URL" ] || [ -z "$NC_USER" ] || [ -z "$NC_PASS" ]; then
  echo "ERROR: NC_URL, NC_USER and NC_PASS must be set." >&2
  exit 1
fi

LOCAL_DIR="/data"
if [ ! -d "$LOCAL_DIR" ]; then
  echo "ERROR: $LOCAL_DIR does not exist (mount your folder to /data)." >&2
  exit 1
fi

EXCLUDE_OPT=""
if [ -f "/config/exclude" ]; then
  EXCLUDE_OPT="--exclude /config/exclude"
fi

UNSYNCED_OPT=""
if [ -f "/config/unsyncedfolders" ]; then
  UNSYNCED_OPT="--unsyncedfolders /config/unsyncedfolders"
fi

run_once() {
  echo "==> Running nextcloudcmd sync at $(date -Iseconds)"
  # Notes:
  #  - --path selects a remote subfolder (works on recent clients)
  #  - nextcloudcmd does a single pass and exits (we loop if NC_INTERVAL>0)
  nextcloudcmd \
    --non-interactive \
    --trust \
    --user "$NC_USER" \
    --password "$NC_PASS" \
    --path "$NC_REMOTE_PATH" \
    $EXCLUDE_OPT \
    $UNSYNCED_OPT \
    $NC_ARGS \
    "$LOCAL_DIR" \
    "$NC_URL"
}

if [ "$NC_INTERVAL" = "0" ]; then
  run_once
  exit $?
fi

# Periodic loop
while true; do
  run_once || echo "WARN: sync run failed at $(date -Iseconds)"
  sleep "$NC_INTERVAL"
done
