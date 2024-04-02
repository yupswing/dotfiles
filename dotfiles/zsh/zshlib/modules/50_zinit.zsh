
# -------------------------------------------------------------------------- #
# ZINIT

export ZINIT_HOME=$YUPZSHRC_HOME/.zinit/bin

# Install zinit if no zinit
if [[ ! -e $ZINIT_HOME ]]; then
  echo "*** Installing zinit"
  git clone https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME
fi

# -------------------------------------------------------------------------- #

# Load
source $ZINIT_HOME/zinit.zsh
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# -------------------------------------------------------------------------- #

# zsh-users
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

# oh-my-zsh
zinit snippet OMZ::plugins/globalias
zinit snippet OMZ::plugins/command-not-found
zinit snippet OMZ::plugins/common-aliases

# CTRL+T, CTRL+R, ALT+C
zinit snippet OMZ::plugins/fzf

# zinit snippet OMZ::plugins/gitfast

# zinit snippet OMZ::plugins/pip
# zinit snippet OMZ::plugins/ruby
# zinit snippet OMZ::plugins/rails

# Personal
zinit light yupswing/zsh-rationalise-dot

# # Theme
zinit ice depth=1
zinit light romkatv/powerlevel10k
[[ ! -f $YUPZSHRC_HOME/p10k.zsh ]] || source $YUPZSHRC_HOME/p10k.zsh
# # see also .zshrc for "instant prompt"

# # -------------------------------------------------------------------------- #

function update-zinit() {
  echo "\n*** Update zinit"
  zinit self-update

  echo "\n*** Update plugins"
  zinit update --all
}
