#!/usr/bin/env zsh

rofi -modi calc -show calc -display-calc  -no-show-match -no-sort -no-history -calc-command "echo '{result}' | xclip"
