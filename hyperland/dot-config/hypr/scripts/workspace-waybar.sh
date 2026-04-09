#!/bin/bash
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
TIMER_PID=""

while IFS= read -r line; do
    if [[ "$line" == workspacev2* ]]; then
        if [ -n "$TIMER_PID" ] && kill "$TIMER_PID" 2>/dev/null; then
            ~/.config/hypr/scripts/show-waybar.sh 1 --restart &
        else
            ~/.config/hypr/scripts/show-waybar.sh 1 &
        fi
        TIMER_PID=$!
    fi
done < <(socat -U - UNIX-CONNECT:"$SOCKET")
