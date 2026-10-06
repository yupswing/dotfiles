-- Keybindings
-- Doc: https://wiki.hypr.land/Configuring/Basics/Binds/
-- Nomi dei tasti: quelli di xkbcommon-keysyms.h senza XKB_KEY_ (o `wev`)

local vars = require("conf.vars")
local mod = vars.mod
local exec = hl.dsp.exec_cmd

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + M", hl.dsp.exit())
hl.bind(mod .. " + E", exec(vars.file_manager))
hl.bind(mod .. " + B", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + N", hl.dsp.window.pseudo()) -- dwindle

hl.bind(mod .. " + Return", exec(vars.terminal))

-- rofi (stessi tasti e stessi script di sxhkdrc)
hl.bind(mod .. " + space", exec(vars.menu)) -- applicazioni (.desktop)
hl.bind(mod .. " + SHIFT + space", exec("rofi -show run")) -- eseguibili nel $PATH
hl.bind(mod .. " + Tab", exec("rofi -show window -show-icons"))
hl.bind(mod .. " + P", exec("~/.scripts/rofi-power.zsh"))
hl.bind(mod .. " + L", exec("pidof hyprlock || hyprlock")) -- blocca lo schermo
hl.bind(mod .. " + C", exec("~/.scripts/clipboard.zsh --rofi")) -- cliphist
hl.bind(mod .. " + CTRL + C", exec("~/.scripts/clipboard.zsh --clear"))
hl.bind(mod .. " + SHIFT + C", exec("~/.scripts/calculator.zsh --rofi"))
hl.bind(mod .. " + SHIFT + CTRL + C", exec("~/.scripts/calculator.zsh --clear"))

-- Screenshot con grim+slurp (stessi tasti di sxhkdrc)
hl.bind("Print", exec("~/.scripts/screenshot.zsh"))
hl.bind("SHIFT + Print", exec("~/.scripts/screenshot.zsh --select")) -- area
hl.bind("CTRL + Print", exec("~/.scripts/screenshot.zsh --open")) -- apre la cartella

-- Focus con mod + frecce, swap nel tiling con mod + SHIFT + frecce
for _, dir in ipairs({ "left", "right", "up", "down" }) do
  hl.bind(mod .. " + " .. dir, hl.dsp.focus({ direction = dir }))
  hl.bind(mod .. " + SHIFT + " .. dir, hl.dsp.window.swap({ direction = dir }))
end

-- Workspace: mod + tasto per andarci, mod + SHIFT + tasto per spostarci la
-- finestra attiva senza seguirla (follow = true per seguirla)
for _, ws in ipairs(vars.workspaces) do
  local target = vars.ws(ws.name)
  hl.bind(mod .. " + " .. ws.key, hl.dsp.focus({ workspace = target }))
  hl.bind(mod .. " + SHIFT + " .. ws.key, hl.dsp.window.move({ workspace = target, follow = false }))
end

-- Albero dwindle, come in bspwm (stessi tasti di sxhkdrc)
-- Doc: https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
-- mod + CTRL + frecce: preseleziona dove si aprirà la prossima finestra
for dir, short in pairs({ left = "l", right = "r", up = "u", down = "d" }) do
  hl.bind(mod .. " + CTRL + " .. dir, hl.dsp.layout("preselect " .. short))
end
-- mod + SHIFT + PagSu/PagGiù: ruota lo split della finestra attiva
hl.bind(mod .. " + SHIFT + Prior", hl.dsp.layout("rotatesplit -90"))
hl.bind(mod .. " + SHIFT + Next", hl.dsp.layout("rotatesplit 90"))

-- Special workspace (scratchpad)
hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scorri i workspace esistenti con mod + scroll
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Sposta/ridimensiona finestre con mod + LMB/RMB e trascinamento
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Tasti multimediali: volume e luminosità (anche a schermo bloccato)
local held = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), held)
hl.bind("XF86AudioLowerVolume", exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), held)
hl.bind("XF86AudioMute", exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), held)
hl.bind("XF86AudioMicMute", exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), held)
hl.bind("XF86MonBrightnessUp", exec("brightnessctl s 10%+"), held)
hl.bind("XF86MonBrightnessDown", exec("brightnessctl s 10%-"), held)

-- Requires playerctl
hl.bind("XF86AudioNext", exec("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", exec("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", exec("playerctl previous"), { locked = true })

-- Chord "apps": mod + X, poi una lettera per lanciare l'app.
-- Il secondo argomento "reset" chiude la submap dopo ogni bind eseguito.
-- Doc: https://wiki.hypr.land/Configuring/Basics/Binds/Submaps/
local apps = {
  C = "google-chrome-stable",
  S = "spotify",
  E = "enpass",
  N = "nemo",
  F = "firefox",
  D = "discord",
}

hl.bind(mod .. " + X", hl.dsp.submap("apps"))

hl.define_submap("apps", "reset", function()
  for key, cmd in pairs(apps) do
    hl.bind(key, exec(cmd))
  end

  -- Uscite senza lanciare niente
  for _, key in ipairs({ "escape", "backspace", "space" }) do
    hl.bind(key, hl.dsp.submap("reset"))
  end
end)
