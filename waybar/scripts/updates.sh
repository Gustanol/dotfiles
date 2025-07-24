#!/bin/bash

arch_updates=$(checkupdates 2>/dev/null | wc -l)
aur_updates=$(yay -Qua 2>/dev/null | wc -l)
total=$((arch_updates + aur_updates))

if [[ $total -gt 50 ]]; then 
    info=" 50+"
elif [[ $total -gt 0 ]]; then
    info=" $total"
else
    info=""
fi

tooltip="Arch: $arch_updates\nAUR: $aur_updates"

cat <<EOF
{"text":"$info","tooltip":"$tooltip"}
EOF