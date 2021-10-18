#!/usr/bin/env zsh

LOCKER=$HOME/.scripts/lock.zsh

# Commands to execute in an ordered array which will be used as a sort of hash:
MENU=(
  ' Power-off system'    'systemctl poweroff'
  ' Reboot system'       'systemctl reboot'
  ' End session'         '$HOME/.config/bspwm/scripts/quit.sh'
  ' Lock screen'         '$LOCKER'
  ' Suspend system'      'systemctl suspend; $LOCKER'
  # ' Hibernate system'    'systemctl hibernate; $LOCKER'
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
eval $MENU_COMMANDS[SELECTED+1]
