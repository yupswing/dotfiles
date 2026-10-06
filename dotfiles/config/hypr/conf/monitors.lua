-- Monitor e workspace
-- Doc: https://wiki.hypr.land/Configuring/Basics/Monitors/
--      https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

local vars = require("conf.vars")

hl.monitor({ output = vars.monitors.front, mode = "1920x1080@60", position = "0x0", scale = 1 })
hl.monitor({ output = vars.monitors.side, mode = "1920x1080@60", position = "1920x0", scale = 1 })
-- hl.monitor({ output = vars.monitors.front, mode = "2560x1440@143.93", position = "0x0", scale = 1 })
-- hl.monitor({ output = vars.monitors.side, mode = "1920x1080@60.20", position = "2560x360", scale = 1 })

-- Qualsiasi altro monitor: risoluzione preferita, a destra degli altri
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

for _, ws in ipairs(vars.workspaces) do
  hl.workspace_rule({ workspace = vars.ws(ws.name), monitor = ws.monitor })
end

-- Evita blur su app XWayland ridimensionate (testo più nitido)
-- Doc: https://wiki.hypr.land/Configuring/Extra/XWayland/
hl.config({
  xwayland = {
    force_zero_scaling = true,
  },
})
