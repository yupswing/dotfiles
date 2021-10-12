#!/usr/bin/env zsh

case "$1" in
-1)
  xrandr --output HDMI-1-0 --off
  sleep 1
  ;;

-2)
  xrandr --output HDMI-1-0 --auto
  sleep 1
  ;;
esac

# bspwm
MONITORS=$(xrandr -q | grep -w connected | wc -l)
if [[ MONITORS -eq 1 ]]; then
  xrandr --output HDMI-1-0 --off && xrandr --output eDP-1 --primary && ~/.fehbg
else
  xrandr --output HDMI-1-0 --auto && xrandr --output eDP-1 --primary --below HDMI-1-0 && ~/.fehbg
fi
