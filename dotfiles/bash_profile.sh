# {{@@ header() @@}}
# FILE: ~/.bash_profile

export NODENV_ROOT="$HOME/.nodenv"
export PATH="$NODENV_ROOT/bin:$PATH"
if command -v nodenv 1>/dev/null 2>&1; then
  eval "$(nodenv init -)"
fi

export RBENV_ROOT="$HOME/.rbenv"
export PATH="$RBENV_ROOT/bin:$PATH"
if command -v rbenv 1>/dev/null 2>&1; then
  eval "$(rbenv init -)"
fi

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi
