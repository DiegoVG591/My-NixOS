#!/usr/bin/env bash 

# --- CONFIGURATION ---
TARGET_SINK="alsa_output.usb-Razer_Razer_Barracuda_X-00.analog-stereo"
APPS=("mpv" "Anki" "Discord" "OBS")
# ---------------------

echo "🎧 Audio Enforcer (DEBUG MODE) Started..."
echo "Targeting Sink: $TARGET_SINK"

pactl subscribe | grep --line-buffered "sink-input" | while read -r line; do
    if echo "$line" | grep -q "new"; then
        
        # 1. Capture the ID
        INPUT_ID=$(echo "$line" | cut -d'#' -f2 | awk '{print $1}')
        
        # 2. Extract the Name (Wait a tiny bit in case PulseAudio lags)
        sleep 0.1
        APP_NAME=$(pactl list sink-inputs | grep -A 20 "Sink Input #$INPUT_ID" | grep "application.name" | cut -d'"' -f2)

        # 3. DEBUG PRINT
        echo "🔎 Saw ID $INPUT_ID. App Name appears to be: ['$APP_NAME']"

        # --- NEW "GHOST BUSTER" LOGIC ---
        # If the name is empty, it means the sound was too fast (Anki/MPV).
        # We assume it's what we want and move it blindly.
        if [[ -z "$APP_NAME" ]]; then
            echo "👻 Ghost Stream detected (Too fast to name). Assuming Anki -> Moving!"
            pactl move-sink-input "$INPUT_ID" "$TARGET_SINK" 2>/dev/null
            continue
        fi
        # --------------------------------

        # 4. Check Match (Your existing logic for slower apps like Spotify)
        for TARGET_APP in "${APPS[@]}"; do
            if [[ "$APP_NAME" == "$TARGET_APP" ]]; then
                echo "⚡ MATCH FOUND! Moving to Headphones..."
                pactl move-sink-input "$INPUT_ID" "$TARGET_SINK"
                break
            fi
        done
    fi
done
