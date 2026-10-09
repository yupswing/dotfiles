#!/usr/bin/env python3
"""Rofi color tool: pick a color from the screen and see it in every format.

  colors.py            pick a color with hyprpicker
  colors.py --input    type a color: #3b82f6, 3b82f6, steelblue, rgb(59, 130, 246),
                       hsl(217, 91%, 60%), oklch(62.3% 0.188 259.8)
  colors.py --history  the colors used before
  colors.py COLOR      the menu of that color

The menu has four columns, all visible, with the colors always as lowercase "#rrggbb":
  FORMATS   hex, rgb, hsl, oklch, oklab, hsv, cmyk and the nearest CSS name; below,
            the contrast with white and black (only to read, as it looks on each)
  HUE       the color rotated around the OKLCH hue wheel, by the angles of the
            harmonies (analogous, split, triad, tetradic, square, complement)
  CHROMA    from 0 to the most vivid chroma the color can have at its lightness and hue
  LIGHTNESS from 95% to 15%, keeping hue and chroma (reduced where it would not fit)
Each of the last three changes only its own axis of OKLCH. Every cell shows the
current color before its own, to compare; in CHROMA and LIGHTNESS the one closest
to the current color is marked.

  Enter  on a format: copies it; on a cell: opens that color on the same cell, so
         Enter again repeats it (the next rotation, the same chroma...)
  C      copies the selected cell (its hex)
  H      copies the hex of the color of the menu, whatever cell is selected
The colors picked, typed or copied go first in the history, without duplicates: one
that was there moves up. Looking around (opening cells) adds nothing.

While it runs, rofi opens without animation: the menu is closed and opened again at
every Enter and would jump. It switches the layer rule `rofi_quiet` (hypr look.lua).
Requires: rofi, pastel (names and input), hyprpicker, wl-clipboard; notify-send is optional.
"""

import colorsys
import math
import os
import re
import signal
import struct
import subprocess
import sys
import zlib
from contextlib import contextmanager
from pathlib import Path
from typing import NamedTuple

STATE = Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "colors"
SWATCHES = Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp")) / "colors-swatches"  # in memory, gone at logout
HISTORY = STATE / "history"
HISTORY_MAX = 40
HISTORY_PAGE = 10  # colors per page of the history menu

MONO_FONT = "FiraCode Nerd Font"  # labels, so that the values line up
HERE = "◀"  # marks the cell closest to the current color
GRID_ROWS = 12  # rows of a column: its title and 11 cells
COLUMN_WIDTH = 360  # pixels

# rotations of the OKLCH hue wheel (degrees) and the harmony each belongs to
HARMONIES = [
    (30, "analogous"), (60, "tetradic"), (90, "square"), (120, "triad"), (150, "split"),
    (180, "complement"), (210, "split"), (240, "triad"), (270, "square"), (300, "tetradic"),
    (330, "analogous"),
]
CHROMAS = list(range(0, 101, 10))  # % of the most vivid chroma
LIGHTNESSES = list(range(95, 14, -8))  # %, light to dark

HINT = "<span size='small' alpha='55%'>Enter: load the selected color, or copy a format  ·  C: copy the selected color  ·  H: copy the original color</span>"
# rofi exit codes of the custom keys "c" (kb-custom-1) and "h" (kb-custom-2)
COPY_KEY, HEX_KEY = 10, 11


# --- color math -------------------------------------------------------------------


def pastel(*args):
    """Lines printed by pastel (colors without ANSI codes)."""
    result = subprocess.run(["pastel", "-m", "off", *args], capture_output=True, text=True)
    if result.returncode != 0:
        raise ValueError(result.stderr.strip() or "pastel failed")
    return result.stdout.splitlines()


def rgb_of(color):
    return tuple(int(color[i : i + 2], 16) for i in (1, 3, 5))


def to_linear(channel):
    """sRGB channel (0..255) to linear light (0..1)."""
    c = channel / 255
    return c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4


def oklab_of(color):
    """(L, a, b) of the color, with Björn Ottosson's matrices."""
    r, g, b = map(to_linear, rgb_of(color))
    l = (0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b) ** (1 / 3)
    m = (0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b) ** (1 / 3)
    s = (0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b) ** (1 / 3)
    return (
        0.2104542553 * l + 0.7936177850 * m - 0.0040720468 * s,
        1.9779984951 * l - 2.4285922050 * m + 0.4505937099 * s,
        0.0259040371 * l + 0.7827717662 * m - 0.8086757660 * s,
    )


def oklch_of(color):
    """(L, C, H) of the color; the hue of a gray, where it is noise, is 0."""
    lightness, a, b = oklab_of(color)
    chroma = math.hypot(a, b)
    return lightness, chroma, math.degrees(math.atan2(b, a)) % 360 if chroma >= 0.0005 else 0.0


def oklch_to_linear(lightness, chroma, hue):
    """Linear sRGB of an OKLCH color: outside 0..1 where sRGB cannot show it."""
    a = chroma * math.cos(math.radians(hue))
    b = chroma * math.sin(math.radians(hue))
    l = (lightness + 0.3963377774 * a + 0.2158037573 * b) ** 3
    m = (lightness - 0.1055613458 * a - 0.0638541728 * b) ** 3
    s = (lightness - 0.0894841775 * a - 1.2914855480 * b) ** 3
    return (
        4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s,
        -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s,
        -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s,
    )


def linear_to_hex(linear):
    def encode(c):
        c = min(max(c, 0.0), 1.0)
        return round((12.92 * c if c <= 0.0031308 else 1.055 * c ** (1 / 2.4) - 0.055) * 255)

    return "#" + "".join(f"{encode(c):02x}" for c in linear)


def max_chroma(lightness, hue, limit=0.5):
    """The largest chroma (up to `limit`) that fits in sRGB at that lightness and hue."""

    def fits(chroma):
        return all(-0.0005 <= x <= 1.0005 for x in oklch_to_linear(lightness, chroma, hue))

    if fits(limit):
        return limit
    low, high = 0.0, limit
    for _ in range(20):
        middle = (low + high) / 2
        low, high = (middle, high) if fits(middle) else (low, middle)
    return low


def fitted_hex(lightness, chroma, hue):
    """Hex of an OKLCH color, with the chroma reduced where sRGB cannot show it."""
    return linear_to_hex(oklch_to_linear(lightness, min(chroma, max_chroma(lightness, hue)), hue))


def parse(text):
    """The color typed or picked, as "#rrggbb": any CSS-like color, oklch() too;
    None if it cannot be read."""
    text = text.strip()
    if not text:
        return None
    oklch = re.fullmatch(r"oklch\(\s*([\d.]+)(%?)[\s,]+([\d.]+)[\s,]+([\d.]+)(?:deg)?\s*\)", text.lower())
    if oklch:
        lightness, percent, chroma, hue = oklch.groups()
        lightness = min(float(lightness) / (100 if percent else 1), 1)
        return fitted_hex(lightness, float(chroma), float(hue) % 360)  # out of sRGB: less chroma
    try:
        return pastel("format", "hex", text)[0].lower()
    except (ValueError, IndexError):
        return None


# --- what the menu shows ------------------------------------------------------------


def trim(value, digits):
    """62.0 -> "62", 0.18810 -> "0.188"."""
    return f"{round(value, digits):g}"


def formats(color):
    """[(label, shown, copied)]: what is shown has only the numbers, to be short;
    what is copied is complete, as CSS wants it: rgb(59, 130, 246)."""
    red, green, blue = rgb_of(color)
    r, g, b = red / 255, green / 255, blue / 255
    hue, lightness, saturation = colorsys.rgb_to_hls(r, g, b)
    hsl = f"{round(hue * 360)}, {round(saturation * 100)}%, {round(lightness * 100)}%"
    hue, saturation, value = colorsys.rgb_to_hsv(r, g, b)
    hsv = f"{round(hue * 360)}, {saturation * 100:.1f}%, {value * 100:.1f}%"
    black = 1 - max(r, g, b)
    cyan, magenta, yellow = ((1 - c - black) / (1 - black) if black < 1 else 0 for c in (r, g, b))
    cmyk = ", ".join(str(round(x * 100)) for x in (cyan, magenta, yellow, black))
    lightness, chroma, hue = oklch_of(color)
    oklch = f"{trim(lightness * 100, 1)}% {trim(chroma, 3)} {trim(hue, 1)}"
    lightness, a, b = oklab_of(color)
    oklab = f"{trim(lightness * 100, 1)}% {trim(a, 3)} {trim(b, 3)}"
    name = pastel("format", "name", color)[0]
    return [
        ("hex", color, color),
        ("rgb", f"{red}, {green}, {blue}", f"rgb({red}, {green}, {blue})"),
        ("hsl", hsl, f"hsl({hsl})"),
        ("oklch", oklch, f"oklch({oklch})"),
        ("oklab", oklab, f"oklab({oklab})"),
        ("hsv", hsv, f"hsv({hsv})"),
        ("cmyk", cmyk, f"cmyk({cmyk})"),
        ("name", name, name),
    ]


def contrast(color):
    """[(label, ratio and level, background)]: WCAG contrast with white and black."""

    def luminance(c):
        r, g, b = map(to_linear, rgb_of(c))
        return 0.2126 * r + 0.7152 * g + 0.0722 * b

    rows = []
    for label, background in (("on white", "#ffffff"), ("on black", "#000000")):
        high, low = sorted((luminance(color), luminance(background)), reverse=True)
        ratio = (high + 0.05) / (low + 0.05)
        level = "AAA" if ratio >= 7 else "AA" if ratio >= 4.5 else "AA large" if ratio >= 3 else "fails"
        rows.append((label, f"{ratio:.2f}:1  {level}", background))
    return rows


def hues(color):
    """[(angle, harmony, hex)]: the color rotated by the angle of each harmony. The
    angles past 180° are negative (-30° and not 330°: the same, the other way)."""
    lightness, chroma, hue = oklch_of(color)
    return [
        (f"{angle - 360 if angle > 180 else angle:+d}°", harmony, fitted_hex(lightness, chroma, (hue + angle) % 360))
        for angle, harmony in HARMONIES
    ]


def chromas(color):
    """[(chroma, hex)]: from 0 to the most vivid chroma at the color's lightness and hue."""
    lightness, _, hue = oklch_of(color)
    vivid = max_chroma(lightness, hue)
    return [
        (f"{vivid * level / 100:.3f}", linear_to_hex(oklch_to_linear(lightness, vivid * level / 100, hue)))
        for level in CHROMAS
    ]


def chroma_percent(color):
    """Where the color is on the scale of chromas(), in %."""
    lightness, chroma, hue = oklch_of(color)
    vivid = max_chroma(lightness, hue)
    return min(chroma / vivid * 100, 100) if vivid > 1e-6 else 0


def lightnesses(color):
    """[(lightness, hex)]: the color from 95% to 15% of OKLCH lightness."""
    _, chroma, hue = oklch_of(color)
    return [(f"{level}%", fitted_hex(level / 100, chroma, hue)) for level in LIGHTNESSES]


def nearest(value, levels):
    """Index of the level closest to the value."""
    return min(range(len(levels)), key=lambda i: abs(levels[i] - value))


# --- swatches ---------------------------------------------------------------------


def swatch(color, background=None, beside=None):
    """Path of the icon of a color, a 48x32 PNG written once, transparent around it:
    a 32px square of the color, or of the color inside a square of the `background`
    (to see it on it), or after a half-width rectangle of the `beside` color (to compare)."""
    name = color[1:] + (f"-on-{background[1:]}" if background else "") + (f"-beside-{beside[1:]}" if beside else "")
    path = SWATCHES / f"{name}.png"
    if path.exists():
        return str(path)

    def pixel(c):
        return bytes(rgb_of(c)) + b"\xff"

    height, width, inner = 32, 48, 16
    edge = (height - inner) // 2
    outer = pixel(background or color)
    middle = outer * edge + pixel(color) * inner + outer * edge
    rows = [middle if edge <= y < edge + inner else outer * height for y in range(height)]
    if beside:
        rows = [pixel(beside) * (height // 2) + row for row in rows]
    else:
        margin = b"\x00" * 4 * ((width - height) // 2)
        rows = [margin + row + margin for row in rows]

    def chunk(kind, data):
        return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", zlib.crc32(kind + data))

    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(b"".join(b"\x00" + row for row in rows))) + chunk(b"IEND", b"")
    write_atomic(path, png)
    return str(path)


# --- rofi -------------------------------------------------------------------------


def esc(text):
    return text.replace("&", "&amp;").replace("<", "&lt;")


class Row(NamedTuple):
    text: str  # pango markup
    icon: tuple | None  # arguments of swatch()
    copy: str | None  # what Enter copies; None: the row cannot be chosen
    open: str | None  # the color Enter opens instead of copying


class Choice(NamedTuple):
    action: str  # "open" a color, "copy" a value, "hex": copy the hex of the menu
    value: str
    row: int


class Menu:
    """A rofi menu. With columns (`column()`) it is a grid whose columns are all
    visible, with no search field; without, it is a list with one."""

    def __init__(self, label_width=0):
        self.rows = []
        self.columns = 0
        self.label_width = label_width

    def label(self, text, width=None):
        """Dim monospace text, so that what follows lines up."""
        return "<span font_family='{}' alpha='60%'>{}</span>".format(MONO_FONT, text.ljust(width or self.label_width))

    def header(self, title):
        self.rows.append(Row(f"<span size='small' alpha='45%'>{title}</span>", None, None, None))

    def column(self, title, label_width):
        """Starts a column: the rows go on after the free ones of the one before."""
        while len(self.rows) % GRID_ROWS:
            self.rows.append(Row(" ", None, None, None))
        self.header(title)
        self.columns += 1
        self.label_width = label_width

    def item(self, name, shown, icon, copy=None, width=None):
        """A row to copy (`copy`, or `shown`); without `copy` it is only to read."""
        text = self.label(name, width) + " " + esc(shown)
        self.rows.append(Row(text, icon, copy, None))

    def cell(self, name, color, current=None, plain="", here=False):
        """A color: Enter opens it. Its icon has `current` before it, to compare."""
        text = self.label(name) + (f" {esc(plain)}" if plain else "") + (f" <b>{HERE}</b>" if here else "")
        self.rows.append(Row(text, (color, None, current), color, color))

    def command(self, prompt, selected):
        keys = []
        theme = "element { padding: 8px 12px; } element-icon { size: 1.9em; } "
        if self.columns:
            theme += (
                f"window {{ width: {self.columns * COLUMN_WIDTH + 10}px; }} inputbar {{ enabled: false; }} "
                f"listview {{ columns: {self.columns}; lines: {GRID_ROWS}; flow: vertical; fixed-columns: true; dynamic: false; }} "
                # the hint goes under the grid, small and without a card of its own
                'mainbox { children: [ "listview", "message" ]; } '
                "message { background-color: transparent; margin: 0; padding: 10px 12px 2px 12px; }"
            )
            # no search field: plain letters are free; the arrows go from a column to another
            keys = [
                "-kb-custom-1", "c", "-kb-custom-2", "h",
                "-kb-move-char-back", "Control+b", "-kb-move-char-forward", "Control+f",
                "-kb-row-left", "Left,Control+Page_Up", "-kb-row-right", "Right,Control+Page_Down",
            ]
        else:
            theme += f"listview {{ lines: {HISTORY_PAGE}; }}"
        return [
            "rofi", "-dmenu", "-i", "-no-custom", "-show-icons", "-markup-rows", "-format", "i",
            "-p", prompt, "-selected-row", str(selected), *keys, "-theme-str", theme,
            *(["-mesg", HINT] if self.columns else []),
        ]

    def show(self, prompt, selected=None):
        """Shows the menu, with the row `selected` (by default the first that can be
        chosen); returns the Choice, or None if it was cancelled."""
        if selected is None:
            selected = next(i for i, row in enumerate(self.rows) if row.copy is not None)
        lines = []
        for text, icon, copy, _ in self.rows:
            options = []
            if copy is None:
                options += ["nonselectable", "true"]
            if self.columns:
                options += ["permanent", "true"]  # what is typed by mistake does not hide rows
            if icon:
                options += ["icon", swatch(*icon)]
            lines.append(text + ("\0" + "\x1f".join(options) if options else ""))
        result = subprocess.run(self.command(prompt, selected), input="\n".join(lines), capture_output=True, text=True)
        picked = result.stdout.strip()
        if result.returncode == HEX_KEY:
            return Choice("hex", "", selected)
        if result.returncode not in (0, COPY_KEY) or not picked.isdecimal() or int(picked) >= len(self.rows):
            return None
        index = int(picked)
        row = self.rows[index]
        if row.copy is None:
            return None
        if result.returncode == 0 and row.open:
            return Choice("open", row.open, index)
        return Choice("copy", row.copy, index)


def color_menu(color, selected=None):
    """The menu of a color, until something is copied or it is cancelled."""
    while color:
        menu = Menu()
        menu.column("FORMATS", 6)
        for name, shown, copied in formats(color):
            menu.item(name, shown, (color, None, None), copied)
        menu.header("CONTRAST")
        for name, text, background in contrast(color):
            menu.item(name, text, (color, background, None), width=9)

        menu.column("HUE (H)  harmonies", 5)
        for angle, harmony, hex_ in hues(color):
            menu.cell(angle, hex_, color, plain=harmony)

        near = nearest(chroma_percent(color), CHROMAS)
        menu.column("CHROMA (C)", 6)
        for i, (name, hex_) in enumerate(chromas(color)):
            menu.cell(name, hex_, color, here=i == near)

        near = nearest(oklch_of(color)[0] * 100, LIGHTNESSES)
        menu.column("LIGHTNESS (L)", 6)
        for i, (name, hex_) in enumerate(lightnesses(color)):
            menu.cell(name, hex_, color, here=i == near)

        choice = menu.show("󰏘", selected)
        if not choice:
            return
        if choice.action == "open":
            color, selected = choice.value, choice.row  # its menu, on the same row
            continue
        if choice.action == "hex":
            text = used = color
        else:
            text, used = choice.value, menu.rows[choice.row].open or color
        remember(used)
        clipboard(text)
        return


def history_menu():
    colors = history()
    if not colors:
        notify("Colors: no history yet")
        return
    menu = Menu(label_width=9)
    for color, name in zip(colors, pastel("format", "name", *colors)):
        menu.cell(color, color, plain=name)
    choice = menu.show("󰋚")
    if choice:
        color_menu(choice.value)


# --- history and system -----------------------------------------------------------


def history():
    return HISTORY.read_text().split() if HISTORY.exists() else []


def remember(color):
    """Puts the color first in the history: if it was there already, it moves up."""
    colors = [color] + [c for c in history() if c != color]
    write_atomic(HISTORY, ("\n".join(colors[:HISTORY_MAX]) + "\n").encode())


def write_atomic(path, data):
    """Writes the file at once, so that nobody reads half of it; each instance has its
    own temporary file."""
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f"{path.name}.{os.getpid()}.tmp")
    temporary.write_bytes(data)
    temporary.replace(path)


def clipboard(text):
    subprocess.run(["wl-copy", "-n", text], check=True)


def notify(message):
    try:
        subprocess.run(["notify-send", "-a", "colors", "-t", "2500", message], check=False)
    except FileNotFoundError:
        pass


@contextmanager
def quiet_rofi():
    """The layer rule that opens rofi without animation, on while the menus are."""

    def switch(on):
        try:
            subprocess.run(["hyprctl", "eval", f"rofi_quiet:set_enabled({str(on).lower()})"], capture_output=True)
        except FileNotFoundError:
            pass

    switch(True)
    try:
        yield
    finally:
        switch(False)


def share_privacy(on):
    # le regole no_screen_share oscurano le finestre anche nel frame del picker
    try:
        subprocess.run(["hyprctl", "eval", f"screen_share_privacy({str(on).lower()})"], capture_output=True)
    except FileNotFoundError:
        pass


def pick():
    share_privacy(False)
    try:
        result = subprocess.run(["hyprpicker", "-l"], capture_output=True, text=True)
    finally:
        share_privacy(True)
    return parse(result.stdout) if result.returncode == 0 else None


def typed():
    result = subprocess.run(
        ["rofi", "-dmenu", "-p", "󰏘", "-theme-str", "listview { enabled: false; }"],
        input="", capture_output=True, text=True,
    )
    text = result.stdout.strip()
    if result.returncode != 0 or not text:
        return None
    color = parse(text)
    if not color:
        notify(f"Colors: cannot read '{text}'")
    return color


def main():
    option = sys.argv[1] if len(sys.argv) > 1 else "--pick"
    if option == "--history":
        return history_menu()
    if option == "--pick":
        color = pick()
    elif option == "--input":
        color = typed()
    else:
        color = parse(option)
        if not color:
            sys.exit(f"cannot read the color '{option}'\n\n{__doc__}")
    if color:
        remember(color)
        color_menu(color)


if __name__ == "__main__":
    # killed or not, rofi must go back to its animations
    signal.signal(signal.SIGTERM, lambda *_: sys.exit(1))
    signal.signal(signal.SIGHUP, lambda *_: sys.exit(1))
    try:
        with quiet_rofi():
            main()
    except (ValueError, FileNotFoundError, subprocess.CalledProcessError) as error:
        notify(f"Colors: {error}")
        sys.exit(1)
