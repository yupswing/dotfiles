#!/usr/bin/env zsh
# Original script by Oliver Kraitschy - http://okraits.de
# Modified by Simone Cingano @yupswing

OPTIONS="Lock screen\nEnd session\nReboot system\nPower-off system\nSuspend system\nHibernate system"
LOCKER=$HOME/.config/i3/scripts/lock.sh

LAUNCHER="rofi -dmenu -i -p  -width -30"
option=$(echo -e "$OPTIONS" | ${(s: :)LAUNCHER} | awk '{print $1}' | tr -d '\r\n')

if [ ${#option} -gt 0 ]; then
  case $option in
  Lock)
    eval $LOCKER
    ;;
  End)
    i3-msg exit
    ;;
  Reboot)
    systemctl reboot
    ;;
  Power-off)
    systemctl poweroff
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
