#!/usr/bin/env zsh

IMAGE=/tmp/screen_locked.png

# Pause music
playerctl pause

# Take a picture of the screen
scrot $IMAGE

# Pixelate it
convert $IMAGE -scale 10% -scale 1000% $IMAGE

# Use it as a wallpaper
# ** i3lock
# i3lock -t -e -f -n -i  /tmp/screen_locked.png
# ** i3lock-color

function color() {
  xrdb -query | grep "*color$1:" | sed "s/.*#\([0-9a-f]\{6\}\)/\1$2/gi"
}

B=$(color 0 00) # background
C=$(color 0 99) # background (while verifying)
D=$(color 0 99) # ring
T=$(color 7 99) # text
W=$(color 1 99) # wrong
V=$(color 5 99) # verifying

i3lock \
  --nofork \
  \
  --insidevercolor=$C \
  --ringvercolor=$V \
  \
  --insidewrongcolor=$C \
  --ringwrongcolor=$W \
  \
  --insidecolor=$B \
  --ringcolor=$D \
  --linecolor=$B \
  --separatorcolor=$D \
  \
  --verifcolor=$T \
  --wrongcolor=$T \
  --timecolor=$T \
  --datecolor=$T \
  --layoutcolor=$T \
  --keyhlcolor=$W \
  --bshlcolor=$W \
  \
  --image $IMAGE \
  \
  --radius=150 \
  --ring-width=50.0 \
  --clock \
  --indicator \
  --timestr="%H:%M:%S" \
  --datestr="%A, %m %Y" \
  --veriftext="Verifying" \
  --wrongtext="WRONG!" \
  --layout-font=FiraCode Nerd Font

# Remove files
rm $IMAGE
