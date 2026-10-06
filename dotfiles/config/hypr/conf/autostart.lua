-- Autostart
-- Doc: https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.exec_cmd è già asincrono: niente `&` in coda.

hl.on("hyprland.start", function()
  -- Portali: se il user manager di systemd sopravvive tra una sessione e l'altra
  -- (es. passaggio da bspwm), xdg-desktop-portal e i backend restano vivi con
  -- l'ambiente vecchio (niente WAYLAND_DISPLAY) e non riescono ad aprire finestre.
  -- Reimporta l'ambiente e riavviali a ogni avvio di Hyprland.
  hl.exec_cmd(
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
      .. " && systemctl --user stop xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk"
      .. " && systemctl --user start xdg-desktop-portal"
  )

  hl.exec_cmd("waybar") -- https://github.com/Alexays/Waybar
  hl.exec_cmd("hyprpaper") -- https://wiki.hypr.land/Hypr-Ecosystem/hyprpaper/
  hl.exec_cmd("dunst")           -- https://github.com/dunst-project/dunst
  -- hl.exec_cmd("nm-applet")       -- systray network
  -- hl.exec_cmd("udiskie --tray")  -- mount tray
  -- hl.exec_cmd("wlsunset -l 44 -L 9")  -- warm screen evening (set coordinate)

  -- Clipboard manager (wayland)
  hl.exec_cmd("wl-paste --watch cliphist store")

  -- Fix per GTK
  -- hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme prefer-dark")
end)
