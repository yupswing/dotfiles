# yup server zsh config 1.1 [2020-09-24]

# Prompt
PROMPT="%F{green}%n%f@%F{magenta}%m%f %F{blue}%B%"$'~%-30(l::\n)'"%b%f %# "
RPROMPT='[%F{yellow}%?%f]'

export EDITOR='nvim'
export VISUAL=$EDITOR

# Updater
alias update_zshrc="wget --no-cache --no-http-keep-alive https://raw.githubusercontent.com/yupswing/dotfiles/master/server/zsh/update.zsh -O /tmp/update.zsh && chmod +x /tmp/update.zsh && /tmp/update.zsh && rm /tmp/update.zsh"

# Local (per Host) customizations
for localDir in ~ /etc/zsh /etc /usr/local/etc /usr/local/etc/zsh; do
  if [ -f ${localDir}/zshrc.local ]; then
    source ${localDir}/zshrc.local
  fi
done
unset localDir
