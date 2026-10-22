#!/usr/bin/env bash
# Set a random wallpaper from ~/wallpapers on every monitor (ported from awesome/wallpaper.lua).
dir="$HOME/wallpapers"

pgrep -x hyprpaper >/dev/null || { hyprpaper & sleep 1; }

wall=$(find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
[ -z "$wall" ] && exit 1

for mon in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl hyprpaper wallpaper "$mon,$wall"
done
