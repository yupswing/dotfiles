#######################################################################################
# GIT

alias gl='git pull'
alias gp='git push'

alias gs='git status -sb'

alias gc='git commit'
alias gcj='gitmoji -c'

alias ga='git add'
alias gaa='git add --all'

alias gr='git rm'

alias gk='git checkout'
alias gm='git merge'

alias gd='git diff'
alias gds='git diff --staged'

alias gsu='git submodule foreach git pull origin master'

# function ginit() {
#   git init
#   git remote add origin $GITHUB$*
#   git pull origin master
#   git push origin master
# }

function glall() {
  find . -maxdepth 1 -type d  | while read line; do
    if [[ -d $line/.git ]]; then
      echo "\n❯ git -C $line pull"
      git -C $line pull
    fi
  done
}
