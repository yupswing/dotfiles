-- Variabili d'ambiente
-- Doc: https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Forza Electron/Chromium/VS Code su Wayland (Ozone)
hl.env("ELECTRON_ENABLE_WAYLAND", "1")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("OZONE_PLATFORM_HINT", "auto")
hl.env("GTK_USE_PORTAL", "1")

-- Alcune cose per app specifiche
hl.env("KITTY_ENABLE_WAYLAND", "1")

-- #TAG_LINUX_THEME
-- GTK: forza tema Mojave-Dark (oltre ai settings.ini)
hl.env("GTK_THEME", "Mojave-Dark")
hl.env("GTK_APPLICATION_PREFER_DARK_THEME", "1")
-- Qt
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
