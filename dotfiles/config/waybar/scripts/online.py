#!/usr/bin/env python3
"""Internet check for waybar (port of polybar's online.py).

Prints one JSON line per change; the class (online/offline/updating) is
coloured from the CSS and the tooltip holds public and local IP.
SIGUSR1 checks again.

Usage: online.py [interval_seconds]
"""

import json
import signal
import socket
import sys
import urllib.request

INTERVAL = 60
TIMEOUT = 10
URL = "https://api.ipify.org?format=json"


def local_ip():
    # address of the interface holding the default route (no packet is sent)
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as probe:
            probe.connect(("192.0.2.1", 9))
            return probe.getsockname()[0]
    except OSError:
        return None


class Checker:
    def __init__(self):
        self.ip = None
        self.state = "updating"

    def update(self):
        self.state = "updating"
        self.emit()
        try:
            with urllib.request.urlopen(URL, timeout=TIMEOUT) as response:
                self.ip = json.load(response)["ip"]
            self.state = "online"
        except (OSError, ValueError, KeyError):
            self.ip = None
            self.state = "offline"
        self.emit()

    def emit(self):
        public = {"updating": "Checking...", "offline": "Offline"}.get(self.state, self.ip)
        local = local_ip() or "No local IP"
        tooltip = f"Public: {public}\nLocal: {local}"
        # tooltip += "\n\nclick: check · right: ifconfig.co"
        print(json.dumps({"text": "", "tooltip": tooltip, "class": self.state}), flush=True)


if __name__ == "__main__":
    interval = int(sys.argv[1]) if len(sys.argv) > 1 else INTERVAL
    signals = {signal.SIGUSR1}
    # handled in the loop below instead of interrupting a check
    signal.pthread_sigmask(signal.SIG_BLOCK, signals)

    checker = Checker()
    try:
        checker.update()
        while True:
            # wakes up early on SIGUSR1
            signal.sigtimedwait(signals, interval)
            checker.update()
    except (KeyboardInterrupt, BrokenPipeError):
        pass
