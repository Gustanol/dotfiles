#!/bin/sh

xset r rate 200 50
feh --bg-scale ~/images/static/wallpaper.jpg &

~/projects/dotfiles/slstatus/slstatus &

exec dwm
