#!/usr/bin/env zsh

case "$1" in
--rofi | -r | $NULL)
  # rofi -modi ":greenclip print" -show  -run-command '{cmd}' -theme clipboard
  rofi -modi ":greenclip print" -show  -run-command '{cmd}'
  ;;
--clear | -c)
  pkill greenclip && greenclip clear && greenclip daemon &
  echo "Cleared clipboard history"
  ;;
esac
exit 0
