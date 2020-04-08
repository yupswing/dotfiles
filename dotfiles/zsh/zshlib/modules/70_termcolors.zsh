##############################################################################
# Colorize terminal

# autoload colors zsh/terminfo
# if [[ "$terminfo[colors]" -ge 8 ]]; then
#   colors
# fi
# for color in RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
#   eval PR_$color='%{$terminfo[bold]$fg[${(L)color}]%}'
#   eval PR_LIGHT_$color='%{$fg[${(L)color}]%}'
#   ((count = $count + 1))
# done
# PR_NO_COLOR="%{$terminfo[sgr0]%}"

# ----------------------------------------------------------------------------
# pywal

if [[ -f $HOME/.cache/wal/sequences ]]; then
  # initialise colors for this terminal
  (cat $HOME/.cache/wal/sequences &)
  # tty colors
  # source $HOME/.cache/wal/colors-tty.sh
fi
