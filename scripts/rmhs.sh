#!/usr/bin/env bash
# rmhs - Remove hyprshot screenshots with optional date filtering
# Usage:
#   rmhs [-v] [-p] [year] [month] [day] [hour] [min]
#   -v → verbose, list files before deleting
#   -p → preview, open files in nsxiv before deleting

SCREENSHOTS_DIR="$HOME/Screenshots"

# --- PARSE FLAGS --- #
VERBOSE=false
PREVIEW=false
while [[ "$1" == -* ]]; do
    case "$1" in
        -v) VERBOSE=true; shift ;;
        -p) PREVIEW=true; shift ;;
        *) echo "Unknown flag: $1"; exit 1 ;;
    esac
done

# --- PARSE ARGS --- #
YEAR=$1
MONTH=$2
DAY=$3
HOUR=$4
MIN=$5

# --- BUILD PATTERN --- #
BASE="$SCREENSHOTS_DIR"

case $# in
    0) PATTERN="$BASE/*/*/*.png" ;;
    1) PATTERN="$BASE/$YEAR/*/*.png" ;;
    2) PATTERN="$BASE/$YEAR/$MONTH/*.png" ;;
    3) PATTERN="$BASE/$YEAR/$MONTH/${YEAR}-${MONTH}-${DAY}-*_hyprshot.png" ;;
    4) PATTERN="$BASE/$YEAR/$MONTH/${YEAR}-${MONTH}-${DAY}-${HOUR}*_hyprshot.png" ;;
    5) PATTERN="$BASE/$YEAR/$MONTH/${YEAR}-${MONTH}-${DAY}-${HOUR}${MIN}*_hyprshot.png" ;;
    *) echo "Usage: rmhs [-v] [-p] [year] [month] [day] [hour] [min]"; exit 1 ;;
esac

# --- FIND FILES --- #
FILES=$(ls $PATTERN 2>/dev/null)

if [ -z "$FILES" ]; then
    echo "No screenshots found matching the criteria."
    exit 0
fi

# --- VERBOSE OUTPUT --- #
if [ "$VERBOSE" = true ]; then
    echo "The following files will be deleted:"
    echo "$FILES"
    echo ""
fi

# --- PREVIEW --- #
if [ "$PREVIEW" = true ]; then
    echo "Mark files to delete with 'm', then press 'q' to quit."
    FILES_TO_DELETE=$(nsxiv -o $PATTERN)
    if [ -z "$FILES_TO_DELETE" ]; then
        echo "No files marked for deletion."
        exit 0
    fi
    echo ""
    read -p "Delete $(echo "$FILES_TO_DELETE" | wc -l) marked files? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo "$FILES_TO_DELETE" | xargs rm
        echo "Done!"
    else
        echo "Aborted."
    fi
    exit 0
fi

# --- CONFIRM --- #
read -p "Are you sure? (y/N): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    rm $PATTERN
    echo "Done!"
else
    echo "Aborted."
fi
