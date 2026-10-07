#! /usr/bin/env zsh
# {{@@ header() @@}}

launch() {
  pgrep -u "$USER" $1 >/dev/null || $@ &
}

### Hotkeys
###############################################################################
# X11 only: on wayland the compositor handles the binds
[[ -z $WAYLAND_DISPLAY ]] && launch sxhkd

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
# GDMSESSION is set by lightdm/gdm only, other DMs (ly) set the XDG ones
SESSION=${GDMSESSION:-${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-$DESKTOP_SESSION}}}
case ${SESSION:l} in
i3 | bspwm)
  # Portals: the systemd user manager may survive a previous Hyprland session,
  # drop its stale wayland env and restart them with the current one
  systemctl --user unset-environment WAYLAND_DISPLAY HYPRLAND_INSTANCE_SIGNATURE
  dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
  systemctl --user stop xdg-desktop-portal-hyprland
  systemctl --user try-restart xdg-desktop-portal-gtk xdg-desktop-portal
  {%@@ if X11_COMPOSITOR @@%}
  # Composite manager (highest priority)
  launch picom -b
  {%@@ endif @@%}
  # Background
  $HOME/.fehbg &
  # Notifications
  launch dunst
  # Clipboard
  launch greenclip daemon
  # Autolock
  $HOME/.scripts/x11-autolock.zsh
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
  # Portals: the systemd user manager may survive a previous X11 session,
  # import the current env and restart them (they would not open windows)
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE
  systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  # The backend goes first: the frontend reads its capabilities (e.g. ScreenCast
  # cursor modes) only once at startup. reset-failed clears the start limit hit
  # when the backend crash-loops while the previous session goes down
  systemctl --user reset-failed xdg-desktop-portal-hyprland
  systemctl --user start xdg-desktop-portal-hyprland
  systemctl --user start xdg-desktop-portal

  # Hypr ecosystem daemons
  systemctl --user start hyprpolkitagent

  sleep 1

  # Bar
  launch waybar
  # Background
  launch hyprpaper
  # Notifications
  launch dunst
  # Clipboard
  launch wl-paste --watch cliphist store
  # launch udiskie --tray       # mount tray
  # launch wlsunset -l 44 -L 9  # warm screen evening (set coordinates)
  ;;
esac

sleep 1

### Applications
###############################################################################
# launch spotify
launch google-chrome-stable
launch ferdium
launch discord
# launch linphone
# launch thunderbird
launch code
