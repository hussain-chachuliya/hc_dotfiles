#!/usr/bin/env bash
# Run a `noctalia msg ...` command and surface failures as a notification.
#
# Why this exists: niri's `spawn-sh` discards the child's stdout and stderr, so
# a failing Noctalia verb is completely invisible -- you press the key and
# nothing happens, with no way to tell a dead keybind from a dead subsystem.
# That is exactly how the missing Bluetooth radio presented: `noctalia msg
# bluetooth-toggle` printed "error: bluetooth state unavailable" and it was
# swallowed whole.
#
# On success this is a transparent pass-through. On failure it pops the error
# and exits non-zero.
#
# Repeat de-duplication: the volume and brightness binds are repeat=true, so a
# held key re-runs this many times per second. Without de-dup, one broken
# subsystem would fire a flood of identical notifications. The same error text
# notifies at most once per NOCTALIA_MSG_COOLDOWN seconds (default 5).
#
# Usage:
#   noctalia-msg.sh bluetooth-toggle
#   noctalia-msg.sh panel-toggle launcher /emo

set -uo pipefail

# Noctalia writes its errors to stdout, not stderr (verified: `noctalia msg
# bluetooth-toggle 2>&1 1>/dev/null` prints nothing). Capture both anyway so
# this keeps working if that ever changes.
output="$(noctalia msg "$@" 2>&1)"
status=$?

# Success: stay out of the way.
if [ "$status" -eq 0 ]; then
	exit 0
fi

# Build a single-line message. Fall back to the exit status if the command
# failed without saying why (e.g. the Noctalia socket is gone entirely).
msg="$(printf '%s' "$output" | tr '\n\t' '  ' | sed 's/[[:space:]]\{1,\}/ /g; s/^ //; s/ $//')"
[ -n "$msg" ] || msg="noctalia msg $* exited with status $status"
msg="${msg:0:300}"

# --- de-duplicate repeated failures from hold-to-repeat binds ---
cooldown="${NOCTALIA_MSG_COOLDOWN:-5}"
state_dir="${XDG_RUNTIME_DIR:-/tmp}/noctalia-msg"
mkdir -p "$state_dir" 2>/dev/null

key="$(printf '%s' "$msg" | md5sum | cut -d' ' -f1)"
stamp="$state_dir/$key"
now="$(date +%s)"

# Prune expired stamps so the state dir cannot grow without bound.
find "$state_dir" -type f -mmin "+$((cooldown / 60 + 1))" -delete 2>/dev/null

if [ -r "$stamp" ]; then
	last="$(cat "$stamp" 2>/dev/null || echo 0)"
	case "$last" in
	'' | *[!0-9]*) last=0 ;;
	esac
	if [ "$((now - last))" -lt "$cooldown" ]; then
		exit "$status"
	fi
fi
printf '%s' "$now" >"$stamp" 2>/dev/null

# --- report it ---
if command -v notify-send >/dev/null 2>&1; then
	notify-send --app-name="Noctalia" --urgency=critical \
		"Noctalia: $* failed" "$msg" 2>/dev/null
else
	# No notification daemon reachable; at least leave it in the journal.
	printf 'noctalia-msg: %s: %s\n' "$*" "$msg" >&2
fi

exit "$status"
