#!/usr/bin/env zsh

# Power menu: a 3x2 grid of buttons (rofi theme: ~/.config/rofi/power.rasi)

# Session dependent commands (wayland: Hyprland, x11: bspwm/i3)
if [[ -n $WAYLAND_DISPLAY ]]; then
  # the lock script returns only on unlock, so run it in background
  LOCKER='{ $HOME/.scripts/way-lock.zsh & }'
  END_SESSION="hyprctl dispatch 'hl.dsp.exit()'"
  # (the pause lets go of the Enter key, which would wake the screen right back up)
  SCREEN_OFF="sleep 1; hyprctl eval 'hl.dispatch(hl.dsp.dpms({ action = \"disable\" }))'"
else
  LOCKER=$HOME/.scripts/x11-lock.zsh
  END_SESSION=$HOME/.config/bspwm/scripts/quit.sh
  SCREEN_OFF="sleep 1; xset dpms force off"
fi

# Buttons, row by row (icon, label, command), in an ordered array which will be
# used as a sort of hash. The first one is selected when the menu opens
MENU=(
  ''    'Log out'     '$END_SESSION'
  ''    'Reboot'      'systemctl reboot'
  ''    'Shut down'   'systemctl poweroff'
  ''    'Lock'        '$LOCKER'
  '󰶐'    'Screen off'  '$SCREEN_OFF'
  ''    'Suspend'     '$LOCKER && systemctl suspend'
  # ''    'Hibernate'   '$LOCKER && systemctl hibernate' #WARNING DO NOT USE WITH ZFS!
)

# The icons are nerd font glyphs drawn by rofi as "text icons": they do not take
# the colour from the theme, so read the foreground of the wal palette it uses
ICON_FONT='FiraCode Nerd Font Propo'
ICON_COLOR=$(sed -n 's/.*foreground-colour: *\(#[0-9a-fA-F]*\).*/\1/p' $HOME/.cache/wal/colors.rasi 2>/dev/null)
ICON_COLOR=${ICON_COLOR:-#f8f8f2}

# Extract menu rows (label + icon) and menu commands
MENU_ROWS=()
MENU_COMMANDS=()
for ((index = 1; index <= $#MENU; index += 3)); do
  MENU_ROWS+=("${MENU[index+1]}\0icon\x1f<span font_family='$ICON_FONT' color='$ICON_COLOR'>${MENU[index]}</span>")
  MENU_COMMANDS+=("${MENU[index+2]}")
done

# Launch rofi with the buttons
LAUNCHER="rofi -dmenu -i -show-icons -theme power -format i"
SELECTED=$(printf "%b\n" "${MENU_ROWS[@]}" | ${(s: :)LAUNCHER})

# No selection
[[ -z $SELECTED ]] && exit

# Selected an index (-format i), but it is zerobased
# (double eval: the first expands $LOCKER/$END_SESSION, the second runs them)
eval "eval $MENU_COMMANDS[SELECTED+1]"
