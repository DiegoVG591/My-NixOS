#!/usr/bin/env bash

# initializing wallpaper demon
swww init &
# setting wallpaper
swww img ~/wallpapers/gruvbox-mountain-village.png &

# networl manager applet (network info thingy)
nm-applet --inidicator &

# the bar
waybar &

# dunst
dunst
