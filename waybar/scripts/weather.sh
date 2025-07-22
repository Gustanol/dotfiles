#!/bin/bash

CITY="Carapicuíba"
SYMBOLS=("☀️" "⛅" "☁️" "🌧️" "🌩️" "❄️" "🌫️" "❓")

weather=$(curl -sf "https://wttr.in/${CITY}?format=%t" | sed 's/+//')

if [ -z "$weather" ]; then
    echo ""
else
    echo "$weather"
fi
