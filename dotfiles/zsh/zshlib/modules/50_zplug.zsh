# -------------------------------------------------------------------------- #
# ZPLUG

export ZPLUG_HOME=$YUPZSHRC_HOME/zplug

# Install zplug if no zplug
if [[ ! -e $ZPLUG_HOME ]]; then
  echo "*** Installing zplug"
  git clone https://github.com/zplug/zplug $ZPLUG_HOME
fi

# -------------------------------------------------------------------------- #

source $ZPLUG_HOME/init.zsh

# zsh-users
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-completions"

# oh-my-zsh
zplug "plugins/globalias", from:oh-my-zsh
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/common-aliases", from:oh-my-zsh

# CTRL+T, CTRL+R, ALT+C
zplug "plugins/fzf", from:oh-my-zsh

zplug "plugins/gitfast", from:oh-my-zsh

zplug "plugins/pip", from:oh-my-zsh
zplug "plugins/ruby", from:oh-my-zsh
# zplug "plugins/rails", from:oh-my-zsh

# Personal
zplug "yupswing/zsh-rationalise-dot"

# Theme
zplug romkatv/powerlevel10k, as:theme, depth:1
[[ ! -f $YUPZSHRC_HOME/p10k.zsh ]] || source $YUPZSHRC_HOME/p10k.zsh
# see also .zshrc for "instant prompt"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo
    zplug install
  fi
fi

zplug load # --verbose

# -------------------------------------------------------------------------- #

function zplug_update() {
  echo "\n*** Update zplug"
  git -C $ZPLUG_HOME pull

  echo "\n*** Update plugins"
  zplug update

  echo "\n*** Please restart your shell"
}
