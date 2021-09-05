#!/usr/bin/env zsh
# Original script by Oliver Kraitschy - http://okraits.de
# Modified by Simone Cingano @yupswing

OPTIONS=" Power-off system
 Reboot system
 End session
 Lock screen
 Suspend system
 Hibernate system"
LOCKER=$HOME/.scripts/lock.zsh

LAUNCHER="rofi -dmenu -i -p  -width -30"
option=$(echo -e "$OPTIONS" | ${(s: :)LAUNCHER} | awk '{print $2}' | tr -d '\r\n')

if [ ${#option} -gt 0 ]; then
  case $option in
  Power-off)
    systemctl poweroff
    ;;
  Reboot)
    systemctl reboot
    ;;
  End)
    case ${GDMSESSION:l} in
      i3)
        i3-msg exit
        ;;
      bspwm)
        $HOME/.config/bspwm/scripts/quit.sh
        # bspc quit
        ;;
    esac
    ;;
  Lock)
    eval $LOCKER
    ;;
  Suspend)
    systemctl suspend
    eval $LOCKER
    ;;
  Hibernate)
    systemctl hibernate
    eval $LOCKER
    ;;
  *) ;;

  esac
fi
