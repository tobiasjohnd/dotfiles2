#!/bin/bash
STATE_FILE="/tmp/waybar-visible"

[ -f "$STATE_FILE" ] && ! pgrep -qf show-waybar.sh && rm -f "$STATE_FILE"

if [ -f "$STATE_FILE" ]; then
    menu-scripts
else
    pkill -x -SIGUSR1 waybar
    touch "$STATE_FILE"
    menu-scripts
    pkill -x -SIGUSR1 waybar
    rm -f "$STATE_FILE"
fi
