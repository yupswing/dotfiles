#######################################################################################
# Aliases

# tail / head shortcuts
alias -g GI='| grep -i'

# list
alias ls='ls -F --color'
alias l='ls -lAFh --color'
# alias la='ls -A'
# alias ll='ls -l'

# sudo
alias fu='sudo $(fc -ln -1)'
alias _=sudo
alias __='sudo -s'

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
alias les=less
alias pk=pkill
alias cls=clear

# utils
alias wh=which
alias zap='rm -rf'

# mistakes
alias dc=cd

# ps
alias p='ps -ef'

