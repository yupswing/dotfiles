#!/usr/bin/env zsh

# Retrive all WINDOW_IDs for hidden windows globally
nodes=($(bspc query -N -n .hidden.window))
[[ -z $nodes ]] && exit

# list=$(echo $nodes | xargs -n1 xdotool getwindowname)
# Create a list for ROFI (CLASSNAME : WINDOWNAME)
list=()
for wid in $nodes; do
  list+="$(xdotool getwindowclassname $wid) : $(xdotool getwindowname $wid)"
done

# Give the option to ROFI (expect an index in return)
# sed to remove first line
selected_index=$(echo ${(j:\n:)list} | rofi -dmenu -format i -p )

[[ -z $selected_index ]] && exit

# Retrive the WINDOW_ID of the user choice
# index was zerobased, but we use sed -n so we want it onebased
wid=${nodes[$((selected_index + 1))]}

# Show the hidden window
bspc node $wid -n focused -g hidden=off -f
