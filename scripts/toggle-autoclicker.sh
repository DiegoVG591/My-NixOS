#!/usr/bin/env bash

# Auto-clicker toggle script
# - Toggles clicking on/off
# - CPS (clicks per second) stored in /tmp/autoclicker_cps
# - PID stored in /tmp/autoclicker.pid

PID_FILE="/tmp/autoclicker.pid"
CPS_FILE="/tmp/autoclicker_cps"
DEFAULT_CPS=10
MAX_CPS=50

# Initialize CPS file if it doesn't exist
if [[ ! -f "$CPS_FILE" ]]; then
    echo "$DEFAULT_CPS" > "$CPS_FILE"
fi

CPS=$(cat "$CPS_FILE")

# If already running, kill it (toggle off)
if [[ -f "$PID_FILE" ]]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID"
        rm -f "$PID_FILE"
        notify-send "🖱️ Auto-clicker" "OFF" -t 1500
        exit 0
    else
        rm -f "$PID_FILE"
    fi
fi

# Start clicking in background
(
    DELAY=$(echo "scale=4; 1 / $CPS" | bc)
    while true; do
        ydotool click 0xC0
        sleep "$DELAY"
    done
) &

echo $! > "$PID_FILE"
notify-send "🖱️ Auto-clicker" "ON — ${CPS} CPS" -t 1500
