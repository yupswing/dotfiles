#######################################################################################
# GIT

alias gl='git pull'
alias gp='git push'

alias gs='git status -sb'

alias gc='git commit'
alias gcj='gitmoji -c'

alias ga='git add'
alias gaa='git add --all'

alias gk='git checkout'
alias gm='git merge'

alias gba='git branch -a'

alias grs='git reset --soft HEAD~1'

alias gd='git diff'
alias gds='git diff --staged'
alias gdl='git diff HEAD^1..HEAD'
# alias gdc='git diff-tree --no-commit-id --name-only -r'
alias gst='git show --stat --oneline'
alias gsu='git submodule foreach git pull origin master'

# alias glb='git log --graph --decorate --oneline'
alias glb="git log --graph --decorate --date-order --date=format:'%Y-%m-%d' --format='%C(auto)%h %C(cyan)%cd%Creset %s%C(auto)%d %C(green)%cn %C(cyan)(%cr)'"

# function ginit() {
#   git init
#   git remote add origin $GITHUB$*
#   git pull origin master
#   git push origin master
# }

function glall() {
  find . -maxdepth 1 -type d | while read line; do
    if [[ -d $line/.git ]]; then
      echo "\n❯ git -C $line pull"
      git -C $line pull
    fi
  done
}
