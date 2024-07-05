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

# Acer Nitro
#MONITOR1=DP-0
#MONITOR2=HDMI-0
# Acer ZenBook
MONITOR1=eDP-1
MONITOR2=HDMI-1-0

if [[ MONITORS -eq 1 ]]; then
  xrandr --output $MONITOR2 --off && xrandr --output $MONITOR1 --primary && ~/.fehbg
else
# RESOLUTION=$(xrandr | grep -A1 "HDMI-1-0" | tail -n1 | awk '{ print $1 }')
  # aggiunto il rate perche a casa si settava su 144 e non visualizzava nulla
  # xrandr --output $MONITOR2 --auto &&
  #   xrandr --output $MONITOR2 --mode $RESOLUTION --rate 60 &&
  #   xrandr --output $MONITOR1 --primary --below $MONITOR2 && ~/.fehbg
  xrandr --output $MONITOR2 --auto && xrandr --output $MONITOR1 --primary --right-of $MONITOR2 && ~/.fehbg
fi
