#!/usr/bin/env bash
# Set a random wallpaper from ~/wallpapers, the same on every monitor (ported from awesome/wallpaper.lua).
# With "sync", re-apply the current wallpaper to all monitors (e.g. after a hotplug).
dir="$HOME/wallpapers"

pgrep -x hyprpaper >/dev/null || { hyprpaper & sleep 1; }

if [ "$1" = sync ]; then
    wall=$(hyprctl hyprpaper listactive | awk -F': ' 'NF==2 && $2 != "" {print $2; exit}')
fi
[ -z "$wall" ] && wall=$(find "$dir" -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)
[ -z "$wall" ] && exit 1

for mon in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl hyprpaper wallpaper "$mon,$wall"
done
