#!/usr/bin/env bash

# --- Variable Setup ---
FILE_PATH="$1"
EXTENSION="${FILE_PATH##*.}"
DIRECTORY=$(dirname "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH" ."$EXTENSION")

# Define the "pause" command as a reusable variable
PAUSE_COMMAND="echo; printf 'Press ENTER twice to close pane... '; read -r _"


# --- Main Logic ---
cd "$DIRECTORY" || exit

case "$EXTENSION" in
    java)
        echo "Compiling and running '$BASENAME.java'..."
        # We now use '-v' for a vertical split and have added the PAUSE_COMMAND
        javac *.java && tmux split-window -v "java '$BASENAME'; $PAUSE_COMMAND"
        ;;
    c)
        echo "Compiling and running '$BASENAME.c'..."
        gcc "$BASENAME.c" -o "$BASENAME" && tmux split-window -v "./'$BASENAME'; $PAUSE_COMMAND"
        ;;
    cpp)
        echo "Compiling and running '$BASENAME.cpp'..."
        g++ "$BASENAME.cpp" -o "$BASENAME" && tmux split-window -v "./'$BASENAME'; $PAUSE_COMMAND"
        ;;
    py)
        echo "Running Python script '$BASENAME.py'..."
        tmux split-window -v "python3 '$BASENAME.py'; $PAUSE_COMMAND"
        ;;
    *)
        echo "Unsupported file type: $EXTENSION"
        sleep 3
        ;;
esac
