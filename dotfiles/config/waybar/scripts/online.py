#!/usr/bin/env python3
"""Internet check for waybar (port of polybar's online.py).

Prints one JSON line per change; the class (online/offline/updating) is
coloured from the CSS and the tooltip holds public and local IP.

Periodic check (every interval): a plain TCP connection to PROBE tells online
from offline, no HTTP involved.

Public IP: asked to IP_URL only when it may have changed, that is at startup,
when back online, when the local IP changes, on click and every IP_REFRESH
seconds (a few dozen calls a day).

Click (SIGUSR1): always checks again at once, public IP included; the class
is "updating" meanwhile.

Shared cache: each bar runs its own copy of this script and they share the
last result, with its time, through CACHE. A copy takes the lock, uses the
result if it is recent enough (younger than half the interval, or obtained
after the click) and otherwise checks and rewrites it. So the first copy to
wake up does the work and the others read it; if a bar dies the other one
finds an old result and carries on alone.

Usage: online.py [interval_seconds]
"""

import fcntl
import json
import os
import signal
import socket
import sys
import time
import urllib.request

INTERVAL = 60
TIMEOUT = 10
# host and port of the connectivity check (Quad9 DNS)
PROBE = ("9.9.9.9", 443)
IP_URL = "https://api.ipify.org?format=json"
IP_REFRESH = 30 * 60
# last result, shared between the copies of this script (emptied at logout)
CACHE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar-online.json")


def local_ip():
    # address of the interface holding the default route (no packet is sent)
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as probe:
            probe.connect(("192.0.2.1", 9))
            return probe.getsockname()[0]
    except OSError:
        return None


def connected():
    try:
        with socket.create_connection(PROBE, timeout=TIMEOUT):
            return True
    except OSError:
        return False


def public_ip():
    try:
        with urllib.request.urlopen(IP_URL, timeout=TIMEOUT) as response:
            return json.load(response)["ip"]
    except (OSError, ValueError, KeyError):
        return None


def read_cache():
    try:
        with open(CACHE) as cache:
            return json.load(cache)
    except (OSError, ValueError):
        return {}


def write_cache(result):
    # atomic, a reader never sees half a file
    with open(CACHE + ".tmp", "w") as cache:
        json.dump(result, cache)
    os.replace(CACHE + ".tmp", CACHE)


def check(last, force):
    local = local_ip()
    ip, ip_checked = last.get("ip"), last.get("ip_checked", 0)
    if connected():
        expired = time.time() - ip_checked > IP_REFRESH
        if force or ip is None or local != last.get("local") or expired:
            ip, ip_checked = public_ip(), time.time()
        state = "online"
    else:
        ip, state = None, "offline"
    # wall clock: after a suspend the result is old and gets checked again
    return {"state": state, "ip": ip, "local": local, "checked": time.time(), "ip_checked": ip_checked}


class Checker:
    def __init__(self, interval):
        self.interval = interval
        self.ip = None
        self.state = "updating"
        self.printed = None

    def update(self, force=False):
        started = time.time()
        if force:
            self.state = "updating"
            self.emit()
        # the copies wake up together: the first one checks, the others wait
        # here and find its result. It is theirs too if it is younger than
        # half the interval or, when forced, if it was obtained after the click
        oldest = started if force else started - self.interval / 2
        with open(CACHE + ".lock", "w") as lock:
            fcntl.flock(lock, fcntl.LOCK_EX)
            result = read_cache()
            if result.get("checked", 0) < oldest:
                result = check(result, force)
                write_cache(result)
        self.state, self.ip = result["state"], result["ip"]
        self.emit()

    def emit(self):
        public = {"updating": "Checking...", "offline": "Offline"}.get(self.state, self.ip or "Unknown")
        local = local_ip() or "No local IP"
        tooltip = f"Public: {public}\nLocal: {local}"
        tooltip += "\n\nclick: check • right: ifconfig.co"
        line = json.dumps({"text": "", "tooltip": tooltip, "class": self.state})
        if line != self.printed:
            print(line, flush=True)
            self.printed = line


if __name__ == "__main__":
    interval = int(sys.argv[1]) if len(sys.argv) > 1 else INTERVAL
    signals = {signal.SIGUSR1}
    # handled in the loop below instead of interrupting a check
    signal.pthread_sigmask(signal.SIG_BLOCK, signals)

    checker = Checker(interval)
    try:
        checker.update(force=True)
        while True:
            # wakes up early on SIGUSR1
            signalled = signal.sigtimedwait(signals, interval) is not None
            checker.update(force=signalled)
    except (KeyboardInterrupt, BrokenPipeError):
        pass
