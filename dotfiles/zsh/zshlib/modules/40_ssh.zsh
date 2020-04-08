# Also need `AddKeysToAgent yes` in `.ssh/config`
# see: https://superuser.com/questions/1152833/save-identities-added-by-ssh-add-so-they-persist

# Define SSH_AUTH_SOCK as a specific file
# (so for the session it does ask for the password just once per certificate)
export SSH_AUTH_SOCK="/tmp/ssh-agent.${USER}.${HOST}.sock"
eval ssh-agent -a "${SSH_AUTH_SOCK}" 2>/dev/null >/dev/null

# Add key at startup
# ssh-add -L | grep "$(awk -F' ' '{print $2}' ${HOME}/.ssh/*.pub)" &>/dev/null
# if [[ ! 0 == $? ]]; then
#   ssh-add
# fi
