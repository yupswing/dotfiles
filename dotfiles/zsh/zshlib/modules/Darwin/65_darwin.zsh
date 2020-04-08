# Darwin/OSX
# Environment and aliases for OSX
export LSCOLORS="GxgxcxdxCxegedabagacad"
alias aquamacs='open -a Aquamacs\ Emacs'
alias ldd='otool -L'
alias ls='ls -F -G'
alias skill=killall
alias lsrebuild='/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user'

alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
alias mvim='mvim --remote-tab-silent '
alias flushcache='sudo discoveryutil mdnsflushcache'
alias ']'='open'
