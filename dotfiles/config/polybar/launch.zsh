#!/usr/bin/env zsh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch `main` polybar for each monitor
# for m in $(polybar --list-monitors | cut -d":" -f1); do
#     MONITOR=$m polybar -c $HOME/.config/polybar/config.conf --reload primary &
# done

# HOW TO SET PRIMARY
# `xrandr --output HDMI-3 --primary --right-of DP-1`

# Launch `primary` polybar for primary monitor and `secondary` for everything else
# (or just `primary` if only 1 monitor)
export POLYBAR_SHELL=/bin/sh
MONITORS=$(polybar --list-monitors)

if [[ $(echo -e $MONITORS | wc -l) -eq 1 ]]; then

  MONITOR=$(echo -e $MONITORS | cut -d":" -f1) polybar -c $HOME/.config/polybar/config.conf --reload primary &

else

  PRIMARY=$(echo -e $MONITORS | grep primary | cut -d":" -f1)
  SECONDARY=$(echo -e $MONITORS | grep -v primary | cut -d":" -f1)

  if [[ ! -z "$PRIMARY" ]]; then
    MONITOR=$PRIMARY polybar -c $HOME/.config/polybar/config.conf --reload primary &
  fi

  for m in $SECONDARY; do
    MONITOR=$m polybar -c $HOME/.config/polybar/config.conf --reload secondary &
  done

  unset PRIMARY
  unset SECONDARY
fi

unset MONITORS
