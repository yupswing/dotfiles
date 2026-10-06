#!/usr/bin/env zsh

screenshot_dir=$HOME/Pictures/screenshots/
screenshot_date='%Y-%m-%dT%H:%M:%S'

if ! [ -d $screenshot_dir ]; then
  mkdir -p $screenshot_dir
fi

# wayland: grim (+slurp per l'area) e wl-copy
wayland_screenshot() {
  local file geometry picker_pid
  if [ "$1" = "select" ]; then
    # slurp non congela lo schermo: hyprpicker mostra un frame fermo sotto
    if (( $+commands[hyprpicker] )); then
      hyprpicker -r -z &>/dev/null &!
      picker_pid=$!
      sleep 0.2
    fi
    {
      # slurp esce con errore se la selezione viene annullata (Esc)
      geometry=$(slurp) || return 1
      file=$(date +$screenshot_date)_${${geometry#* }%% *}.png
      grim -g "$geometry" $file || return 1
    } always {
      # va chiuso dopo grim, che cattura il frame congelato
      [ -n "$picker_pid" ] && kill $picker_pid 2>/dev/null
    }
  else
    file=$(date +$screenshot_date).png
    grim $file || return 1
  fi
  wl-copy --type image/png <$file && notify-send "Screenshot taken $file"
}

# x11: scrot e xclip
# #INFO in caso di glitch
# https://github.com/resurrecting-open-source-projects/scrot/issues/36
x11_screenshot() {
  local file=$screenshot_date'_$wx$h.png'
  local after='xclip -selection clipboard -t image/png -i $f && notify-send "Screenshot taken $f"'
  if [ "$1" = "select" ]; then
    scrot -s $file -e $after
  else
    scrot $file -e $after
  fi
}

take_screenshot() {
  if [ -n "$WAYLAND_DISPLAY" ]; then
    wayland_screenshot $1
  else
    x11_screenshot $1
  fi
}

cd $screenshot_dir
case "$1" in
--desktop | -d | $NULL)
  take_screenshot desktop
  ;;
--select | -s)
  # notify-send 'select an area for the screenshot' &
  take_screenshot select
  ;;
--open | -o)
  xdg-open $screenshot_dir
  ;;
esac
exit 0
