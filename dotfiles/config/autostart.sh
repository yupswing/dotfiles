#! /usr/bin/env zsh
# {{@@ header() @@}}

launch() {
  pgrep -u "$USER" $1 >/dev/null || $@ &
}


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


### DE Dependent (unused)
###############################################################################
# # GDMSESSION is set by lightdm/gdm only, other DMs (ly) set the XDG ones
# SESSION=${GDMSESSION:-${XDG_CURRENT_DESKTOP:-${XDG_SESSION_DESKTOP:-$DESKTOP_SESSION}}}
# case ${SESSION:l} in
# i3 | bspwm) # ;; # cinnamon|cinnamon2d) # ;; # enlightenment) # ;; # gnome|gnome-cassic) # ;; # kde-plasma) # ;; # xfce) # ;; # hyprland) # ;; # esac


### Hyprland
###############################################################################

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

sleep 2

# Bar
launch waybar
# Background
launch hyprpaper
# Idle (screen off)
launch hypridle
# Notifications
launch dunst
# Clipboard
launch wl-paste --watch cliphist store

sleep 2

### Applications
###############################################################################

# launch spotify
launch google-chrome-stable
launch discord
launch ferdium
launch code
