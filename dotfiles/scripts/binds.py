#!/usr/bin/env python3
"""Rofi list of the Hyprland keybinds, read live from `hyprctl binds -j`.

A row has the keys and the description of the bind (the `description` option of
hl.bind, see conf/binds.lua; "<no description>" if it has none). The binds of a
submap, a chord, start with the keys that enter it: "Alt + X; C". Choosing a row
does nothing: the menu is to look things up, the counter tells how many binds
the search found.
Requires: rofi, hyprctl
"""

import json
import re
import subprocess
from html import escape

MONO_FONT = "FiraCode Nerd Font"  # the keys, so that the descriptions line up
MODS = [(64, "Super"), (4, "Ctrl"), (8, "Alt"), (1, "Shift")]  # bits of modmask
KEYS = {
    "mouse:272": "Click",
    "mouse:273": "Right Click",
    "mouse_down": "Mouse Down",
    "mouse_up": "Mouse Up",
    "Prior": "Page Up",
    "Next": "Page Down",
    "backslash": "\\",
    "minus": "-",
    "equal": "=",
    "grave": "`",
    "period": ".",
    "space": "Space",
    "Return": "Enter",
    "escape": "Esc",
    "backspace": "Backspace",
}


def keys(bind):
    mods = [name for bit, name in MODS if bind["modmask"] & bit]
    return " + ".join(mods + [KEYS.get(bind["key"], bind["key"].replace("XF86", ""))])


def chords(binds):
    """{submap: keys that enter it}: the entering bind says so in its description,
    "Open the apps chord"."""
    entering = {}
    for bind in binds:
        match = re.search(r"\bthe (\w+) chord\b", bind["description"])
        if match and not bind["submap"]:
            entering[match.group(1)] = keys(bind)
    return entering


def main():
    binds = json.loads(subprocess.run(["hyprctl", "binds", "-j"], capture_output=True, text=True).stdout)
    entering = chords(binds)

    def label(bind):
        if not bind["submap"]:
            return keys(bind)
        return f"{entering.get(bind['submap'], '[' + bind['submap'] + ']')}; {keys(bind)}"

    # the global binds first, then each submap
    binds.sort(key=lambda bind: (bool(bind["submap"]), bind["submap"], keys(bind)))
    width = max(len(label(bind)) for bind in binds)
    rows = [
        f"<span font_family='{MONO_FONT}' weight='bold'>{escape(label(bind).ljust(width))}</span>   "
        f"{escape(bind['description'] or '<no description>')}"
        for bind in binds
    ]
    subprocess.run(["rofi", "-dmenu", "-i", "-markup-rows", "-no-custom", "-p", "󰌌"], input="\n".join(rows), text=True)


if __name__ == "__main__":
    main()
