#!/usr/bin/env zsh

# cliphist (+ wl-clipboard)
case "$1" in
--rofi | -r | $NULL)
  cliphist list | rofi -dmenu -i -p  -display-columns 2 | cliphist decode | wl-copy
  ;;
--clear | -c)
  cliphist wipe
  echo "Cleared clipboard history"
  ;;
esac
exit 0
