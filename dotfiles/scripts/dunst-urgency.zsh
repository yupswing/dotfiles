#!/usr/bin/env zsh

# Regola dunst (script = ...): marca urgent la finestra dell'app che ha mandato
# la notifica, così la barra colora il suo workspace.

# Exit if DUNST_DESKTOP_ENTRY is not available
[[ -z $DUNST_DESKTOP_ENTRY ]] && exit

# hyprland: le app Electron su Wayland non chiedono attenzione da sole, ma
# rilanciandole l'istanza già aperta chiede il focus per la propria finestra.
# Con focus_on_activate = false (conf/rules.lua) Hyprland non le dà il focus e
# la marca urgent.

# Solo le app che rilanciate riusano la finestra aperta (le altre ne
# aprirebbero una nuova)
case $DUNST_DESKTOP_ENTRY in
ferdium | discord) app=$DUNST_DESKTOP_ENTRY ;;
*) exit ;;
esac

# Workspace della finestra dell'app: se non c'è (app chiusa nella tray)
# rilanciarla la riaprirebbe
workspace=$(hyprctl clients -j | jq -r --arg class $app \
  'first(.[] | select(.class == $class)) | .workspace.id')
[[ -z $workspace ]] && exit

# Inutile se quel workspace è già quello col focus
[[ $workspace == $(hyprctl activeworkspace -j | jq -r '.id') ]] && exit

timeout 10 $app &>/dev/null &!
