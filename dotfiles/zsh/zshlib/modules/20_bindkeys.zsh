#######################################################################################
# Bindkeys

# use `showkeys` to find them
# just remember \e here is same as ^[

bindkey "-e"

bindkey "\e[1~" beginning-of-line        # [HOME?]
bindkey "\e[H" beginning-of-line         # [HOME]
bindkey "\e[4~" end-of-line              # [END?]
bindkey "\e[F" end-of-line               # [END]
bindkey "\e[3~" delete-char              # [DEL]

bindkey "\eOA" history-search-backward   # 
bindkey "\eOB" history-search-forward    #
bindkey "\e[A" history-search-backward   # [UP]
bindkey "\e[B" history-search-forward    # [DOWN]

bindkey "5D" backward-word               # CTRL+[LEFT]
bindkey "5C" forward-word                # CTRL+[RIGHT]

bindkey "^W" vi-backward-kill-word       # CTRL+W
