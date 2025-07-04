#!/usr/bin/env bash
# Show a persistent notification while Caps Lock is on.
# Works on any keyboard that exposes an LED_CAPSL event via evdev.

set -euo pipefail

LOGFILE="${XDG_STATE_HOME:-$HOME/.local/state}/capslock-alert.log"
mkdir -p "$(dirname "$LOGFILE")"
: >"$LOGFILE" # truncate on every start

# Pick the first "…-kbd" device under /dev/input/by-id
keyboard_dev=$(find /dev/input/by-id -type l -name '*-kbd' -exec readlink -f {} \; | head -n1)

if [[ -z $keyboard_dev || ! -e $keyboard_dev ]]; then
    printf '%s ❌ Cannot find keyboard device\n' "$(date)" >>"$LOGFILE"
    exit 1
fi

printf '%s ✅ Monitoring CAPS LOCK on %s\n' "$(date)" "$keyboard_dev" >>"$LOGFILE"

NOTIF_ID=22222 # arbitrary but constant
last_state=off

# We keep the simple "grep-like" filtering that you know works.
evtest "$keyboard_dev" 2>/dev/null | while read -r line; do
    [[ $line != *'EV_LED'* || $line != *'LED_CAPSL'* ]] && continue
    printf '%s RAW: %s\n' "$(date)" "$line" >>"$LOGFILE"

    case $line in
    *'value 1'*)
        if [[ $last_state != on ]]; then
            last_state=on
            notify-send -r "$NOTIF_ID" -u critical "🟥 CAPS LOCK ENABLED"
        fi
        ;;
    *'value 0'*)
        if [[ $last_state != off ]]; then
            last_state=off
            dunstctl close "$NOTIF_ID"
        fi
        ;;
    esac
done
