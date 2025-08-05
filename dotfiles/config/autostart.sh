#! /usr/bin/env zsh
# {{@@ header() @@}}

launch() {
  pgrep -u "$USER" $1 >/dev/null || $@ &
}

### Hotkeys
###############################################################################
launch sxhkd

sleep 1

### Applets
###############################################################################
# launch redshift-gtk
launch pasystray
# launch blueman-applet
launch nm-applet

### Daemons
###############################################################################
launch dropbox start
# launch nextcloud

### DE Dependent
###############################################################################
case ${GDMSESSION:l} in
i3 | bspwm)
  {%@@ if COMPOSITOR @@%}
  # Composite manager (highest priority)
  launch picom -b
  {%@@ endif @@%}
  # Background
  $HOME/.fehbg &
  # Notifications
  launch dunst -config $HOME/.config/dunst/dunst.conf
  # Clipboard
  launch greenclip daemon
  # Autolock
  $HOME/.scripts/autolock.zsh
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
hyprland)
  wayland &
esac

sleep 1

### Applications
###############################################################################
# launch spotify
# launch google-chrome-stable
launch ferdium
# launch discord
# launch linphone
# launch thunderbird
launch code
