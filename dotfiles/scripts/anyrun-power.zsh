#!/usr/bin/env zsh
set -euo pipefail

# --- Config personali ---------------------------------------------------------
LOCKER="${HOME}/.scripts/wayland-lock.zsh"

WM_QUIT_CMD="hyprctl dispatch exit"
# -----------------------------------------------------------------------------

# Coppie [label, comando] come nel tuo script
typeset -a MENU
MENU=(
  '  Power-off system'    'systemctl poweroff'
  '  Reboot system'       'systemctl reboot'
  '  End session'         '${=WM_QUIT_CMD}'
  '  Lock screen'         '${=LOCKER}'
  '  Suspend system'      '${=LOCKER} && systemctl suspend'
  # '  Hibernate system'  '${=LOCKER} && systemctl hibernate'  # attenzione con ZFS
)

# Split in etichette e comandi
labels=()
cmds=()
for ((i=1; i<=${#MENU}; i++)); do
  if (( i % 2 )); then
    labels+=("${MENU[i]}")
  else
    cmds+=("${MENU[i]}")
  fi
done

# Mostra il menu con anyrun (stdin plugin)
selected="$(printf '%s\n' "${labels[@]}" | anyrun --plugins libstdin.so --show-results-immediately true)"

# Niente selezione → esci
[[ -z "${selected:-}" ]] && exit 0

# Trova l'indice dell'etichetta scelta
sel_index=-1
for ((j=1; j<=${#labels}; j++)); do
  [[ "${labels[j]}" == "${selected}" ]] && sel_index=$j && break
done
(( sel_index == -1 )) && exit 1

# Esegui il comando associato (espansione variabili + &&)
eval "${cmds[sel_index]}"
