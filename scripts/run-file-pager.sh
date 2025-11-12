#!/usr/bin/env bash 

# --- Variable Setup ---
FILE_PATH="$1"
EXTENSION="${FILE_PATH##*.}"
DIRECTORY=$(dirname "$FILE_PATH")
BASENAME=$(basename "$FILE_PATH" ."$EXTENSION")

# Define the "pause" command as a reusable variable
PAUSE_COMMAND="echo; printf 'Press ENTER to close pane... '; read -r _"

# --- Main Logic ---
cd "$DIRECTORY" || exit

case "$EXTENSION" in
    java)
        echo "Compiling and running '$BASENAME.java'..."
        # Pipe the output of the 'java' command into 'less'
        # The -R flag allows 'less' to render colors correctly.
        javac *.java && tmux split-window -v "(java '$BASENAME') | less -R; $PAUSE_COMMAND"
        ;;
    c)
        echo "Compiling and running '$BASENAME.c'..."
        # Pipe the output of the compiled program into 'less'
        gcc "$BASENAME.c" -o "$BASENAME" && tmux split-window -v "(./'$BASENAME') | less -R; $PAUSE_COMMAND"
        ;;
    cpp)
        echo "Compiling and running '$BASENAME.cpp'..."
        # Pipe the output of the compiled program into 'less'
        g++ "$BASENAME.cpp" -o "$BASENAME" && tmux split-window -v "(./'$BASENAME') | less -R; $PAUSE_COMMAND"
        ;;
    py)
        echo "Running Python script '$BASENAME.py'..."
        # Pipe the output of the python script into 'less'
        tmux split-window -v "(python3 '$BASENAME.py') | less -R; $PAUSE_COMMAND"
        ;;
    *)
        echo "Unsupported file type: $EXTENSION"
        sleep 3
        ;;
esac
