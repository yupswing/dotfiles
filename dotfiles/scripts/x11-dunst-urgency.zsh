#!/usr/bin/env zsh

# Exit if neither DUNST_DESKTOP_ENTRY nor DESKTOP_APP_NAME is available
[[ -z $DUNST_DESKTOP_ENTRY ]] && exit

case $DUNST_DESKTOP_ENTRY in
"ferdium")
  # DUNST_DESKTOP_ENTRY and DESKTOP_APP_NAME are lowercase, but window is uppercase
  NAME="Ferdium"
  ;;
"Thunderbird")
  # DUNST_DESKTOP_ENTRY is Thunderbird
  # DESKTOP_APP_NAME is thunderbird
  # window are present in both, but we need to use the first match of thunderbird
  NAME="thunderbird"
  ;;
*)
  NAME=$DUNST_DESKTOP_ENTRY
  ;;
esac

# # WM INDEPENDENT SET URGENT (to be tested)
# Get lowest numeric id (is it a wid? it does not look like it) and make it urgent
# (lowest because it is probably the main window)
# (It does not work with Thunderbird, the main window is a random one in the list)
# xdotool set_window --urgency 1 \
#     "$(xdotool search --name "${NAME}" | sort -n | head -n1)" \
#      &> /dev/null

# BSPWM SET URGENT
# Get all WID related to appname (from actual shown app in bspc)
wid=$(comm -12 <(bspc query -N | sort) <(xdo id -N $NAME | sort))
[[ -z $wid ]] && exit

# Get first WID (if more than one)
wid=$(echo $wid | head -n1)

# xdo activate $wid
# Set urgency on WID
xdotool set_window --urgency 1 $wid
