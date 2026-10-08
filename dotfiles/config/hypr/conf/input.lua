-- Input
-- Doc: https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    kb_layout = "us",
    kb_options = "compose:ralt", -- AltGr come tasto Compose (come su X11, xprofile)
    numlock_by_default = true,

    follow_mouse = 1,
    sensitivity = 0, -- -1.0..1.0

    touchpad = {
      natural_scroll = true,
    },
  },
})

-- Swipe a 3 dita tra workspace
-- Doc: https://wiki.hypr.land/Configuring/Basics/Binds/Gestures/
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})
