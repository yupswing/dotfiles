#!/usr/bin/env zsh

xdg-open "$(locate -i $HOME | sed "s|$HOME|~|g" | grep -vE '(.cache|node_modules)' | rofi -dmenu -i -p  -threads 0 -sort | sed "s|~|$HOME|g")"
