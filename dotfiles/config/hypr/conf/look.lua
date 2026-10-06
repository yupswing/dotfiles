-- Look and feel
-- Doc: https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
  general = {
    gaps_in = 2, -- spazio tra finestre
    gaps_out = 4, -- spazio tra finestre e bordi
    border_size = 1,

    -- Bordi: attivo con gradiente, inattivo tenue
    -- (per usare i colori di pywal: require("conf.vars").colors.color4, ecc.)
    col = {
      active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
      inactive_border = "rgba(4a4a4abb)",
    },

    resize_on_border = false,
    allow_tearing = false,

    layout = "dwindle", -- tiling dinamico
  },

  decoration = {
    rounding = 9, -- angoli arrotondati
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
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = -1, -- -1 = lascia com'è, 0/1 = disabilita wallpaper mascotte
    disable_hyprland_logo = true,
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
  hl.animation({ leaf = leaf, enabled = true, speed = speed, bezier = bezier, style = style })
end

anim("global", 6, "default")

-- Finestre (tiling + floating)
anim("windows", 5.2, "easeOut", "popin 82%")
anim("windowsIn", 5.0, "easeOut", "popin 82%")
anim("windowsOut", 3.0, "linear", "popin 82%")

-- Layer (waybar/anyrun/notifiche)
anim("layers", 4.0, "easeOut", "fade")
anim("layersIn", 4.0, "easeOut", "fade")
anim("layersOut", 2.0, "linear", "fade")

-- Fade generici
anim("fadeIn", 2.2, "easeInOut")
anim("fadeOut", 2.0, "easeInOut")
anim("fade", 2.4, "quick")

-- Workspace
anim("workspaces", 2.4, "easeInOut", "slide")
anim("workspacesIn", 2.0, "easeInOut", "fade")
anim("workspacesOut", 2.0, "easeInOut", "fade")
