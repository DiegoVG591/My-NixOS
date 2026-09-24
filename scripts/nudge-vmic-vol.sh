#!/usr/bin/env bash

# Nudges VirtualMicSink volume up or down, clamped at 150% to avoid distortion
# Usage: nudge-vmic-vol.sh +5%   or   nudge-vmic-vol.sh -5%

MAX_VOL=150  # clamp ceiling in percent
STEP="${1:-+5%}"
SOURCE="VirtualMicSink"

# Get current volume as a plain integer (e.g. 100)
CURRENT=$(pactl get-source-volume "$SOURCE" 2>/dev/null \
  | grep -oP '\d+(?=%)' | head -1)

if [[ -z "$CURRENT" ]]; then
    # fallback: try as sink instead of source
    CURRENT=$(pactl get-sink-volume "$SOURCE" 2>/dev/null \
      | grep -oP '\d+(?=%)' | head -1)
    MODE="sink"
else
    MODE="source"
fi

if [[ -z "$CURRENT" ]]; then
    notify-send "nudge-vmic-vol" "Could not find $SOURCE"
    exit 1
fi

# Calculate new volume
# Use parameter expansion instead of tr to avoid range issues
STEP_NUM="${STEP//[+\-%]/}"
if [[ "$STEP" == -* ]]; then
    NEW_VOL=$(( CURRENT - STEP_NUM ))
else
    NEW_VOL=$(( CURRENT + STEP_NUM ))
fi

# Clamp between 0 and MAX_VOL
if (( NEW_VOL > MAX_VOL )); then NEW_VOL=$MAX_VOL; fi
if (( NEW_VOL < 0 )); then NEW_VOL=0; fi

# Apply
if [[ "$MODE" == "sink" ]]; then
    pactl set-sink-volume "$SOURCE" "${NEW_VOL}%"
else
    pactl set-source-volume "$SOURCE" "${NEW_VOL}%"
fi

notify-send "🎤 VirtualMic Volume" "${NEW_VOL}%" -t 1000
