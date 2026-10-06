#!/usr/bin/env zsh

# Session dependent commands (wayland: Hyprland, x11: bspwm/i3)
if [[ -n $WAYLAND_DISPLAY ]]; then
  # hyprlock does not fork, so run it in background (only once)
  LOCKER='{ pidof -q hyprlock || hyprlock & }'
  END_SESSION="hyprctl dispatch 'hl.dsp.exit()'"
else
  LOCKER=$HOME/.scripts/x11-lock.zsh
  END_SESSION=$HOME/.config/bspwm/scripts/quit.sh
fi

# Commands to execute in an ordered array which will be used as a sort of hash:
MENU=(
  ' Power-off system'    'systemctl poweroff'
  ' Reboot system'       'systemctl reboot'
  ' End session'         '$END_SESSION'
  ' Lock screen'         '$LOCKER'
  ' Suspend system'      '$LOCKER && systemctl suspend'
  # ' Hibernate system'    '$LOCKER && systemctl hibernate' #WARNING DO NOT USE WITH ZFS!
)

# Extract menu labels and menu commands
MENU_LABELS=()
MENU_COMMANDS=()
for ((index = 1; index <= $#MENU; index++)); do
  (( index % 2 )) && MENU_LABELS+=("${MENU[index]}")
  (( index % 2 )) || MENU_COMMANDS+=("${MENU[index]}")
done

# Launch rofi with labels
LAUNCHER="rofi -dmenu -i -p  -width -30 -format i"
SELECTED=$(printf "%s\n" "${MENU_LABELS[@]}" | ${(s: :)LAUNCHER})

# No selection
[[ -z $SELECTED ]] && exit

# Selected an index (-format i), but it is zerobased
# (double eval: the first expands $LOCKER/$END_SESSION, the second runs them)
eval "eval $MENU_COMMANDS[SELECTED+1]"
