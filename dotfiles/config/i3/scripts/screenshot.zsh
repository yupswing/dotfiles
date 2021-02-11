scrot_dir=$HOME/Pictures/screenshots/
scrot_file='%Y-%m-%dT%H:%M:%S_$wx$h.png'

if ! [ -d $scrot_dir ]; then
  mkdir -p $scrot_dir
fi

cd $scrot_dir
case "$1" in
--desk | -d | $NULL)
  scrot $scrot_file -e 'xclip -selection clipboard -t image/png -i $f && notify-send "screenshot taken $f"'
  ;;
--select | -s)
  notify-send 'select an area for the screenshot' &
  scrot -s $scrot_file -e 'xclip -selection clipboard -t image/png -i $f && notify-send "screenshot taken $f"'
  ;;
esac
exit 0
