#!/usr/bin/env zsh

# x11: greenclip, wayland: cliphist (+ wl-clipboard)
case "$1" in
--rofi | -r | $NULL)
  if [[ -n $WAYLAND_DISPLAY ]]; then
    cliphist list | rofi -dmenu -i -p  -display-columns 2 | cliphist decode | wl-copy
  else
    # rofi -modi ":greenclip print" -show  -run-command '{cmd}' -theme clipboard
    rofi -modi ":greenclip print" -show  -run-command '{cmd}'
  fi
  ;;
--clear | -c)
  if [[ -n $WAYLAND_DISPLAY ]]; then
    cliphist wipe
  else
    pkill greenclip && greenclip clear && greenclip daemon &
  fi
  echo "Cleared clipboard history"
  ;;
esac
exit 0
