#!/bin/bash

# Detect the active interface
iface=$(ip route get 1.1.1.1 | awk '{print $5}' | head -n1)

# Private IP
ip=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

# Subnetting mask
cidr=$(ip -4 addr show "$iface" | grep -oP '(?<=inet\s)\d+(\.\d+){3}/\d+' | cut -d/ -f2)

# Default gateway
gateway=$(ip route | grep default | awk '{print $3}')

# SSID (WI-FI)
if [[ "$iface" == "wlan"* ]]; then
  ssid=$(iw dev "$iface" info | grep ssid | awk '{print $2}')
else
  ssid="Cabled conection"
fi

# JSON output
tooltip="Network: $ssid\rInterface: $iface\rMask: /$cidr\rGateway: $gateway"
cat <<EOF
{"text":"$ip","tooltip":"$tooltip"}
EOF

