#!/usr/bin/env zsh

screenshot_dir=$HOME/Pictures/screenshots/
screenshot_date='%Y-%m-%dT%H:%M:%S'

if ! [ -d $screenshot_dir ]; then
  mkdir -p $screenshot_dir
fi

# hyprland: le regole no_screen_share (conf/rules.lua) oscurano le finestre in
# qualsiasi cattura, screenshot compresi, quindi restano sospese dall'inizio
# alla fine dello scatto (usiamo funzione custom `screen_share_privacy`)
share_privacy() {
  [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] && hyprctl eval "screen_share_privacy($1)" &>/dev/null
}

# wayland: grim (+slurp per l'area) e wl-copy
take_screenshot() {
  local file geometry picker_pid
  share_privacy false
  {
    if [ "$1" = "select" ]; then
      # slurp non congela lo schermo: hyprpicker mostra un frame fermo sotto
      if (( $+commands[hyprpicker] )); then
        hyprpicker -r -z &>/dev/null &!
        picker_pid=$!
        sleep 0.2
      fi
      # slurp esce con errore se la selezione viene annullata (Esc)
      geometry=$(slurp) || return 1
      file=$(date +$screenshot_date)_${${geometry#* }%% *}.png
      grim -g "$geometry" $file || return 1
    else
      file=$(date +$screenshot_date).png
      grim $file || return 1
    fi
  } always {
    # va chiuso dopo grim, che cattura il frame congelato
    [ -n "$picker_pid" ] && kill $picker_pid 2>/dev/null
    share_privacy true
  }
  wl-copy --type image/png <$file && notify-send "Screenshot taken $file"
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
