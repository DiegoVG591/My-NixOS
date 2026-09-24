#!/usr/bin/env bash
notify-send \
  --urgency=critical \
  --app-name="Meeting Reminder" \
  "⚠️ Meeting in $1 minutes!" \
  "Saturday meeting at 15:00. Click to dismiss." \
  --expire-time=0
