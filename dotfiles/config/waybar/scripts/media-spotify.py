#!/usr/bin/env python3
"""Spotify slot updated via MPRIS events; empty (hidden by waybar) when closed."""

import html
import json
import subprocess
import sys

import gi

gi.require_version("Playerctl", "2.0")
from gi.repository import GLib, Playerctl


# Material Design Icons: artist (account-music), title (music-note), album
TOOLTIP_ICONS = ("\U000f0803", "\U000f0387", "\U000f0025")


# Max characters of the artist shown in the bar; the title takes what is left
# of the module's max-length (modules.jsonc) and waybar puts the ellipsis
MAX_ARTIST = 20


def ellipsis(value, limit):
    return value if len(value) <= limit else value[: limit - 1].rstrip() + "…"


def clean(value):
    return " ".join((value or "").split())


def render(player=None):
    # empty text: waybar hides the module
    state, text, tooltip = "closed", "", ""
    if player is not None:
        state = player.props.playback_status.value_nick.lower()
        artist, title = clean(player.get_artist()), clean(player.get_title())
        short_artist = ellipsis(artist, MAX_ARTIST)
        text = " • ".join(filter(None, (short_artist, title))) or "Spotify"
        rows = zip(TOOLTIP_ICONS, (artist, title, clean(player.get_album())))
        tooltip = "\n".join(f"{icon}  {value}" for icon, value in rows if value)
        # tooltip += "\n\nclick: play/pause · middle: next"
        # tooltip += "\nscroll: previous · right: open Spotify"
    return {"text": html.escape(text), "tooltip": html.escape(tooltip), "alt": state, "class": state}


class Spotify:
    def __init__(self):
        self.manager = Playerctl.PlayerManager()
        self.manager.connect("name-appeared", self.appeared)
        self.manager.connect("player-vanished", self.vanished)
        for name in self.manager.props.player_names:
            self.appeared(self.manager, name)
        self.emit()

    def current(self):
        return next(iter(self.manager.props.players), None)

    def emit(self, *_):
        try:
            payload = render(self.current())
        except GLib.Error:
            payload = render()
        print(json.dumps(payload, ensure_ascii=False), flush=True)

    def appeared(self, manager, name):
        if name.name != "spotify":
            return
        try:
            player = Playerctl.Player.new_from_name(name)
            player.connect("metadata", self.emit)
            player.connect("playback-status", self.emit)
            manager.manage_player(player)
            self.emit()
        except GLib.Error:
            self.emit()

    def vanished(self, *_):
        self.emit()


def control(action):
    if action in ("next", "previous"):
        subprocess.run(["playerctl", "-p", "spotify", action],
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        return
    if action == "toggle":
        result = subprocess.run(["playerctl", "-p", "spotify", "play-pause"],
                                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if result.returncode == 0:
            return
    subprocess.Popen(["spotify"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
                     start_new_session=True)


if __name__ == "__main__":
    if len(sys.argv) > 1:
        if len(sys.argv) > 2 or sys.argv[1] not in ("toggle", "next", "previous", "open"):
            sys.exit("Usage: spotify.py [toggle|next|previous|open]")
        control(sys.argv[1])
    else:
        # keep a reference: with Spotify closed nothing else holds the manager,
        # and once collected it never reports that Spotify appeared
        spotify = Spotify()
        try:
            GLib.MainLoop().run()
        except (KeyboardInterrupt, BrokenPipeError):
            pass
