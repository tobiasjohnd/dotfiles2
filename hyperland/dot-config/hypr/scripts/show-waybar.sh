#!/bin/bash
STATE_FILE="/tmp/waybar-visible"
DURATION="${1:?Usage: show-waybar.sh <seconds>}"
RESTART="${2}"

if [ "$RESTART" = "--restart" ]; then
    : # timer was killed and restarted, fall through
elif [ ! -f "$STATE_FILE" ]; then
    pkill -x -SIGUSR1 waybar
    touch "$STATE_FILE"
else
    exit 0  # shown manually, do nothing
fi

sleep "$DURATION"
pkill -x -SIGUSR1 waybar
rm -f "$STATE_FILE"
