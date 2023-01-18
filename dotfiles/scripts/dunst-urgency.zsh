#!/usr/bin/env zsh

[[ -z $DUNST_DESKTOP_ENTRY ]] && exit

# # WM INDEPENDENT SET URGENT (to be tested)
# Get lowest numeric id (is it a wid? it does not look like it) and make it urgent
# (lowest because it is probably the main window)
# (It does not work with Thunderbird, the main window is a random one in the list)
# xdotool set_window --urgency 1 \
#     "$(xdotool search --name "${DUNST_DESKTOP_ENTRY}" | sort -n | head -n1)" \
#      &> /dev/null

# BSPWM SET URGENT
# Get all WID related to appname (from actual shown app in bspc)
wid=$(comm -12 <(bspc query -N | sort) <(xdo id -N $DUNST_DESKTOP_ENTRY | sort))
[[ -z $wid ]] && exit

# Get last WID (if more than one)
wid=$(echo $wid | tail -n1)

# xdo activate $wid
# Set urgency on WID
xdotool set_window --urgency 1 $wid
