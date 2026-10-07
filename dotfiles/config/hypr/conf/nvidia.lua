-- F*** nvidia specific

-- Hardware acceleration on NVIDIA GPUs
-- (https://wiki.archlinux.org/title/Hardware_video_acceleration)
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

-- (https://wiki.archlinux.org/title/Wayland#Requirements)
-- NOTE: it used to crash hyprland: kept enabled on purpose, it is the first
-- thing to disable if the crashes come back
hl.env("GBM_BACKEND", "nvidia-drm")
-- To force GBM as a backend
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

-- TIP: Advantage is all the apps will be running on nvidia
-- NOTE: it used to crash whatever window was opened after "hibernate": kept
-- enabled on purpose (hibernate is not used, see rofi-power.zsh)
hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")

-- G-Sync / Adaptive Sync (VRR)
-- (https://download.nvidia.com/XFree86/Linux-32bit-ARM/375.26/README/openglenvvariables.html)
hl.env("__GL_GSYNC_ALLOWED", "1")
hl.env("__GL_VRR_ALLOWED", "1")

-- Cursore software al posto di quello hardware, se serve:
-- hl.config({ cursor = { no_hardware_cursors = 1 } })
