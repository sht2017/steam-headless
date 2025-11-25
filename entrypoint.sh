#!/usr/bin/env bash
set -euo pipefail

if ! pgrep Xvfb >/dev/null 2>&1; then
  Xvfb :0 -screen 0 1280x720x24 &
  sleep 1
fi
exec "$@"
