# yup server zsh config 1.0

PROMPT='%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%~%b%f %# '
RPROMPT='[%F{yellow}%?%f]'
alias update_zshrc=wget --no-cache https://raw.githubusercontent.com/yupswing/dotfiles/master/server/zsh/update.zsh -O /tmp/update.zsh && chmod +x /tmp/update.zsh && /tmp/update.zsh
