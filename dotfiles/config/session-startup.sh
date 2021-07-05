#! /usr/bin/env zsh
# {{@@ header() @@}}

sleep 1

### Applets
###############################################################################
redshift-gtk &
pasystray &
# blueman-applet &
nm-applet &

### Daemons
###############################################################################
dropbox start &
# nextcloud &

### DE Dependent
###############################################################################
case ${GDMSESSION:l} in
i3)
  {%@@ if COMPOSITOR @@%}
  # Composite manager (highest priority)
  picom -bG &
  {%@@ endif @@%}
  # Background
  $HOME/.fehbg &
  # Notifications
  dunst -config $HOME/.config/dunst/dunst.conf &
  # Clipboard
  greenclip daemon &
  # Autolock
  $HOME/.config/i3/scripts/autolock.zsh &
  # Polybar
  wal -R && $HOME/.config/polybar/launch.zsh &
  ;;
  # cinnamon|cinnamon2d)
  #   ;;
  # enlightenment)
  #   ;;
  # gnome|gnome-cassic)
  #   ;;
  # kde-plasma)
  #   ;;
  # xfce)
  #   ;;
esac

sleep 1

### Applications
###############################################################################
# spotify &
# google-chrome-stable &
rambox &
discord &
linphone &
thunderbird &
code &
