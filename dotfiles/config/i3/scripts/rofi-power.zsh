#!/usr/bin/env zsh
# Original script by Oliver Kraitschy - http://okraits.de
# Modified by Simone Cingano @yupswing

OPTIONS=" Power-off system
 Reboot system
 End session
 Lock screen
 Suspend system
 Hibernate system"
LOCKER=$HOME/.config/i3/scripts/lock.sh

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
    i3-msg exit
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
