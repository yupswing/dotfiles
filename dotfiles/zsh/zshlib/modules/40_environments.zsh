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
  function nodenv_list() {
    echo " # nodenv install -l\n # filtered to show only last node versions\n"
    nodenv install -l | \grep -P '^\s*\d+\.\d+\.\d+$' | awk -F. '{a[$1]=$0} END {for (i in a) print a[i]}'
    echo "\n # nodenv global"
    nodenv global
  }
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
  function rbenv_list() {
    echo " # rbenv install -l\n # filtered to show only last ruby versions\n"
    rbenv install -l | \grep -P '^\s*\d+\.\d+\.\d+$'
    echo "\n # rbenv global"
    rbenv global
  }
fi

# ----------------------------------------------------------------------------
# PYENV
# - https://github.com/pyenv/pyenv#basic-github-checkout
# - https://github.com/pyenv/pyenv-update

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d $PYENV_ROOT ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init -)"
  function pyenv_list() {
    echo " # pyenv install -l\n # filtered to show only last python versions\n"
    pyenv install -l | \grep -P '^\s*\d+\.\d+\.\d+$' | awk -F. '{a[$1$2]=$0} END {for (i in a) print a[i]}' | sort
    echo "\n # pyenv global"
    pyenv global
  }
fi

# ----------------------------------------------------------------------------

function updatenv() {
  (( $+commands[nodenv] )) && echo "\n=== NODENV Update ===" && nodenv update
  (( $+commands[rbenv] )) && echo "\n=== RBENV Update ===" && rbenv update
  (( $+commands[pyenv] )) && echo "\n=== PYENV Update ===" && pyenv update
}
