#!/usr/bin/env bash
# scratchpad.sh <workspace_name> <app_command...>
# Launches the app into the special workspace if it's empty, then toggles it.

WORKSPACE="$1"
APP="$2"

COUNT=$(hyprctl clients -j | jq "[.[] | select(.workspace.name == \"special:$WORKSPACE\")] | length")

if [ "$COUNT" -eq 0 ]; then
    hyprctl dispatch "hl.dsp.exec_cmd('gtk-launch $APP', { workspace = 'special:$WORKSPACE silent' })"
fi

hyprctl dispatch "hl.dsp.workspace.toggle_special('$WORKSPACE')"
