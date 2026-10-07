#!/usr/bin/env python3
"""Media slot for any MPRIS player; empty (hidden by waybar) when nothing plays.

Port of polybar's mpris.py (player-mpris-tail): follows the player that is
playing, or else the most recently used one that is paused.
Same output and commands as spotify.py, so the two are interchangeable.
"""

import html
import json
import os
import subprocess
import sys

import gi

gi.require_version("Playerctl", "2.0")
from gi.repository import Gio, GLib, Playerctl

# Material Design Icons: artist (account-music), title (music-note), album
TOOLTIP_ICONS = ("\U000f0803", "\U000f0387", "\U000f0025")

# Max characters of the artist shown in the bar; the title takes what is left
# of the module's max-length (modules.jsonc) and waybar puts the ellipsis
MAX_ARTIST = 20

# Players to ignore (name as in `playerctl -l`, without the instance suffix)
IGNORED = ()

# The instance shown in the bar, read back by the click commands
CURRENT_FILE = os.path.join(GLib.get_user_runtime_dir(), "waybar-media-player")

COMMANDS = {"toggle": "play-pause", "next": "next", "previous": "previous"}


def ellipsis(value, limit):
    return value if len(value) <= limit else value[: limit - 1].rstrip() + "…"


def clean(value):
    return " ".join((value or "").split())


def status(player):
    return player.props.playback_status.value_nick.lower()


def render(player=None):
    # empty text: waybar hides the module
    state, text, tooltip, name = "closed", "", "", ""
    if player is not None:
        state, name = status(player), player.props.player_name
        artist, title = clean(player.get_artist()), clean(player.get_title())
        short_artist = ellipsis(artist, MAX_ARTIST)
        text = " • ".join(filter(None, (short_artist, title))) or name
        rows = zip(TOOLTIP_ICONS, (artist, title, clean(player.get_album())))
        tooltip = "\n".join(f"{icon}  {value}" for icon, value in rows if value)
    return {"text": html.escape(text), "tooltip": html.escape(tooltip), "alt": state,
            "class": list(filter(None, (state, name)))}


class Media:
    def __init__(self):
        self.last = None
        self.ready = False
        self.manager = Playerctl.PlayerManager()
        self.manager.connect("name-appeared", self.appeared)
        self.manager.connect("player-vanished", self.emit)
        for name in self.manager.props.player_names:
            self.appeared(self.manager, name)
        # first output only once every running player is known
        self.ready = True
        self.emit()

    def current(self):
        # players are sorted by most recent activity
        players = self.manager.props.players
        for wanted in ("playing", "paused"):
            for player in players:
                if status(player) == wanted:
                    return player
        return None

    def emit(self, *_):
        if not self.ready:
            return
        try:
            player = self.current()
            payload = render(player)
            instance = player.props.player_instance if player else ""
        except GLib.Error:
            payload, instance = render(), ""
        line = json.dumps(payload, ensure_ascii=False)
        if line == self.last:
            return
        self.last = line
        with open(CURRENT_FILE, "w") as current:
            current.write(instance)
        print(line, flush=True)

    def appeared(self, manager, name):
        if name.name in IGNORED:
            return
        try:
            player = Playerctl.Player.new_from_name(name)
            player.connect("metadata", self.emit)
            player.connect("playback-status", self.emit)
            manager.manage_player(player)
        except GLib.Error:
            pass
        self.emit()


def control(action):
    try:
        with open(CURRENT_FILE) as current:
            instance = current.read().strip()
    except OSError:
        instance = ""
    if not instance:
        return
    if action == "open":
        # MPRIS Raise: brings the player window up (not every player honours it)
        bus = Gio.bus_get_sync(Gio.BusType.SESSION)
        try:
            bus.call_sync(f"org.mpris.MediaPlayer2.{instance}", "/org/mpris/MediaPlayer2",
                          "org.mpris.MediaPlayer2", "Raise", None, None,
                          Gio.DBusCallFlags.NONE, 1000)
        except GLib.Error:
            pass
        return
    subprocess.run(["playerctl", "-p", instance, COMMANDS[action]],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        if len(sys.argv) > 2 or sys.argv[1] not in (*COMMANDS, "open"):
            sys.exit("Usage: media.py [toggle|next|previous|open]")
        control(sys.argv[1])
    else:
        # keep a reference: with no player running nothing else holds the
        # manager, and once collected it never reports the players that appear
        media = Media()
        try:
            GLib.MainLoop().run()
        except (KeyboardInterrupt, BrokenPipeError):
            pass
