-- Regole finestre
-- Doc: https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- Classe/titolo di una finestra: `hyprctl clients` o `hyprctl activewindow`.
-- A parità di effetto vince l'ultima regola che fa match.

local vars = require("conf.vars")

-- Ignora richieste di maximize da app (meglio col tiling)
hl.window_rule({
  name = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix trascinamenti strani con alcune app XWayland "vuote"
hl.window_rule({
  name = "fix-xwayland-drags",
  match = {
    class = "^$",
    title = "^$",
    xwayland = true,
    float = true,
    fullscreen = false,
    pin = false,
  },
  no_focus = true,
})

-- Opacità leggera SOLO per floating (dialog, picker, ecc.):
-- il tiling resta opaco al 100% per leggibilità
hl.window_rule({
  name = "floating-opacity",
  match = { float = true },
  opacity = "0.96 0.92",
})

-- Niente blur su terminali per testo più nitido
hl.window_rule({
  name = "no-blur-terminals",
  match = { class = "^(kitty)$" },
  no_blur = true,
})

-- Dialog
hl.window_rule({
  name = "file-dialogs",
  match = { title = "^(Save |Open ).*" },
  float = true,
  center = true,
})

-- App → workspace
local app_workspaces = {
  { "ferdium", "^(Ferdium|ferdium)$", "!1:im" },
  { "discord", "^(Discord|discord)$", "!1:im" },
  { "thunderbird", "^(Thunderbird|thunderbird)$", "!2:mail" },
  { "spotify", "^(Spotify|spotify)$", "!3:music" },
  { "code", "^(Code|code|code-oss|com.microsoft.VSCode)$", "02:code" },
  { "firefox", "^(firefox)$", "01:web" },
  { "chrome", "^(Chromium|chromium|Google-chrome|google-chrome)$", "01:web" },
}

for _, app in ipairs(app_workspaces) do
  local name, class, workspace = app[1], app[2], app[3]
  hl.window_rule({
    name = "workspace-" .. name,
    match = { class = class },
    workspace = vars.ws(workspace),
  })
end

-- Hack per firefox
hl.window_rule({
  name = "firefox-pip",
  match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },
  float = true,
  center = true,
  border_size = 0,
  stay_focused = true,
})

hl.window_rule({
  name = "firefox-toolkit",
  match = { class = "^(firefox)$", title = "^(.*Toolkit.*)$" },
  float = true,
  center = true,
  border_size = 0,
})

-- Float, center e pin
hl.window_rule({
  name = "float-enpass",
  match = { class = "^(Enpass|enpass)$" },
  float = true,
  center = true,
  pin = true,
})

-- Float, center
local floating = {
  simplenote = "^(Simplenote|simplenote)$",
  pavucontrol = "^(Pavucontrol|pavucontrol|org.pulseaudio.pavucontrol)$",
  seahorse = "^(Seahorse|seahorse)$",
  nemo = "^(Nemo|nemo)$",
  gpick = "^(Gpick|gpick)$",
  ["file-roller"] = "^(file-roller)$",
  lxappearance = "^(Lxappearance|lxappearance)$",
}

for name, class in pairs(floating) do
  hl.window_rule({
    name = "float-" .. name,
    match = { class = class },
    float = true,
    center = true,
  })
end

-- Privacy: escluse dallo screen sharing (al loro posto si vede nero)
local no_screen_share = {
  ferdium = "^(Ferdium|ferdium)$",
  discord = "^(Discord|discord)$",
}

for name, class in pairs(no_screen_share) do
  hl.window_rule({
    name = "no-screen-share-" .. name,
    match = { class = class },
    no_screen_share = true,
  })
end

-- Notifiche dunst (namespace da `hyprctl layers`)
hl.layer_rule({
  name = "no-screen-share-notifications",
  match = { namespace = "^(notifications)$" },
  no_screen_share = true,
})

-- Smart gaps / no gaps when only (scommenta per provarli)
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1", match = { float = false, workspace = "f[1]" }, border_size = 0, rounding = 0 })
