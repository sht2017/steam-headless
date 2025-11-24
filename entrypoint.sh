#!/usr/bin/env bash
set -euo pipefail

sudo chown root:root /tmp /var/tmp || true
sudo chmod 1777 /tmp /var/tmp || true

sudo mkdir -p /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix


if ! pgrep Xvfb >/dev/null 2>&1; then
  Xvfb :0 -screen 0 800x600x24 &
fi
export DISPLAY=:0

if ! pgrep dbus-daemon >/dev/null 2>&1; then
  DBUS_SESSION_BUS_ADDRESS=$(dbus-daemon --session --fork --print-address)
  export DBUS_SESSION_BUS_ADDRESS
fi

exec "$@"
