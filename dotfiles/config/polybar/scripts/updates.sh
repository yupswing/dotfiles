#!/usr/bin/env zsh

# update database
yay -Sy &>/dev/null

# count packages to be updated
COUNT=$(yay -Qu | wc -l)

if [ $COUNT -ne 0 ]; then
  echo "$COUNT updates"
fi
