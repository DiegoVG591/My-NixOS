#!/usr/bin/env bash

# 1. Define the custom path.
#    Use $HOME instead of ~ in scripts for better reliability.
custoPath="$HOME/My Project/Asets/test.cs"

# 2. Echo the path for verification.
echo "Path to open: $custoPath"

# 3. Sleep for 7 seconds as requested.
echo "Sleeping for 7 seconds..."
sleep 7

# 4. Execute the command to open a new terminal.
#    The quotes here are essential for passing the path with spaces correctly.
ghostty -e "bash -c 'nvim \"$custoPath\"; exec zsh'"
