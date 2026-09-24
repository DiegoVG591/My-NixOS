#!/usr/bin/env bash

# initializing wallpaper demon
# swww init &
# setting wallpaper
# swww img ~/wallpapers/gruvbox-mountain-village.png &

# networl manager applet (network info thingy)
nm-applet --inidicator &

# the bar
waybar &
# dunst
dunst &
# fcitx5
fcitx5 &
# RGB profile
(sleep 3 && openrgb -p purple || notify-send "⚠️ RGB profile failed to apply") &

# Virtual mic links
(sleep 3 && pw-link VirtualMicSink:monitor_0 VirtualMic:playback_0 2>/dev/null) &
(sleep 3 && pw-link VirtualMicSink:monitor_1 VirtualMic:playback_1 2>/dev/null) &
(sleep 4 && pactl set-default-source VirtualMic) &

# Connect bluetooth keyboard
(sleep 5 && ~/mysystem/scripts/ConnectToKnownKeyboard.sh) &
