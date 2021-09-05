#!/usr/bin/env zsh

case "$1" in
--rofi | -r | $NULL)
  rofi -modi calc -show calc -display-calc  -no-show-match -no-sort -calc-command "echo '{result}' | xclip"
  ;;
--clear | -c)
  rm $HOME/.local/share/rofi/rofi_calc_history
  echo "Cleared calculator history"
  ;;
esac
exit 0
