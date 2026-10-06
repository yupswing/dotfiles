-- Valori condivisi tra i vari file di config.

local M = {}

M.mod = "ALT"

M.terminal = "kitty"
M.file_manager = "nemo"
M.menu = "anyrun"

M.monitors = {
  front = "HDMI-A-1", -- monitor esterno
  side = "eDP-1", -- portatile
}

-- Unica fonte di verità per i workspace: da qui nascono sia le workspace rule
-- (conf/monitors.lua) sia i keybind mod+key / mod+SHIFT+key (conf/binds.lua).
M.workspaces = {
  { name = "!0:float", key = "backslash", monitor = M.monitors.front },
  { name = "!1:im", key = "minus", monitor = M.monitors.front },
  { name = "!2:mail", key = "equal", monitor = M.monitors.side },
  { name = "!3:music", key = "grave", monitor = M.monitors.side },
  { name = "01:web", key = "1", monitor = M.monitors.front },
  { name = "02:code", key = "2", monitor = M.monitors.front },
  { name = "03:term", key = "3", monitor = M.monitors.side },
  { name = "04", key = "4", monitor = M.monitors.side },
  { name = "05", key = "5", monitor = M.monitors.front },
  { name = "06", key = "6", monitor = M.monitors.side },
  { name = "07", key = "7", monitor = M.monitors.front },
  { name = "08", key = "8", monitor = M.monitors.side },
  { name = "09", key = "9", monitor = M.monitors.front },
  { name = "10", key = "0", monitor = M.monitors.side },
}

-- Selettore Hyprland per un workspace con nome.
function M.ws(name)
  return "name:" .. name
end

-- Colori generati da pywal (~/.config/wal/templates/hyprland.lua).
-- Se il file non esiste ancora (wal mai eseguito) resta una tabella vuota.
local wal = loadfile(os.getenv("HOME") .. "/.cache/wal/hyprland.lua")
M.colors = wal and wal() or {}

return M
