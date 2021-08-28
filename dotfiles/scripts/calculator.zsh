#!/usr/bin/env zsh

if [[ $1 == '-c' ]]; then
  rm $HOME/.local/share/rofi/rofi_calc_history
  echo "Cleared calculator history"
  exit
fi

rofi -modi calc -show calc -display-calc  -no-show-match -no-sort -calc-command "echo '{result}' | xclip"
