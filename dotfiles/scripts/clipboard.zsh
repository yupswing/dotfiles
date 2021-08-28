#!/usr/bin/env zsh

if [[ $1 == '-c' ]]; then
  pkill greenclip && greenclip clear && greenclip daemon &
  echo "Cleared clipboard history"
  exit
fi

rofi -modi "clipboard:greenclip print" -show clipboard -run-command '{cmd}'
