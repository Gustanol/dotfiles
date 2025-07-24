#!/usr/bin/env bash

direction="$1"
monitor_data=$(hyprctl monitors -j | sed 's/^[^{]*//')

HIGH_BRIGHTNESS="󰃠"
MID_BRIGHTNESS="󰃟"
LOW_BRIGHTNESS="󰃜"

id=$(printf '%s' "$monitor_data" | jq -r '.[] | select(.focused==true) | .id')
name=$(printf '%s' "$monitor_data" | jq -r '.[] | select(.focused==true) | .name')

if [[ -z "$id" ]]; then
  id=1
fi

if [[ "$name" == eDP-* ]]; then
  # Laptop
  if [[ "$direction" == "+" ]]; then
    brillo -u 150000 -A 5
  else
    brillo -u 150000 -U 5
  fi
  brightness=$(printf "%.0f" "$(brillo -G)")
else
  # Monitor
  ddcutil --display="$id" setvcp 10 "$direction" 5 &>/dev/null
  brightness=$(ddcutil --display="$id" getvcp 10 2>/dev/null | awk -F'current value = ' '{print $2}' | cut -d',' -f1)
fi

if [ "$brightness" -ge 60 ]; then
    ICON="$HIGH_BRIGHTNESS"
elif [ "$brightness" -ge 20 ]; then
    ICON="$MID_BRIGHTNESS"
else
    ICON="$LOW_BRIGHTNESS"
fi

echo "${ICON}${brightness}%"
