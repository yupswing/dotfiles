# Core Utils (Brew or Macports)
which gcp > /dev/null 
if [ $? -eq 0 ]; then
    if [ -f /etc/zsh/gdircolors ]; then
        eval `gdircolors /etc/zsh/gdircolors`
    else
        eval `gdircolors`
    fi
    #alias ls='gls --color -F' # OSX ls is better (supports extended attributes)
    alias ll='ls -l'
    alias la='ls -a'
    alias cp='gcp'
    alias mv='gmv'
    alias rm='grm'
    alias du='gdu'
    alias df='gdf -a'
fi

#  vim: set ts=4 sw=4 tw=0 ft=zsh : 
