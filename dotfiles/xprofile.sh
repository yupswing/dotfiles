#!/bin/sh

# {{@@ header() @@}}
# FILE: ~/.xprofile

# Monitors profiles
{%@@ if profile == VM_HOST @@%}
xrandr --output VGA-1 --primary
{%@@ elif profile == WORK_HOST @@%}
xrandr --output HDMI-3 --primary --right-of DP-1
{%@@ endif @@%}

# Numlock ON
numlockx

# Increase key speed via a rate change
xset r rate 300 50

# Layouts + compose on ALTGR
setxkbmap -model pc105 -layout us,it -option compose:ralt

# Set cursor in root window (to avoid X in bspwm)
xsetroot -cursor_name left_ptr
