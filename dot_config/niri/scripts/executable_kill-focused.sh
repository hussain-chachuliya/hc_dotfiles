#!/usr/bin/env bash
# Force-close the focused window's process.
#
# Port of the Hyprland bind:
#   hl.bind(MOD + SHIFT + Q, hl.dsp.exec_cmd(
#       "hyprctl activewindow | grep pid | tr -d 'pid:' | xargs kill"))
#
# niri's close-window action is a polite protocol-level close. This goes to the
# process directly, for the cases where the client ignores the protocol.

set -uo pipefail

pid="$(niri msg --json focused-window 2>/dev/null |
    sed -n 's/.*"pid":[[:space:]]*\([0-9]\{1,\}\).*/\1/p')"

if [ -z "$pid" ]; then
    exit 0
fi

kill -TERM "$pid" 2>/dev/null || exit 0

# Escalate if the client is still alive after a moment.
for _ in 1 2 3 4 5 6 7 8 9 10; do
    kill -0 "$pid" 2>/dev/null || exit 0
    sleep 0.1
done

kill -KILL "$pid" 2>/dev/null || true
