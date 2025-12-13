#!/bin/sh

xset r rate 200 50
feh --bg-scale ~/images/static/wallpaper.jpg &

/usr/local/bin/slstatus &

exec dwm
