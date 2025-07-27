#!/usr/bin/env bash

# This script acts as a bridge between Unity and your terminal editor.

# Exit if no file path is provided by Unity.
if [ -z "$1" ]; then
    echo "Was not able to open ghostty properly"
    exit 1
fi

# The main command. We've added the echo and sleep commands before nvim.
# - The file path from Unity is the first argument ($1).
# - We sleep for 7 seconds.
# - "$@" passes all arguments from Unity (file, line, etc.) to nvim.
ghostty -e "nvim '$1'; exec zsh"
