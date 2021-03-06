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

# Layouts + compose on ALTGR
setxkbmap -model pc105 -layout us,it -option compose:ralt
