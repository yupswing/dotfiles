# ----------------------------------------------------------------------------
# NODENV
# https://github.com/nodenv/nodenv#basic-github-checkout
# https://github.com/nodenv/node-build#installation (for `nodenv install`)

export NODENV_ROOT="${HOME}/.nodenv"
if [[ -d $NODENV_ROOT ]]; then
  export PATH="$NODENV_ROOT/bin:$PATH"
  eval "$(nodenv init -)"
fi

# ----------------------------------------------------------------------------
# RBENV
# https://github.com/rbenv/rbenv#basic-github-checkout

export RBENV_ROOT="${HOME}/.rbenv"
if [[ -d $RBENV_ROOT ]]; then
  export PATH="$RBENV_ROOT/bin:$PATH"
  eval "$(rbenv init -)"
fi

# ----------------------------------------------------------------------------
# PYENV
# https://github.com/pyenv/pyenv#basic-github-checkout

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
fi
