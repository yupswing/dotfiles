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
-- hl.window_rule({
--   name = "no-blur-terminals",
--   match = { class = "^(kitty)$" },
--   no_blur = true,
-- })

-- Dialog
hl.window_rule({
  name = "file-dialogs",
  match = { title = "^(Save |Open ).*" },
  float = true,
  center = true,
})

-- Popup di Chrome (window.open: email aperta in finestra, login OAuth, ecc.):
-- su Wayland non hanno un ruolo come su X11 (WM_WINDOW_ROLE=pop-up), l'unica
-- cosa che li distingue è il titolo con cui nascono, "Untitled - Google Chrome"
-- (una finestra normale nasce come "New tab - Google Chrome")
local chrome_popup = "^Untitled - Google Chrome$"

-- App → workspace (il quarto campo, facoltativo, aggiunge condizioni al match)
local app_workspaces = {
  { "ferdium", "^(Ferdium|ferdium)$", "!1:im" },
  { "discord", "^(Discord|discord)$", "!1:im" },
  { "thunderbird", "^(Thunderbird|thunderbird)$", "!2:mail" },
  { "spotify", "^(Spotify|spotify)$", "!3:music" },
  { "code", "^(Code|code|code-oss|com.microsoft.VSCode)$", "02:code" },
  -- { "firefox", "^(firefox)$", "01:web" },
  -- i popup restano sul workspace da cui vengono aperti
  { "chrome", "^(Chromium|chromium|Google-chrome|google-chrome)$", "01:web", { initial_title = "negative:" .. chrome_popup } },
}

for _, app in ipairs(app_workspaces) do
  local name, class, workspace = app[1], app[2], app[3]
  local match = { class = class }
  for key, value in pairs(app[4] or {}) do
    match[key] = value
  end
  hl.window_rule({
    name = "workspace-" .. name,
    match = match,
    workspace = vars.ws(workspace),
  })
end

hl.window_rule({
  name = "chrome-popup",
  match = { class = "^(Chromium|chromium|Google-chrome|google-chrome)$", initial_title = chrome_popup },
  float = true,
  center = true,
})

-- Hack per firefox
-- PiP senza decorazioni, come quello di Chrome qui sotto
hl.window_rule({
  name = "firefox-pip",
  match = { class = "^(firefox)$", title = "^(Picture-in-Picture)$" },
  float = true,
  center = true,
  border_size = 0,
  no_blur = true,
  no_shadow = true,
  opacity = "1.0 1.0",
  stay_focused = true,
})

hl.window_rule({
  name = "firefox-toolkit",
  match = { class = "^(firefox)$", title = "^(.*Toolkit.*)$" },
  float = true,
  center = true,
  border_size = 0,
})

-- Popup PiP di Chrome (Meet cambiando tab, video, ecc.): niente decorazioni.
-- Le finestre normali nascono con titolo "... - Google Chrome", i popup PiP no
-- (es. "Meet - <codice>"): è l'unica proprietà che li distingue
hl.window_rule({
  name = "chrome-pip",
  match = { class = "^(google-chrome)$", initial_title = "negative:.* - Google Chrome$", float = true },
  border_size = 0,
  no_blur = true,
  no_shadow = true,
  opacity = "1.0 1.0",
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
  blueman = "^(blueman-manager)$",
}

for name, class in pairs(floating) do
  hl.window_rule({
    name = "float-" .. name,
    match = { class = class },
    float = true,
    center = true,
  })
end

-- -----------------------------------------------------------------------------
-- Privacy: escluse dallo screen sharing (al loro posto si vede nero)

-- lista di applicazioni escluse dallo screen sharing ()
local no_screen_share = {
  ferdium = "^(Ferdium|ferdium)$",
  discord = "^(Discord|discord)$",
}

-- lista di regole live (per poterle attivare/disattivare)
local privacy_rules = {}

for name, class in pairs(no_screen_share) do
  table.insert(
    privacy_rules,
    hl.window_rule({
      name = "no-screen-share-" .. name,
      match = { class = class },
      no_screen_share = true,
    })
  )
end

-- Notifiche dunst (namespace da `hyprctl layers`)
table.insert(
  privacy_rules,
  hl.layer_rule({
    name = "no-screen-share-notifications",
    match = { namespace = "^(notifications)$" },
    no_screen_share = true,
  })
)



-- Le regole valgono per qualsiasi cattura, screenshot compresi: lo script
-- ~/.scripts/screenshot.zsh le sospende dall'inizio alla fine della cattura con
-- `hyprctl eval 'screen_share_privacy(false)'`
function screen_share_privacy(enabled)
  for _, rule in ipairs(privacy_rules) do
    rule:set_enabled(enabled)
  end
  hl.exec_scheduled_prop_refresh_immediately()
end

-- -----------------------------------------------------------------------------

-- Urgent: le app IM non rubano il focus quando chiedono attenzione (override di
-- misc.focus_on_activate), così il workspace viene marcato urgent e waybar lo
-- colora (#workspaces button.urgent).
-- Da sole non la chiedono mai: lo fa ~/.scripts/dunst-urgency.zsh a ogni
-- notifica, rilanciandole.
local urgent = {
  ferdium = "^(Ferdium|ferdium)$",
  discord = "^(Discord|discord)$",
}

for name, class in pairs(urgent) do
  hl.window_rule({
    name = "urgent-" .. name,
    match = { class = class },
    focus_on_activate = false,
  })
end

-- -----------------------------------------------------------------------------


-- Smart gaps / no gaps when only (scommenta per provarli)
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]", gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({ name = "no-gaps-wtv1", match = { float = false, workspace = "w[tv1]" }, border_size = 0, rounding = 0 })
-- hl.window_rule({ name = "no-gaps-f1", match = { float = false, workspace = "f[1]" }, border_size = 0, rounding = 0 })
