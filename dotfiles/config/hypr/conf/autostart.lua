-- Autostart
-- Doc: https://wiki.hypr.land/Configuring/Basics/Autostart/
-- hl.exec_cmd è già asincrono: niente `&` in coda.

hl.on("hyprland.start", function()
  -- Tutto ciò che parte all'avvio sta in ~/.config/autostart.sh, condiviso con
  -- bspwm/i3: la parte specifica di Hyprland è nel ramo `hyprland)`.
  hl.exec_cmd("~/.config/autostart.sh")
end)
