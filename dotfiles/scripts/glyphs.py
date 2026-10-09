#!/usr/bin/env python3
"""Rofi picker for emoji and Nerd Font icons: the choice goes to the clipboard.

  glyphs.py --emoji    the emoji
  glyphs.py --nerd     the Nerd Font icons
  glyphs.py --all      both
  glyphs.py --update   downloads the data again

A grid, each cell with the glyph, its code point, its name and (Nerd Font) the
icon set it comes from, in the color of that set. Typing searches the name, the
code point and what is not shown: for the emoji their group and the CLDR keywords
in English and Italian ("puppy", "cane"), for the Nerd Font the set and the code.

The data is downloaded into ~/.cache/glyphs (about 3 MB) the first time, and again
when it is older than MAX_AGE_DAYS (the old one is kept if that fails):
  emoji  unicode.org emoji-test.txt and the CLDR annotations
  nerd   glyphnames.json of the ryanoasis/nerd-fonts repository
Requires: rofi, wl-clipboard; notify-send is optional.
"""

import json
import os
import subprocess
import sys
import time
import urllib.request
import xml.etree.ElementTree as ET
from html import escape
from pathlib import Path

CACHE = Path(os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")) / "glyphs"
SOURCES = {
    "nerd": "https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/glyphnames.json",
    "emoji": "https://unicode.org/Public/emoji/latest/emoji-test.txt",
}
# CLDR keywords of the emoji; the "derived" files have the sequences (a person
# with a profession...)
CLDR = "https://raw.githubusercontent.com/unicode-org/cldr/main/common/{}/{}.xml"
CLDR_LANGUAGES = ["en", "it"]
TIMEOUT = 30
DATA_ERRORS = (OSError, ValueError, ET.ParseError)  # download or parsing failed

MAX_AGE_DAYS = 7  # the cache is downloaded again when older
RETRY_DAYS = 1  # after a failed update

COLUMNS, ROWS, WIDTH = 8, 5, 1060
GLYPH_SIZE = "230%"
# lines of a cell: glyph, code point, name, hidden words; Nerd Font also the set
CELL_LINES = {"emoji": 4, "nerd": 5}

# Nerd Fonts name prefix -> (icon set, its color in the glyphs diagram of Nerd Fonts, an icon of it)
ORIGINS = {
    "cod": ("Codicons", "#1f77b4", ""),  # vscode
    "custom": ("Custom", "#8c564b", ""),  # ruby
    "dev": ("Devicons", "#d62728", ""),  # git
    "extra": ("Extra", "#2ca02c", ""),  # progress bar
    "fa": ("Font Awesome", "#2ca02c", ""),  # font awesome
    "fae": ("Awesome Extension", "#2ca02c", ""),  # atom
    "iec": ("IEC Power", "#7f7f7f", "⏻"),  # power
    "indent": ("Indent", "#8c564b", ""),  # indent line
    "indentation": ("Indent", "#8c564b", ""),
    "linux": ("Font Logos", "#2ca02c", ""),  # tux
    "md": ("Material Design", "#17becf", "󰦆"),  # material design
    "oct": ("Octicons", "#e377c2", ""),  # github mark
    "pl": ("Powerline", "#ff7f0e", ""),  # branch
    "ple": ("Powerline Extra", "#ff7f0e", ""),  # flame
    "pom": ("Pomicons", "#bcbd22", ""),  # pomodoro done
    "seti": ("Seti-UI", "#8c564b", ""),  # config
    "weather": ("Weather Icons", "#9467bd", ""),  # day sunny
}
WHITE_SHARE = 0.4  # the colors of the sets are mixed with this much white: softer


def soften(color):
    channels = (int(color[i : i + 2], 16) for i in (1, 3, 5))
    return "#" + "".join(f"{round(c + (255 - c) * WHITE_SHARE):02x}" for c in channels)


# --- data -------------------------------------------------------------------------
# The cache has one line per entry, "glyph  name  words": the words are the code of
# a Nerd Font icon, the group and the keywords of an emoji.


def fetch(url, timeout):
    with urllib.request.urlopen(url, timeout=timeout) as response:
        return response.read().decode()


def keywords(timeout):
    """{emoji without U+FE0F: "word word ..."} from the CLDR annotations."""
    words = {}
    for language in CLDR_LANGUAGES:
        for directory in ("annotations", "annotationsDerived"):
            root = ET.fromstring(fetch(CLDR.format(directory, language), timeout))
            for annotation in root.iter("annotation"):
                # the spoken name is the name of the emoji, in English
                if annotation.get("type") == "tts" and language == "en":
                    continue
                found = (word.strip() for word in (annotation.text or "").split("|"))
                words.setdefault(annotation.get("cp"), []).extend(found)
    return {cp: " ".join(dict.fromkeys(filter(None, found))) for cp, found in words.items()}


def parse_nerd(raw):
    lines = []
    for name, glyph in json.loads(raw).items():
        if isinstance(glyph, dict) and "char" in glyph and "code" in glyph:  # not the METADATA
            lines.append(f"{glyph['char']}  {name.replace('_', ' ')}  {glyph['code']}")
    return lines


def parse_emoji(raw, words):
    lines, group, subgroup = [], "", ""
    for line in raw.splitlines():
        if line.startswith("# group:"):
            group = line.split(":", 1)[1].strip()
        elif line.startswith("# subgroup:"):
            subgroup = line.split(":", 1)[1].strip()
        elif line and not line.startswith("#"):
            fields, _, comment = line.partition("#")
            if fields.split(";")[1].strip() != "fully-qualified":
                continue
            # "😀 E1.0 grinning face"
            glyph, _, rest = comment.strip().partition(" ")
            name = rest.partition(" ")[2]
            if "skin tone" not in name:
                found = words.get(glyph.replace("️", ""), "")  # the CLDR has no U+FE0F
                lines.append(f"{glyph}  {name}  ({group} · {subgroup}) {found}".rstrip())
    return lines


def download(kind, timeout=TIMEOUT):
    raw = fetch(SOURCES[kind], timeout)
    lines = parse_nerd(raw) if kind == "nerd" else parse_emoji(raw, keywords(timeout))
    if not lines:
        raise ValueError(f"no {kind} entries found")  # the old cache is better than none
    CACHE.mkdir(parents=True, exist_ok=True)
    path = CACHE / f"{kind}.txt"
    # at once, so that a menu never reads half a file; each instance has its own temporary one
    temporary = path.with_name(f"{path.name}.{os.getpid()}.tmp")
    temporary.write_text("\n".join(lines) + "\n")
    temporary.replace(path)


def entries(kinds):
    """[(kind, line)], downloading or updating the data if needed."""
    result = []
    for kind in kinds:
        path = CACHE / f"{kind}.txt"
        if not path.exists():
            notify("Glyphs: downloading the data...")
            download(kind)
        elif time.time() - path.stat().st_mtime > MAX_AGE_DAYS * 86400:
            notify("Glyphs: updating the data...")
            try:
                download(kind, timeout=8)  # short: the menu waits for it
            except DATA_ERRORS:
                # keep the old one; try again after RETRY_DAYS
                stamp = time.time() - (MAX_AGE_DAYS - RETRY_DAYS) * 86400
                os.utime(path, (stamp, stamp))
        result += [(kind, line) for line in path.read_text().splitlines()]
    return result


# --- menu -------------------------------------------------------------------------


def cell(kind, line):
    """The markup of a cell. Rofi searches the visible text of a row, so what is only
    to be searched is the last line, 1pt and transparent (on the line of the name it
    would shift it off centre)."""
    glyph, name, words = line.split("  ", 2)
    code = " ".join(f"{ord(c):X}" for c in glyph if c != "️")
    lines = [f"<span size='{GLYPH_SIZE}'>{escape(glyph)}</span>", f"<span size='60%' alpha='50%'>U+{code}</span>"]
    if kind == "nerd":
        prefix, _, name = name.partition("-")
        origin, color, icon = ORIGINS.get(prefix, (prefix, "#7f7f7f", ""))
        words = f"{prefix} {words}"
        lines.append(f"<span size='70%' alpha='70%'>{escape(name)}</span>")
        lines.append(f"<span size='70%' foreground='{soften(color)}'>{icon} {escape(origin)}</span>")
    else:
        lines.append(f"<span size='70%' alpha='70%'>{escape(name)}</span>")
    lines.append(f"<span size='1pt' alpha='1%'>{escape(words)}</span>")
    return "\n".join(lines)


def pick(rows, prompt):
    """Shows the grid of the entries; returns the glyph chosen, or None."""
    # not dynamic: rofi sizes a list that fills by rows as if it had a row per
    # element, and the window would be as tall as the matches are many
    theme = (
        f"window {{ width: {WIDTH}px; }} element {{ padding: 14px 4px; }} element-text {{ horizontal-align: 0.5; }} "
        f"listview {{ columns: {COLUMNS}; lines: {ROWS}; flow: horizontal; fixed-columns: true; "
        f"dynamic: false; spacing: 8px; }}"
    )
    lines = max(CELL_LINES[kind] for kind, _ in rows)
    result = subprocess.run(
        [
            "rofi", "-dmenu", "-i", "-no-custom", "-markup-rows", "-p", prompt, "-format", "i",
            "-sep", "\x1e", "-eh", str(lines),
            # the arrows go over the grid; the text cursor moves with Ctrl+B and Ctrl+F
            "-kb-move-char-back", "Control+b", "-kb-move-char-forward", "Control+f",
            "-kb-row-left", "Left,Control+Page_Up", "-kb-row-right", "Right,Control+Page_Down",
            "-theme-str", theme,
        ],
        input="\x1e".join(cell(kind, line) for kind, line in rows),  # not "\n": a row has lines
        capture_output=True,
        text=True,
    )
    picked = result.stdout.strip()
    if result.returncode != 0 or not picked.isdecimal() or int(picked) >= len(rows):
        return None
    return rows[int(picked)][1].split("  ")[0]


def notify(message):
    try:
        subprocess.run(["notify-send", "-a", "glyphs", "-t", "2500", message], check=False)
    except FileNotFoundError:
        pass


def main():
    option = sys.argv[1] if len(sys.argv) > 1 else "--all"
    if option == "--update":
        try:
            for kind in SOURCES:
                download(kind)
        except DATA_ERRORS as error:
            sys.exit(f"Glyphs: update failed: {error}")
        return
    menus = {"--all": (["emoji", "nerd"], "󰞅"), "--emoji": (["emoji"], "󰇵"), "--nerd": (["nerd"], "󰛖")}
    if option not in menus:
        sys.exit(__doc__)
    kinds, prompt = menus[option]
    try:
        glyph = pick(entries(kinds), prompt)
    except DATA_ERRORS:
        notify("Glyphs: download failed (offline?)")
        sys.exit(1)
    if glyph:
        subprocess.run(["wl-copy", "-n", glyph], check=True)


if __name__ == "__main__":
    main()
