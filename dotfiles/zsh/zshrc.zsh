# ----------------------------------------------------------------------------
# ================================== ZSHRC ===================================
# ----------------------------------------------------------------------------

# # Profiling
# zmodload zsh/zprof

# ----------------------------------------------------------------------------

# P10K INSTANT PROMPT
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------------------------------------------------

source $YUPZSHRC_HOME/loader.zsh

# ----------------------------------------------------------------------------

# Add stuff to path:
#   PATH="whatever:$PATH"
#
# If you want to edit environments variables please do in `zshenv.zsh`
#   (like EDITOR or LANGUAGE)
#
#
#                  ##################################
#                  ### Your stuff from here on :) ###
#                  ##################################

# ----------------------------------------------------------------------------
# BACKUP
# `backup` run an rsync one-way from source to destination
# BACKUP_SOURCE='/home/simo'
# BACKUP_DESTINATION='/Volumes/FoxBackup'
# alias backup="rsync -av --delete --exclude-from ~/.rsync-exclude ${BACKUP_SOURCE} ${BACKUP_DESTINATION}"
# ----------------------------------------------------------------------------
