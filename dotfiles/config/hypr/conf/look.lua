-- Look and feel
-- Doc: https://wiki.hypr.land/Configuring/Basics/Variables/

local ROUNDED = tonumber("{{@@ ROUNDED @@}}") -- per avere il formatter

hl.config({
  general = {
    gaps_in = 2, -- spazio tra finestre
    gaps_out = 4, -- spazio tra finestre e bordi
    border_size = 1,

    -- Bordi: attivo con gradiente, inattivo tenue
    -- (per usare i colori di pywal: require("conf._vars").colors.color4, ecc.)
    col = {
      active_border = {
        colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
        angle = 45,
      },
      inactive_border = "rgba(4a4a4abb)",
    },

    resize_on_border = false,
    allow_tearing = false,

    layout = "dwindle", -- tiling dinamico
  },

  decoration = {
    rounding = ROUNDED, -- angoli arrotondati
    rounding_power = 2,

    -- Opacità piena per tiled → leggibilità massima
    active_opacity = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled = true,
      range = 10, -- ombra più morbida
      render_power = 3,
      color = "rgba(00000066)",
    },

    -- Blur: leggero e solo dove serve (layer/floating semitrasp.)
    blur = {
      enabled = true,
      size = 5,
      passes = 3,
      new_optimizations = true, -- performance migliori
      ignore_opacity = false,
      vibrancy = 0.12,
    },
  },

  animations = {
    enabled = true,
  },

  -- Doc: https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/
  dwindle = {
    -- Comportamento alla bspwm: albero binario con split permanenti,
    -- la nuova finestra divide quella attiva e va a destra/sotto, 50/50
    preserve_split = true, -- lo split non cambia quando ridimensioni/muovi
    force_split = 2, -- nuova finestra sempre a destra/sotto (second_child)
    smart_split = false, -- true = direzione scelta dalla posizione del cursore
    use_active_for_splits = true, -- dividi la finestra attiva, non quella sotto al mouse
    default_split_ratio = 1.0, -- 1.0 = 50/50 (split_ratio 0.5 di bspwm)
    smart_resizing = true,
  },

  -- Doc: https://wiki.hypr.land/Configuring/Layouts/Master-Layout/
  master = {
    new_status = "slave", -- le nuove finestre vanno nella pila: la master resta la prima
  },

  misc = {
    force_default_wallpaper = -1, -- -1 = lascia com'è, 0/1 = disabilita wallpaper mascotte
    disable_hyprland_logo = true,
    focus_on_activate = true, -- segui le finestre che chiedono il focus (es. link aperto nel browser su un altro workspace)
    -- We want keyboard events to wake up the screen, but not mouse ones:
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = false,
  },
})

-- Animazioni: rapide, curve moderne, niente lag
-- Doc: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOut", { type = "bezier", points = { { 0.2, 0.9 }, { 0.2, 1 } } })
hl.curve("easeInOut", { type = "bezier", points = { { 0.4, 0 }, { 0.2, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

-- speed è in decimi di secondo: 5 = 500ms
local function anim(leaf, speed, bezier, style)
  hl.animation({
    leaf = leaf,
    enabled = true,
    speed = speed,
    bezier = bezier,
    style = style,
  })
end

anim("global", 6, "default")

-- Finestre: aprono crescendo dal X% + fade, chiudono speculari (più rapide),
-- senza overshoot; il tiling fa spazio in fretta così il fade della nuova
-- finestra non si sovrappone alle altre ancora in movimento
anim("windows", 2.6, "easeOut", "popin 80%")
anim("windowsIn", 2.6, "easeOut", "popin 80%")
anim("windowsOut", 2.2, "quick", "popin 60%")
anim("windowsMove", 1.6, "quick")

-- Layer (rofi, menu): pop leggero; le notifiche hanno la loro regola sotto
anim("layers", 3.0, "easeOut", "popin 80%")
anim("layersIn", 3.0, "easeOut", "popin 80%")
anim("layersOut", 1.8, "quick", "popin 60%")

-- Fade generici
anim("fadeIn", 2.6, "easeInOut")
anim("fadeOut", 2.0, "easeInOut")
anim("fade", 2.4, "quick")

-- Bordo: il colore sfuma quando cambia il focus
anim("border", 5.0, "easeInOut")

-- Workspace: slide orizzontale; quelli speciali entrano dal basso
anim("workspaces", 3.2, "easeInOut", "slide")
anim("specialWorkspace", 3.2, "easeInOut", "slidevert")

-- Notifiche dunst: entrano scivolando da destra; sfondo semitrasparente
-- (alpha in dunst/dunstrc) sfocato come rofi
hl.layer_rule({
  name = "notifications-look",
  match = {
    namespace = "^(notifications)$",
  },
  animation = "slide right",
  blur = true,
  ignore_alpha = 0.3,
})

-- Rofi: il resto dello schermo si abbassa di tono e lo sfondo semitrasparente
-- (alpha in rofi/config.rasi) viene sfocato
hl.layer_rule({
  name = "rofi-dim-blur",
  match = {
    namespace = "^(rofi)$",
  },
  dim_around = true,
  blur = true,
  ignore_alpha = 0.3, -- niente blur dove rofi è trasparente (angoli arrotondati)
})

-- Rofi senza animazioni, ma solo quando serve: il menu dei colori
-- (~/.scripts/colors.py) si chiude e si riapre a ogni Invio e saltellerebbe.
-- La regola nasce disattivata e lo script la attiva/disattiva con
-- `hyprctl eval "rofi_quiet:set_enabled(true)"` (globale di proposito)
rofi_quiet = hl.layer_rule({
  name = "rofi-no-anim",
  match = {
    namespace = "^(rofi)$",
  },
  no_anim = true,
  enabled = false,
})

-- Screenshot ad area: gli overlay a tutto schermo (frame congelato di
-- hyprpicker, selezione di slurp) compaiono e spariscono senza animazione
hl.layer_rule({
  name = "screenshot-no-anim",
  match = {
    namespace = "^(hyprpicker|selection)$",
  },
  no_anim = true,
})
