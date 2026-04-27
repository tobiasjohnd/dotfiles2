#!/bin/bash
set -u
SOCKET="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"
FIFO="$XDG_RUNTIME_DIR/waybar-cmd"
[ -p "$FIFO" ] || { rm -f "$FIFO"; mkfifo "$FIFO"; }

sticky=0
hide_at=0
menu_open=0

show() { pkill -x -SIGUSR1 waybar; }
hide() { pkill -x -SIGUSR2 waybar; }

socat -U - UNIX-CONNECT:"$SOCKET" | while IFS= read -r ln; do
    [[ "$ln" == workspacev2* ]] && echo ws > "$FIFO"
done &

exec 8<>"$FIFO"

while :; do
    if (( hide_at > 0 )); then
        t=$(( hide_at - $(date +%s) )); (( t < 1 )) && t=1
        read -t "$t" -u 8 cmd || cmd=__timeout__
    else
        read -u 8 cmd || continue
    fi
    case "$cmd" in
        ws)
            (( sticky || menu_open )) || { show; hide_at=$(( $(date +%s) + 1 )); }
            ;;
        toggle)
            (( menu_open )) && continue
            sticky=$(( ! sticky ))
            if (( sticky )); then show; else hide; fi
            hide_at=0
            ;;
        menu-open)
            (( menu_open )) && continue
            menu_open=1
            show
            hide_at=0
            ;;
        menu-close)
            (( menu_open )) || continue
            menu_open=0
            (( sticky )) || hide
            hide_at=0
            ;;
        __timeout__)
            (( sticky || menu_open )) || hide
            hide_at=0
            ;;
    esac
done
