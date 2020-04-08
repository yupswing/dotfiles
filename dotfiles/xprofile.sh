#!/bin/sh

# {{@@ header() @@}}
# FILE: ~/.xprofile

# Monitors profiles
{%@@ if profile == VBOX_HOST @@%}
xrandr --output VGA-1 --primary
{%@@ elif profile == WORK_HOST @@%}
xrandr --output HDMI-3 --primary --right-of DP-1
{%@@ endif @@%}

# Numlock ON
numlockx &
