#!/usr/bin/env bash

escape_json() {
    printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g; s/\n/\\n/g'
}

ac_online=$(cat /sys/class/power_supply/AC/online 2>/dev/null || echo "0")
if [[ "$ac_online" -eq 1 ]]; then
    mode="AC"
    cpu_icon=""
else
    mode="BAT"
    cpu_icon=""
fi

heavy=$(ps -eo comm,%cpu --sort=-%cpu --no-headers 2>/dev/null | awk '$2 > 50 {print $1; exit}')
process_info=${heavy:-"Nenhum"}

if [[ -d ~/.cache ]]; then
    cache_size=$(du -sh ~/.cache 2>/dev/null | awk '{print $1}' || echo "N/A")
else
    cache_size="N/A"
fi
{
    pkill -f tracker-miner-fs 2>/dev/null || true
    systemctl --user stop packagekit.service 2>/dev/null || true
    
    if command -v sudo >/dev/null 2>&1; then
        sync 2>/dev/null || true
        echo 3 | sudo tee /proc/sys/vm/drop_caches >/dev/null 2>&1 || true
        
        if [[ "$mode" == "AC" ]]; then
            echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
        else
            echo powersave | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor >/dev/null 2>&1 || true
        fi
    fi
} &

if [[ -n "$heavy" ]]; then
    icon="⚠️"
else
    icon="󰒋"
fi

tooltip="Modo: $mode\\nCache: $cache_size\\nProcesso pesado: $process_info"
printf '{"text":"%s","tooltip":"%s"}\n' "$(escape_json "$icon")" "$(escape_json "$tooltip")"