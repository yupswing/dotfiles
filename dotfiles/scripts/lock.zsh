#!/usr/bin/env zsh

# #TODO this script needs some serious housekeeping

# -----------------------------------------------------------------------------

# Customize
IMAGE=/tmp/screen_locked.png
FONT="IBM Plex Sans Condensed"
FONT_SIZE=84
BOTTOM=100
HEIGHT=200
WIDTH_TEXT=350
MARGIN=100
RADIUS_RING=20

# Set STATIC to use a static image
# Otherwise if you comment the line it will pixelate the current screen
# STATIC=$(echo ${$(cat $HOME/.fehbg)[-1]} | sed "s/'//g")

# -----------------------------------------------------------------------------

# Pause music
playerctl pause

# -----------------------------------------------------------------------------

# Calculate all the variables

RADIUS_INDICATOR=$((HEIGHT / 2))
WIDTH_INDICATOR=$HEIGHT

RESOLUTION=($(xrandr --query | grep ' primary' | grep -o '[0-9][0-9]*x[0-9][0-9]*[^ ]*' | sed 's/[x+]/ /g'))
# $RESOLUTION is WIDTH,HEIGHT,X,Y (array based 1)
SCREEN_HEIGHT=$((${RESOLUTION[2]}))
SCREEN_X_SHIFT=$((${RESOLUTION[3]}))
SCREEN_Y_SHIFT=$((${RESOLUTION[4]}))

TOP=$((SCREEN_Y_SHIFT + SCREEN_HEIGHT - BOTTOM - HEIGHT))
WIDTH=$((MARGIN + WIDTH_TEXT + WIDTH_INDICATOR))

HEIGHT_HALF=$((HEIGHT / 2))

# for some reason instead of MARGIN + WIDTH_TEXT i need to add also its WIDTH.
X_TEXT=$((SCREEN_X_SHIFT + MARGIN))
X_INDICATOR=$((X_TEXT + WIDTH_TEXT + WIDTH_INDICATOR))

DRAW_RECT="fill black fill-opacity 0.6 rectangle $((SCREEN_X_SHIFT)),$TOP $((X_TEXT + WIDTH_TEXT + WIDTH_INDICATOR - 1)),$((TOP + HEIGHT))"
DRAW_ARC="fill black fill-opacity 0.6 arc $((X_TEXT + WIDTH_TEXT + WIDTH_INDICATOR / 2)),$TOP $((SCREEN_X_SHIFT + WIDTH + HEIGHT_HALF)),$((TOP + HEIGHT)) 270,90"

# -----------------------------------------------------------------------------

if [ -z $STATIC ]; then
  rm $IMAGE 2>/dev/null

  echo "Taking screenshot..."

  # Take a picture of the screen
  scrot $IMAGE

  echo "Decorating screenshot..."
  # Pixelate it and add shape
  convert $IMAGE -scale 10% -scale 1000% -draw "$DRAW_ARC" -draw "$DRAW_RECT" $IMAGE
else
  if [ ! -f "$IMAGE" ]; then
    # Add shape
    echo "Decorating picture '$STATIC'..."
    convert $STATIC -draw "$DRAW_ARC" $IMAGE
  fi
fi

# -----------------------------------------------------------------------------

# Colors from term
function color() {
  xrdb -query | grep "*color$1:" | sed "s/.*#\([0-9a-f]\{6\}\)/\1$2/gi"
}
B=$(color 0 00) # background
R=$(color 0 99) # ring
T=$(color 7 99) # text
W=$(color 1 99) # wrong
V=$(color 5 99) # verifying
TRANSPARENT="00000000"

# Pause notifications
pkill -xu $EUID -USR1 dunst

echo "Launching i3lock-color..."
i3lock \
  --nofork \
  --ignore-empty-password \
  --no-modkey-text \
  --color=00000000 \
  \
  --image $IMAGE \
  \
  --indicator \
  --clock --force-clock \
  \
  --keyhl-color=$W \
  --bshl-color=$W \
  \
  --wrong-text="" \
  --wrong-color=$T \
  --ringwrong-color=$W \
  --insidewrong-color=$W \
  \
  --verif-text="" \
  --verif-color=$T \
  --ringver-color=$V \
  --insidever-color=$V \
  \
  --noinput-text="" \
  \
  --ind-pos="$X_INDICATOR:$((TOP + HEIGHT_HALF))" \
  --radius=$((RADIUS_INDICATOR - RADIUS_RING)) \
  --ring-width=$RADIUS_RING \
  --ring-color=$R \
  --inside-color=$TRANSPARENT \
  --line-color=$B \
  --separator-color=$TRANSPARENT \
  \
  --time-str="%H:%M:%S" \
  --time-pos="$X_TEXT:iy+7" \
  --time-font=$FONT \
  --time-size=$FONT_SIZE \
  --time-align=1 \
  --time-color=$T \
  \
  --date-str="%A, %d %B %Y" \
  --date-color=$T \
  --date-font=$FONT \
  --date-size=$((FONT_SIZE * 0.4)) \
  --date-pos="tx:ty+$((FONT_SIZE * 0.5))" \
  --date-align=1

# Unpause notifications
pkill -xu $EUID -USR2 dunst

if [ -z $STATIC ]; then
  # Delete old image (if present)
  rm $IMAGE 2>/dev/null
fi
