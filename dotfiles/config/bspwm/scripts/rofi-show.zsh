#!/usr/bin/env zsh

# Retrive all WINDOW_IDs for hidden windows globally
nodes=$(bspc query -N -n .hidden.window)
[[ -z $nodes ]] && exit

# list=$(echo $nodes | xargs -n1 xdotool getwindowname)
# Create a list for ROFI (CLASSNAME : WINDOWNAME)
while IFS= read -r line; do
  list="$list\n$(xdotool getwindowclassname $line) : $(xdotool getwindowname $line)"
done <<< "$nodes"

# Give the option to ROFI (expect an index in return)
# sed to remove first line
selected_index=$(echo $list | sed -n '1!p' | rofi -dmenu -format i -p )

[[ -z $selected_index ]] && exit

# index was zerobased, but we use sed -n so we want it onebased
selected_index=$((selected_index + 1))
# echo $selected_index

# Retrive the WINDOW_ID of the user choice
wid="$(echo $nodes | sed -n ${selected_index}p)"
# echo $wid

# Show the hidden window
bspc node $wid -n focused -g hidden=off -f
