#######################################################################################
# Dotdrop
# see: https://github.com/deadc0de6/dotdrop/wiki

export DOTREPO="$HOME/dotfiles"
alias dotdrop="$DOTREPO/dotdrop.sh -b"
alias dotgit="git -C $DOTREPO"
alias dotinstall="$DOTREPO/dotdrop.sh install -fb"
alias dotupdate="$DOTREPO/dotdrop.sh update -b"
alias dotcompare="$DOTREPO/dotdrop.sh compare -b"
alias dotremove="$DOTREPO/dotdrop.sh remove -b"

# use `bak` to remove `*.dotdropbak` files
