-- Hyprland config - "snappy & usable"
-- Obiettivo: animazioni rapide, blur leggero su layer/floating, tiling pulito,
--            swipe tra workspace. Niente effetti pacchiani.
-- Docs: https://wiki.hypr.land/Configuring/
--
-- Ogni require è uno scope separato: un errore in un file non blocca gli altri.
-- I valori condivisi (programmi, modificatore, workspace) stanno in conf/vars.lua.

require("conf.env")
require("conf.nvidia")
require("conf.monitors")
require("conf.look")
require("conf.input")
require("conf.binds")
require("conf.rules")
require("conf.hooks")
