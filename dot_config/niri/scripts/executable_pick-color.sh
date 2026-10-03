#!/usr/bin/env bash
# Pick a colour from the screen and copy it to the clipboard.
#
# Port of the Hyprland bind:
#   hl.bind(MOD + P, hl.dsp.exec_cmd("hyprpicker -a -n"))
#
# hyprpicker is Hyprland-only. niri ships its own picker (`niri msg pick-color`)
# which prints the colour but, unlike `hyprpicker -a`, does not copy it. This
# wrapper bridges the gap.
#
# Requires: wl-clipboard (for wl-copy)

set -uo pipefail

output="$(niri msg pick-color 2>/dev/null)" || exit 0

hex="$(printf '%s\n' "$output" | sed -n 's/^Hex: \(#[0-9a-fA-F]\{6\}\)$/\1/p')"

if [ -n "$hex" ] && command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$hex" | wl-copy
  printf 'Copied %s to clipboard\n' "$hex"
fi

printf '%s\n' "$output"
