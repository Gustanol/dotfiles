#!/bin/bash

VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf "%.0f", $2 * 100}')
MUTED=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED && echo 1 || echo 0)

ICON_MUTED=""
ICON_LOW=""
ICON_HIGH=""

if [ "$MUTED" -eq 1 ]; then
    ICON="$ICON_MUTED"
elif [ "$VOLUME" -lt 30 ]; then
    ICON="$ICON_LOW"
else
    ICON="$ICON_HIGH"
fi

echo "{\"text\": \"$ICON  $VOLUME%\", \"tooltip\": \"Volume: $VOLUME%\"}"
