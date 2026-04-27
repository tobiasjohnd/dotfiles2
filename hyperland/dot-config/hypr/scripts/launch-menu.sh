#!/bin/bash
FIFO="$XDG_RUNTIME_DIR/waybar-cmd"

echo menu-open > "$FIFO"
trap 'echo menu-close > "$FIFO"' EXIT

menu-scripts
