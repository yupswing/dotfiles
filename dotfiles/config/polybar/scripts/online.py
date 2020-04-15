#!/usr/bin/env python
# -*- coding: utf-8 -*

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

import requests
import signal
import time
import sys

ICON = ""
COLOR_UPDATE = "f4bf75"
COLOR_OFFLINE = "f92672"
COLOR_ONLINE = "a6e22e"


class Checker(object):
    def __init__(self):
        self.ip = None
        self.online = False
        self.showIp = False
        self.updating = False

    def update(self):
        self.ip = None
        url = 'https://ifconfig.co/json'

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
            self.ip = 'offline'
            self.online = False

        self.updating = False
        self._print()

    def toggleShowIp(self):
        self.showIp = not self.showIp
        self._print()

    def _print(self):
        if self.updating:
            color = COLOR_UPDATE
        elif self.online:
            color = COLOR_ONLINE
        else:
            color = COLOR_OFFLINE
        output = "%%{F#%s}%s%%{F-}" % (color, ICON)
        if self.showIp:
            output = "%s %s" % (output, self.ip)
        print("%s" % output)
        sys.stdout.flush()


if __name__ == '__main__':

    checker = Checker()
    signal.signal(signal.SIGUSR1, lambda signal,
                  frame: checker.update())

    signal.signal(signal.SIGUSR2, lambda signal,
                  frame: checker.toggleShowIp())

    while True:
        checker.update()
        time.sleep(90)
