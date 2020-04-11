# ----------------------------------------------------------------------------
# NODENV
# https://github.com/nodenv/nodenv#basic-github-checkout
# https://github.com/nodenv/node-build#installation (for `nodenv install`)

export NODENV_ROOT="${HOME}/.nodenv"
if [[ -d $NODENV_ROOT ]]; then
  export PATH="$NODENV_ROOT/bin:$PATH"
  eval "$(nodenv init -)"
  alias nodenv_update='nodenv update'
fi

# ----------------------------------------------------------------------------
# RBENV
# https://github.com/rbenv/rbenv#basic-github-checkout

export RBENV_ROOT="${HOME}/.rbenv"
if [[ -d $RBENV_ROOT ]]; then
  export PATH="$RBENV_ROOT/bin:$PATH"
  eval "$(rbenv init -)"
  function rbenv_update() {
    echo "* Update rbenv"
    git -C $RBENV_ROOT pull
    echo "* Update ruby-build"
    git -C $RBENV_ROOT/plugins/ruby-build pull
    echo "* Restart shell"
  }
fi

# ----------------------------------------------------------------------------
# PYENV
# https://github.com/pyenv/pyenv#basic-github-checkout

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  function pyenv_update() {
    echo "* Update pyenv"
    git -C $PYENV_ROOT pull
    echo "* Restart shell"
  }
fi
