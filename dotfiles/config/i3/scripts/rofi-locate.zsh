#!/usr/bin/env zsh

xdg-open "$(locate $HOME | sed "s|$HOME|~|g" | rofi -dmenu -i -p  -threads 0 | sed "s|~|$HOME|g")"
