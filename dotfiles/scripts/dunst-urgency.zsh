#!/usr/bin/env zsh

# Regola dunst (script = ...): marca urgent la finestra dell'app che ha mandato
# la notifica, così la barra colora il suo workspace.

# Exit if DUNST_DESKTOP_ENTRY is not available
[[ -z $DUNST_DESKTOP_ENTRY ]] && exit

# hyprland: le app Electron su Wayland non chiedono attenzione da sole, ma
# rilanciandole l'istanza già aperta chiede il focus per la propria finestra.
# Con focus_on_activate = false (conf/rules.lua) Hyprland non le dà il focus e
# la marca urgent.
hyprland_urgency() {
  local app workspace

  # Solo le app che rilanciate riusano la finestra aperta (le altre ne
  # aprirebbero una nuova)
  case $DUNST_DESKTOP_ENTRY in
  ferdium | discord) app=$DUNST_DESKTOP_ENTRY ;;
  *) return ;;
  esac

  # Workspace della finestra dell'app: se non c'è (app chiusa nella tray)
  # rilanciarla la riaprirebbe
  workspace=$(hyprctl clients -j | jq -r --arg class $app \
    'first(.[] | select(.class == $class)) | .workspace.id')
  [[ -z $workspace ]] && return

  # Inutile se quel workspace è già quello col focus
  [[ $workspace == $(hyprctl activeworkspace -j | jq -r '.id') ]] && return

  timeout 10 $app &>/dev/null &!
}

# x11 (bspwm): urgency hint sulla finestra
x11_urgency() {
  local name wid

  case $DUNST_DESKTOP_ENTRY in
  "ferdium")
    # DUNST_DESKTOP_ENTRY and DESKTOP_APP_NAME are lowercase, but window is uppercase
    name="Ferdium"
    ;;
  "Thunderbird")
    # DUNST_DESKTOP_ENTRY is Thunderbird
    # DESKTOP_APP_NAME is thunderbird
    # window are present in both, but we need to use the first match of thunderbird
    name="thunderbird"
    ;;
  *)
    name=$DUNST_DESKTOP_ENTRY
    ;;
  esac

  # # WM INDEPENDENT SET URGENT (to be tested)
  # Get lowest numeric id (is it a wid? it does not look like it) and make it urgent
  # (lowest because it is probably the main window)
  # (It does not work with Thunderbird, the main window is a random one in the list)
  # xdotool set_window --urgency 1 \
  #     "$(xdotool search --name "${name}" | sort -n | head -n1)" \
  #      &> /dev/null

  # BSPWM SET URGENT
  # Get all WID related to appname (from actual shown app in bspc)
  wid=$(comm -12 <(bspc query -N | sort) <(xdo id -N $name | sort))
  [[ -z $wid ]] && return

  # Get first WID (if more than one)
  wid=$(echo $wid | head -n1)

  # xdo activate $wid
  # Set urgency on WID
  xdotool set_window --urgency 1 $wid
}

if [[ -n $HYPRLAND_INSTANCE_SIGNATURE ]]; then
  hyprland_urgency
else
  x11_urgency
fi
