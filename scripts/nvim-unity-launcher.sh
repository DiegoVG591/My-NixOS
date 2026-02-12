#!/usr/bin/env bash

# 1. Grab the file path Unity sends
FILEPATH="$1"

# Exit if no file path is provided.
if [ -z "$FILEPATH" ]; then
    echo "Error: No file path provided by Unity."
    exit 1
fi

# 2. CRITICAL FIX: Find the Project Root
# This strips the path at "/Assets", giving us the actual project folder.
# Example: /home/user/Game/Assets/Script.cs -> /home/user/Game
PROJECT_PATH="${FILEPATH%%/Assets*}"

# 3. Launch Ghostty
# --working-directory: Forces nvim to launch in the Project Root (Fixes the Sync Plugin)
# -e: Executes nvim directly.
ghostty --working-directory="$PROJECT_PATH" -e nvim "$FILEPATH"
