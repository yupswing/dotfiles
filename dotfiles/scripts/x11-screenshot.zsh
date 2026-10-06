#!/usr/bin/env zsh

scrot_dir=$HOME/Pictures/screenshots/
scrot_file='%Y-%m-%dT%H:%M:%S_$wx$h.png'

if ! [ -d $scrot_dir ]; then
  mkdir -p $scrot_dir
fi

# #INFO in caso di glitch
# https://github.com/resurrecting-open-source-projects/scrot/issues/36

cd $scrot_dir
case "$1" in
--desktop | -d | $NULL)
  scrot $scrot_file -e 'xclip -selection clipboard -t image/png -i $f && notify-send "Screenshot taken $f"'
  ;;
--select | -s)
  # notify-send 'select an area for the screenshot' &
  scrot -s $scrot_file -e 'xclip -selection clipboard -t image/png -i $f && notify-send "Screenshot taken $f"'
  ;;
--open | -o)
  xdg-open $scrot_dir
  ;;
esac
exit 0
