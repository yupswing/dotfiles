# ----------------------------------------------------------------------------
# NODENV
# - https://github.com/nodenv/nodenv#basic-github-checkout
# - https://github.com/nodenv/node-build#installation
# - https://github.com/nodenv/nodenv-update
# - https://github.com/pine/nodenv-yarn-install

export NODENV_ROOT="${HOME}/.nodenv"
if [[ -d $NODENV_ROOT ]]; then
  export PATH="$NODENV_ROOT/bin:$PATH"
  eval "$(nodenv init -)"
  alias nodenv_list="nodenv install -l | \grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'"
fi

# ----------------------------------------------------------------------------
# RBENV
# - https://github.com/rbenv/rbenv#basic-github-checkout
# - https://github.com/rbenv/ruby-build
# - https://github.com/rkh/rbenv-update

export RBENV_ROOT="${HOME}/.rbenv"
if [[ -d $RBENV_ROOT ]]; then
  export PATH="$RBENV_ROOT/bin:$PATH"
  eval "$(rbenv init -)"
  alias rbenv_list="rbenv install -l | \grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'"
fi

# ----------------------------------------------------------------------------
# PYENV
# - https://github.com/pyenv/pyenv#basic-github-checkout
# - https://github.com/pyenv/pyenv-update

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  alias pyenv_list="pyenv install -l | \grep -E '^[0-9]+\.[0-9]+\.[0-9]+$'"
fi
