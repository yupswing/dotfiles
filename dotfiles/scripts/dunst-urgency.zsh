#!/usr/bin/env zsh

# Regola dunst (script = ...): marca urgent la finestra dell'app che ha mandato
# la notifica, così la barra colora il suo workspace.

# Exit if DUNST_DESKTOP_ENTRY is not available
[[ -z $DUNST_DESKTOP_ENTRY ]] && exit

# dunstrc è lo stesso per tutte le sessioni: qui si sceglie solo lo script
if [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]]; then
  exec $HOME/.scripts/way-dunst-urgency.zsh
else
  exec $HOME/.scripts/x11-dunst-urgency.zsh
fi
