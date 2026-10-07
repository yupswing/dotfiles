#!/usr/bin/env zsh

# Lock the session with hyprlock (wayland counterpart of x11-lock.zsh).
# Used by the keybind (hypr/conf/binds.lua), the power menu (rofi-power.zsh)
# and the idle daemon (hypr/hypridle.conf).

# Already locked
pidof -q hyprlock && exit

# Pause music
playerctl -a pause

# Pause notifications
dunstctl set-paused true

# hyprlock does not fork: it returns when the session is unlocked
hyprlock

# Unpause notifications
dunstctl set-paused false
