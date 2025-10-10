#!/usr/bin/env zsh
set -euo pipefail

# --- Config personali ---------------------------------------------------------
LOCKER=${LOCKER:-"$HOME/.scripts/wayland-lock.zsh"}

# Hyprland: end session (al posto dello script di bspwm)
END_SESSION_CMD=${END_SESSION_CMD:-"hyprctl dispatch exit"}

# --- Menu (label, cmd) --------------------------------------------------------
# NB: mantieni accoppiate label/cmd e usa && quando vuoi chaining.
MENU=(
  ' Power-off system'    'systemctl poweroff'
  ' Reboot system'       'systemctl reboot'
  ' End session'         "$END_SESSION_CMD"
  ' Lock screen'         "$LOCKER"
  ' Suspend system'      "$LOCKER && systemctl suspend"
  # ' Hibernate system'    "$LOCKER && systemctl hibernate"  # WARNING: ZFS?
)

# --- Split in LABELS / COMMANDS ----------------------------------------------
MENU_LABELS=()
MENU_COMMANDS=()
for ((i=1; i <= $#MENU; i++)); do
  if (( i % 2 )); then
    MENU_LABELS+=("${MENU[$i]}")
  else
    MENU_COMMANDS+=("${MENU[$i]}")
  fi
done

# --- Lancia wofi (dmenu mode) -------------------------------------------------
# Flag utili:
#   --dmenu        : legge opzioni da stdin, stampa la selezione su stdout
#   --prompt STR   : testo del prompt
#   --insensitive  : case-insensitive
#   --allow-markup : permette icone/font awesome se il font le contiene
# Styling/width si fanno via CSS (~/.config/wofi/style.css)
WOFI_CMD=('wofi' '--dmenu' '--prompt' '' '--insensitive' '--allow-markup')

selected="$(
  printf '%s\n' "${MENU_LABELS[@]}" | "${WOFI_CMD[@]}"
)"

# --- Nessuna selezione ---------------------------------------------------------
[[ -z "${selected:-}" ]] && exit 0

# --- Trova indice della label selezionata -------------------------------------
sel_index=0
for ((i=1; i <= ${#MENU_LABELS[@]}; i++)); do
  if [[ "${MENU_LABELS[$i]}" == "$selected" ]]; then
    sel_index=$i
    break
  fi
done
(( sel_index > 0 )) || exit 1

# --- Esegui comando corrispondente --------------------------------------------
cmd="${MENU_COMMANDS[$sel_index]}"
# Usa zsh -c per supportare variabili/&&/pipeline
exec zsh -c "$cmd"
