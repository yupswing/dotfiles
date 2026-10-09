-- Keybindings
-- Doc: https://wiki.hypr.land/Configuring/Basics/Binds/
-- Nomi dei tasti: quelli di xkbcommon-keysyms.h senza XKB_KEY_ (o `wev`)
local vars = require("conf._vars")
local mod = vars.mod
local exec = hl.dsp.exec_cmd

-- Ogni bind ha una description (in inglese): la mostra il menu dei bind
-- (~/.scripts/binds.py, mod + F1), che legge `hyprctl binds`.
-- opts(desc, extra): le opzioni di hl.bind con la description, più `extra`.
local function opts(desc, extra)
  local t = { description = desc }
  for k, v in pairs(extra or {}) do
    t[k] = v
  end
  return t
end

-- "!1:im" -> "im"
local function label(name)
  return (name:gsub("^.-:", ""))
end

hl.bind(mod .. " + Q", hl.dsp.window.close(), opts("Close the active window"))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.window.kill(), opts("Force kill the active window"))
-- hl.bind(mod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mod .. " + E", exec(vars.file_manager), opts("Open the file manager"))
hl.bind(
  mod .. " + B",
  hl.dsp.window.float({
    action = "toggle",
  }),
  opts("Toggle floating")
)
hl.bind(mod .. " + N", hl.dsp.window.pseudo(), opts("Toggle pseudo-tiling"))
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = 0 }), opts("Toggle fullscreen"))
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = 1 }), opts("Toggle maximized"))

hl.bind(mod .. " + Return", exec(vars.terminal), opts("Open a terminal"))

-- rofi (stessi tasti e stessi script di sxhkdrc)
hl.bind(mod .. " + space", exec(vars.menu), opts("Application launcher"))
hl.bind(mod .. " + SHIFT + space", exec("rofi -show run"), opts("Run a command from $PATH"))
hl.bind(mod .. " + Tab", exec("rofi -show window -show-icons"), opts("Window switcher"))
hl.bind(mod .. " + SHIFT + F", exec("~/.scripts/locate.zsh"), opts("Search files (locate)"))
hl.bind(mod .. " + P", exec("~/.scripts/power.zsh"), opts("Power menu"))
hl.bind(mod .. " + L", exec("~/.scripts/lock.zsh"), opts("Lock the screen"))
hl.bind(mod .. " + C", exec("~/.scripts/clipboard.zsh --rofi"), opts("Clipboard history"))
hl.bind(mod .. " + CTRL + C", exec("~/.scripts/clipboard.zsh --clear"), opts("Clear the clipboard history"))
hl.bind(mod .. " + SHIFT + C", exec("~/.scripts/calculator.zsh --rofi"), opts("Calculator"))
hl.bind(mod .. " + SHIFT + CTRL + C", exec("~/.scripts/calculator.zsh --clear"), opts("Clear the calculator history"))
hl.bind(mod .. " + period", exec("~/.scripts/glyphs.py --emoji"), opts("Emoji picker"))
hl.bind(mod .. " + SHIFT + period", exec("~/.scripts/glyphs.py --nerd"), opts("Nerd Font icon picker"))
hl.bind(mod .. " + F1", exec("~/.scripts/binds.py"), opts("Show all the keybinds"))
hl.bind(mod .. " + K", exec("~/.scripts/colors.py"), opts("Pick a color from the screen"))
hl.bind(mod .. " + SHIFT + K", exec("~/.scripts/colors.py --history"), opts("Colors used before"))
hl.bind(mod .. " + CTRL + K", exec("~/.scripts/colors.py --input"), opts("Type a color to convert"))
-- Richiama l'ultima notifica chiusa (mod + N è già la pseudo-tile)
-- hl.bind(mod .. " + SHIFT + N", exec("dunstctl history-pop"))

-- Screenshot con grim+slurp (stessi tasti di sxhkdrc)
hl.bind("Print", exec("~/.scripts/screenshot.zsh"), opts("Screenshot of the screen"))
hl.bind("SHIFT + Print", exec("~/.scripts/screenshot.zsh --select"), opts("Screenshot of a selected area"))
hl.bind("CTRL + Print", exec("~/.scripts/screenshot.zsh --open"), opts("Open the screenshots folder"))

-- Focus con mod + frecce, swap nel tiling con mod + SHIFT + frecce
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind(
    mod .. " + " .. dir,
    hl.dsp.focus({
      direction = dir,
    }),
    opts("Focus " .. dir)
  )
  hl.bind(
    mod .. " + SHIFT + " .. dir,
    hl.dsp.window.swap({
      direction = dir,
    }),
    opts("Swap the window " .. dir)
  )
end

-- Workspace: mod + tasto per andarci, mod + SHIFT + tasto per spostarci la
-- finestra attiva senza seguirla (follow = true per seguirla)
for _, ws in ipairs(vars.workspaces) do
  local target = vars.ws(ws.name)
  hl.bind(
    mod .. " + " .. ws.key,
    hl.dsp.focus({
      workspace = target,
    }),
    opts("Go to workspace " .. label(ws.name))
  )
  hl.bind(
    mod .. " + SHIFT + " .. ws.key,
    hl.dsp.window.move({
      workspace = target,
      follow = false,
    }),
    opts("Move the window to workspace " .. label(ws.name))
  )
end

-- Albero dwindle, come in bspwm (stessi tasti di sxhkdrc)
-- Doc: https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- mod + CTRL + frecce: preseleziona dove si aprirà la prossima finestra
for dir, short in pairs({
  left = "l",
  right = "r",
  up = "u",
  down = "d",
}) do
  hl.bind(mod .. " + CTRL + " .. dir, hl.dsp.layout("preselect " .. short), opts("Preselect the next window " .. dir))
end
-- mod + SHIFT + PagSu/PagGiù: ruota lo split della finestra attiva
hl.bind(mod .. " + SHIFT + Prior", hl.dsp.layout("rotatesplit -90"), opts("Rotate the split counterclockwise"))
hl.bind(mod .. " + SHIFT + Next", hl.dsp.layout("rotatesplit 90"), opts("Rotate the split clockwise"))

-- Special workspace (scratchpad)
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"), opts("Toggle the scratchpad"))
hl.bind(
  mod .. " + SHIFT + S",
  hl.dsp.window.move({
    workspace = "special:magic",
  }),
  opts("Move the window to the scratchpad")
)

-- Scorri i workspace esistenti con mod + scroll
hl.bind(
  mod .. " + mouse_down",
  hl.dsp.focus({
    workspace = "e+1",
  }),
  opts("Next workspace")
)
hl.bind(
  mod .. " + mouse_up",
  hl.dsp.focus({
    workspace = "e-1",
  }),
  opts("Previous workspace")
)

-- Sposta/ridimensiona finestre con mod + LMB/RMB e trascinamento
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), opts("Move the window (drag)", { mouse = true }))
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), opts("Resize the window (drag)", { mouse = true }))

-- Tasti multimediali: volume e luminosità (anche a schermo bloccato)
local held = {
  locked = true,
  repeating = true,
}
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), opts("Volume up", held))
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), opts("Volume down", held))
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), opts("Mute the speakers", held))
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), opts("Mute the microphone", held))
-- Luminosità: disattivata (non usata; brightnessctl non è installato)
-- hl.bind("XF86MonBrightnessUp", exec("brightnessctl s 10%+"), opts("Brightness up", held))
-- hl.bind("XF86MonBrightnessDown", exec("brightnessctl s 10%-"), opts("Brightness down", held))

-- Requires playerctl
hl.bind("XF86AudioNext", exec("playerctl next"), opts("Next track", { locked = true }))
hl.bind("XF86AudioPause", exec("playerctl play-pause"), opts("Pause", { locked = true }))
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), opts("Play / pause", { locked = true }))
hl.bind("XF86AudioPrev", exec("playerctl previous"), opts("Previous track", { locked = true }))

-- Chord "apps": mod + X, poi una lettera per lanciare l'app.
-- Il secondo argomento "reset" chiude la submap dopo ogni bind eseguito.
-- Doc: https://wiki.hypr.land/Configuring/Basics/Binds/Submaps/
local apps = {
  C = "google-chrome-stable",
  S = "spotify",
  E = "enpass",
  F = "firefox",
  D = "discord",
}

hl.bind(mod .. " + X", hl.dsp.submap("apps"), opts("Open the apps chord (then C, S, E, F, D)"))

hl.define_submap("apps", "reset", function()
  for key, cmd in pairs(apps) do
    hl.bind(key, exec(cmd), opts("Launch " .. cmd))
  end

  -- Uscite senza lanciare niente
  for _, key in ipairs({ "escape", "backspace", "space" }) do
    hl.bind(key, hl.dsp.submap("reset"), opts("Leave the app chord"))
  end
end)

--------------------------------------------------------------------------------

-- Schermo on/off (utile anche per il bug nvidia in cui lo schermo diventa nero).
-- Il bind spegne soltanto: a riaccendere ci pensa qualsiasi tasto
-- (misc.key_press_enables_dpms in look.lua), quindi anche ripremere MOD + O.
-- Un vero toggle non servirebbe: a schermo spento la pressione di MOD lo
-- riaccende prima ancora che scatti il bind.
-- Il ritardo evita che il rilascio dei tasti riaccenda subito lo schermo.
hl.bind(mod .. " + O", function()
  hl.timer(function()
    hl.dispatch(hl.dsp.dpms({
      action = "disable",
    }))
  end, {
    timeout = 500,
    type = "oneshot",
  })
end, opts("Turn the screen off", { locked = true }))
