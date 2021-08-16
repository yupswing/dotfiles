#!/usr/bin/env python
# -*- coding: utf-8 -*

# UNRELIABLE
# https://ifconfig.co/json
# {
#   "ip": "12.34.56.78",
#   "ip_decimal": 1234567890,
#   "country": "Italy",
#   "country_eu": true,
#   "country_iso": "IT",
#   "city": "Genoa",
#   "hostname": "ppp-00-00.00-000.example.com",
#   "latitude": 0.0000,
#   "longitude": 0.0000,
#   "asn": "AS0000",
#   "asn_org": "Organization",
# }

# WORKS OK, NO LOGGING
# https://api.ipify.org?format=json
# {
#   "ip":"151.30.240.62"
# }

import requests
import signal
import time
import sys

INTERVAL = 60
# ICON = "󰀃" # font-awesome
ICON = "" # feather
COLOR_UPDATE = "#f19d3a"
COLOR_OFFLINE = "#f92672"
COLOR_ONLINE = "#dddddd"


class Checker(object):
    def __init__(self, icon, color_online, color_offline, color_update):
        self.ip = None
        self.online = False
        self.showIp = False
        self.updating = False
        self.icon = icon
        self.color_online = color_online
        self.color_offline = color_offline
        self.color_update = color_update

    def update(self):
        self.ip = "Checking..."
        url = 'https://api.ipify.org?format=json'

        self.updating = True
        self._print()

        try:
            r = requests.get(url)
            r.encoding = 'utf-8'
            data = r.json()
        except:
            data = None
        if data:
            self.ip = data['ip']
            self.online = True
        else:
            self.ip = 'Offline'
            self.online = False

        self.updating = False
        self._print()

    def toggleShowIp(self):
        self.showIp = not self.showIp
        self._print()

    def _print(self):
        if self.updating:
            color = self.color_update
        elif self.online:
            color = self.color_online
        else:
            color = self.color_offline
        output = "%%{F%s}%s%%{F-}" % (color, self.icon)
        if self.showIp:
            output = "%s %s" % (output, self.ip)
        print("%s" % output)
        sys.stdout.flush()


def getArgv(index, default=None):
    if len(sys.argv) > index:
        return sys.argv[index]
    else:
        return default


if __name__ == '__main__':

    interval = int(getArgv(1, INTERVAL))
    icon = getArgv(2, ICON)
    color_online = getArgv(3, COLOR_ONLINE)
    color_offline = getArgv(4, COLOR_OFFLINE)
    color_update = getArgv(5, COLOR_UPDATE)

    checker = Checker(icon, color_online, color_offline, color_update)
    signal.signal(signal.SIGUSR1,
                  lambda signal, frame: checker.update())

    signal.signal(signal.SIGUSR2,
                  lambda signal, frame: checker.toggleShowIp())

    while True:
        checker.update()
        time.sleep(interval)
