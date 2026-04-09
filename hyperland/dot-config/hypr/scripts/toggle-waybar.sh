#!/bin/bash
STATE_FILE="/tmp/waybar-visible"

if [ -f "$STATE_FILE" ]; then
    pkill -x -SIGUSR1 waybar
    rm -f "$STATE_FILE"
else
    pkill -x -SIGUSR1 waybar
    touch "$STATE_FILE"
fi
