## If we are not interactive quit
[ -z "$PS1" ] && return

# History
export SAVEHIST=500
export HISTFILE=$HOME/.history
export HISTSIZE=32000

export LOGCHECK=30
export REPORTTIME=15
export WATCH=notme
export WATCHFMT="%n %a %l (%m) at %t."

# Prompt
export ZLE_RPROMPT_INDENT=0

# Set umask to collaborative mode
umask 002
