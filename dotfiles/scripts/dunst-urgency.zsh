#!/usr/bin/env zsh

[[ -z $DUNST_APP_NAME ]] && exit

# Get all WID related to appname (from actual shown app in bspc)
wid=$(comm -12 <(bspc query -N | sort) <(xdo id -N $DUNST_APP_NAME | sort))
[[ -z $wid ]] && exit

# Get last WID (if more than one)
wid=$(echo $wid | tail -n1)

# xdo activate $wid
# Set urgency on WID
xdotool set_window --urgency 1 $wid
