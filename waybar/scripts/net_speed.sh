#!/bin/bash

error_output() {
    echo "{\"text\": \"Error\", \"tooltip\": \"$1\"}"
    exit 1
}

INTERFACE=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}')
if [ -z "$INTERFACE" ]; then
    error_output "Interface não encontrada"
fi

RX_FILE="/sys/class/net/$INTERFACE/statistics/rx_bytes"
TX_FILE="/sys/class/net/$INTERFACE/statistics/tx_bytes"

if [ ! -r "$RX_FILE" ] || [ ! -r "$TX_FILE" ]; then
    error_output "Não foi possível ler estatísticas da interface $INTERFACE"
fi

RX_CUR=$(cat "$RX_FILE" 2>/dev/null || echo "0")
TX_CUR=$(cat "$TX_FILE" 2>/dev/null || echo "0")

TEMP_FILE="/tmp/waybar_net_speed_$INTERFACE"
if [ -f "$TEMP_FILE" ]; then
    read RX_PREV TX_PREV < "$TEMP_FILE"
else
    RX_PREV=$RX_CUR
    TX_PREV=$TX_CUR
fi

echo "$RX_CUR $TX_CUR" > "$TEMP_FILE"

RX_DIFF=$((RX_CUR - RX_PREV))
TX_DIFF=$((TX_CUR - TX_PREV))

if [ "$RX_DIFF" -lt 0 ]; then RX_DIFF=0; fi
if [ "$TX_DIFF" -lt 0 ]; then TX_DIFF=0; fi

format_speed() {
    local BYTES=$1
    if [ "$BYTES" -ge 1048576 ]; then
        awk "BEGIN {printf \"%.1f MB/s\", $BYTES/1048576}"
    elif [ "$BYTES" -ge 1024 ]; then
        awk "BEGIN {printf \"%.1f kB/s\", $BYTES/1024}"
    else
        echo "${BYTES} B/s"
    fi
}

DOWNLOAD=$(format_speed $RX_DIFF)
UPLOAD=$(format_speed $TX_DIFF)

echo "{\"text\": \"↓$DOWNLOAD\", \"tooltip\": \"Download: $DOWNLOAD\nUpload: ↑$UPLOAD\"}"