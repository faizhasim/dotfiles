#!/usr/bin/env zsh

set_workspace_apps_label() {
  local WORKSPACE_NUM
  WORKSPACE_NUM=$(aerospace list-workspaces --focused)

  local APPS
  APPS=$(aerospace list-windows --workspace "$WORKSPACE_NUM" --format "%{app-name}")

  local APPS_ONE_LINE
  APPS_ONE_LINE=$(printf "%s" "$APPS" | paste -sd "," - | sed 's/,/, /g')

  sketchybar --set "$NAME.apps" label="$APPS_ONE_LINE "
}

sketchybar --set "$NAME" label="$(aerospace list-workspaces --focused)"
if [ "$SENDER" = "mouse.entered" ]; then
  set_workspace_apps_label
  sketchybar --set "$NAME" popup.drawing=on
elif [ "$SENDER" = "mouse.exited" ]; then
  sketchybar --set "$NAME" popup.drawing=off
fi

