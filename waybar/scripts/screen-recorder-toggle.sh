#!/usr/bin/env bash

OUTPUT_DIR="$HOME/videos/recordings"
mkdir -p "$OUTPUT_DIR"

PID_FILE="/tmp/wf-recorder.pid"

if [ -f "$PID_FILE" ]; then
  PID=$(cat "$PID_FILE")
  if ps -p "$PID" > /dev/null 2>&1; then
    kill "$PID"
    rm "$PID_FILE"
    notify-send "🎬 Recording ended" "Successful!"

    TMP_LAST=$(ls -t "$OUTPUT_DIR"/*.mkv 2> /dev/null | head -n1)
    notify-send "✅ Recording saved" "File at: $OUTPUT_DIR"
    exit 0
  fi
fi

FORMAT=$(printf "mkv\nmp4" | wofi -dmenu -p "Record format:")
[ -z "$FORMAT" ] && exit 1

GEOM=$(slurp)
[ -z "$GEOM" ] && exit 1

BASENAME="record_$(date +'%Y-%m-%d_%H-%M-%S')"
FILE="$OUTPUT_DIR/$BASENAME"

notify-send "🎥 Recording..." "Click again to stop"

case "$FORMAT" in
  mp4)
    wf-recorder -g "$GEOM" -f "$FILE.mp4" &
    ;;
  mkv)
    wf-recorder -g "$GEOM" -f "$FILE.mkv" &
    ;;
  *)
    notify-send "❌ Invalid format!"
    exit 1
    ;;
esac

echo $! > "$PID_FILE"
