#!/usr/bin/env zsh

case "$1" in
-1)
  xrandr --output HDMI-0 --off
  sleep 1
  ;;

-2)
  xrandr --output HDMI-0 --auto
  sleep 1
  ;;
esac

# bspwm
MONITORS=$(xrandr -q | grep -w connected | wc -l)
if [[ MONITORS -eq 1 ]]; then
  xrandr --output HDMI-0 --off && xrandr --output DP-0 --primary && ~/.fehbg
else
  xrandr --output HDMI-0 --auto && xrandr --output DP-0 --primary --below HDMI-0 && ~/.fehbg
fi
