#######################################################################################
# Aliases

# tail / head shortcuts
alias -g GI='| grep -i'

# utils
alias zap='rm -rf'

# list
# alias ls='ls -F --color'
alias ls="exa --icons --sort=name --group-directories-first"
alias la="ls -a"
alias ll="ls -lga --git"
alias lt="ll --tree --level=2"

# enable alias in sudo
alias sudo='sudo '
# sudo
alias fu='sudo $(fc -ln -1)'
alias _='sudo '
# alias __='sudo -s'

# defaults
alias mkdir='mkdir -p'
alias ftail='tail -f'
alias grep='grep --colour'
alias killall='killall -v'

# host shortcuts
alias ns='host -t ns'
alias mx='host -t mx'
alias soa='host -t soa'
alias ptr='host -t ptr'

# shortcuts
alias v=nvim
alias vim=nvim
alias k='kill -9'
alias pk='pkill -f'
alias cls=clear
alias pp=prettyping

# mistakes
alias dc=cd

# ps
alias p='ps -ef'
