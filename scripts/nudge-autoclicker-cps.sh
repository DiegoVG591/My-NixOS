#!/usr/bin/env bash

# Nudge auto-clicker CPS up or down
# Usage: nudge-autoclicker-cps.sh +5   or   nudge-autoclicker-cps.sh -5

CPS_FILE="/tmp/autoclicker_cps"
PID_FILE="/tmp/autoclicker.pid"
DEFAULT_CPS=10
MAX_CPS=50
MIN_CPS=1

STEP="${1:-+5}"

# Initialize if needed
if [[ ! -f "$CPS_FILE" ]]; then
    echo "$DEFAULT_CPS" > "$CPS_FILE"
fi

CURRENT=$(cat "$CPS_FILE")
STEP_NUM="${STEP//[+\-]/}"

if [[ "$STEP" == -* ]]; then
    NEW_CPS=$(( CURRENT - STEP_NUM ))
else
    NEW_CPS=$(( CURRENT + STEP_NUM ))
fi

# Clamp
if (( NEW_CPS > MAX_CPS )); then NEW_CPS=$MAX_CPS; fi
if (( NEW_CPS < MIN_CPS )); then NEW_CPS=$MIN_CPS; fi

echo "$NEW_CPS" > "$CPS_FILE"
notify-send "🖱️ Auto-clicker CPS" "${NEW_CPS} CPS" -t 1000

# If currently running, restart with new CPS
if [[ -f "$PID_FILE" ]]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm -f "$PID_FILE"
        (
            DELAY=$(echo "scale=4; 1 / $NEW_CPS" | bc)
            while true; do
                ydotool click 0xC0
                sleep "$DELAY"
            done
        ) &
        echo $! > "$PID_FILE"
    fi
fi
