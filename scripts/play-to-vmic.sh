#!/usr/bin/env bash

FILE="${1:-$HOME/vods/Audios/faaaa.mp3}"
VOLUME="${2:-50}"  # Default 50% volume, pass as second arg e.g. play-to-vmic.sh faaaa.mp3 75

if [[ ! -f "$FILE" ]]; then
    notify-send "play-to-vmic" "File not found: $FILE"
    exit 1
fi

# Play to Discord (via VirtualMicSink)
mpv --no-video --ao=pipewire \
    --audio-device=pipewire/VirtualMicSink \
    --volume="$VOLUME" "$FILE" &

# Play to OBS soundboard track
mpv --no-video --ao=pipewire \
    --audio-device=pipewire/SoundboardSink \
    --volume="$VOLUME" "$FILE" &

# Play to your headset
mpv --no-video --ao=pipewire \
    --audio-device=pipewire/alsa_output.usb-Razer_Razer_Barracuda_X-00.analog-stereo \
    --volume="$VOLUME" "$FILE" &
