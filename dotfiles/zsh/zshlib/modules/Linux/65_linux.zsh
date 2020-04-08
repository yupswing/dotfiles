# Linux
if [ -f /etc/dir_colors ]; then
  eval "$(dircolors /etc/dir_colors)"
elif [ -f $HOME/.dir_colors ]; then
  eval "$(dircolors $HOME/.dir_colors)"
else
  eval $(dircolors)
fi

function yuptheme() {
  if [ -f $1 ]; then
    # picture
    feh --no-fehbg --bg-fill $1 && wal -n -i $1
  else
    # theme name
    wal --theme $1
  fi
}

alias open='xdg-open'
alias fonts='fc-list --format="%{family[0]}\n" | sort | uniq'
alias gotop='gotop -a -c monokai'
