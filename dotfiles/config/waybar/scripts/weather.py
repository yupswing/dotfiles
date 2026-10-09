#!/usr/bin/env python3
"""Weather for waybar: Genoa, from Open-Meteo (free, no API key).

Prints one JSON line: the emoji of the weather now (at night, with a clear or
partly cloudy sky, the moon of tonight) and the feels-like temperature. The class
"rain" (blue in the CSS) is set when rain is expected in the next two hours: a
weather code of precipitation or at least RAIN_MM; the probability alone does not
count, 55% of 0.0 mm is not rain. "dry" otherwise. The tooltip has the details.

Offline, or if the answer is not what is expected: an empty text, so that waybar
hides the module.

Each bar runs its own copy: the first one to take the lock fetches, the others
use the result while it is younger than CACHE_SECONDS.
"""

import fcntl
import json
import math
import os
import time
import urllib.parse
import urllib.request

LAT, LON = 44.4072, 8.9339  # Genoa
TIMEOUT = 10
CACHE_SECONDS = 5 * 60
CACHE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "waybar-weather.json")
RAIN_MM = 0.1
MONO_FONT = "FiraCode Nerd Font"  # the tables of the tooltip, so that the columns line up

API = "https://api.open-meteo.com/v1/forecast?" + urllib.parse.urlencode(
    {
        "latitude": LAT,
        "longitude": LON,
        "timezone": "Europe/Rome",
        "forecast_days": 3,
        "current": "temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,is_day,"
        "wind_speed_10m,wind_direction_10m,wind_gusts_10m,pressure_msl,cloud_cover",
        "hourly": "temperature_2m,apparent_temperature,weather_code,precipitation_probability,precipitation,is_day",
        "daily": "weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,"
        "precipitation_probability_max,uv_index_max,sunrise,sunset",
    }
)

# kind of weather -> (day icon, night icon)
ICONS = {
    "sunny": ("☀️", "🌙"),
    "partly": ("⛅", "🌙"),
    "cloudy": ("☁️", "☁️"),
    "fog": ("🌫️", "🌫️"),
    "rain": ("🌧️", "🌧️"),
    "pouring": ("🌧️", "🌧️"),
    "snow": ("❄️", "❄️"),
    "sleet": ("🌨️", "🌨️"),
    "hail": ("🌨️", "🌨️"),
    "storm": ("⛈️", "⛈️"),
}
# WMO weather code -> (description, kind)
CODES = {
    0: ("Clear", "sunny"),
    1: ("Mostly clear", "sunny"),
    2: ("Partly cloudy", "partly"),
    3: ("Overcast", "cloudy"),
    45: ("Fog", "fog"),
    48: ("Rime fog", "fog"),
    51: ("Light drizzle", "rain"),
    53: ("Drizzle", "rain"),
    55: ("Heavy drizzle", "rain"),
    56: ("Freezing drizzle", "sleet"),
    57: ("Heavy freezing drizzle", "sleet"),
    61: ("Light rain", "rain"),
    63: ("Rain", "rain"),
    65: ("Heavy rain", "pouring"),
    66: ("Freezing rain", "sleet"),
    67: ("Heavy freezing rain", "sleet"),
    71: ("Light snow", "snow"),
    73: ("Snow", "snow"),
    75: ("Heavy snow", "snow"),
    77: ("Snow grains", "snow"),
    80: ("Light showers", "rain"),
    81: ("Showers", "rain"),
    82: ("Violent showers", "pouring"),
    85: ("Snow showers", "snow"),
    86: ("Heavy snow showers", "snow"),
    95: ("Thunderstorm", "storm"),
    96: ("Thunderstorm with hail", "hail"),
    99: ("Thunderstorm with heavy hail", "hail"),
}
DRY_KINDS = {"sunny", "partly", "cloudy", "fog"}
WET = {code for code, (_, kind) in CODES.items() if kind not in DRY_KINDS}  # precipitation
DAYS = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
WIND = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]

# the moon, from the mean lunation: nothing to download, good to about half a day
NEW_MOON = 947182440  # 2000-01-06 18:14 UTC
LUNATION = 29.530588861  # days
PHASES = [  # as the emoji show them from the northern hemisphere
    ("New Moon", "🌑"),
    ("Waxing Crescent", "🌒"),
    ("First Quarter", "🌓"),
    ("Waxing Gibbous", "🌔"),
    ("Full Moon", "🌕"),
    ("Waning Gibbous", "🌖"),
    ("Last Quarter", "🌗"),
    ("Waning Crescent", "🌘"),
]


def load():
    """The data and the time (epoch) it was fetched, which is that of the cache."""
    with open(CACHE + ".lock", "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        try:
            fetched = os.stat(CACHE).st_mtime
            if time.time() - fetched < CACHE_SECONDS:
                with open(CACHE) as cache:
                    return json.load(cache), fetched
        except (OSError, ValueError):
            pass
        with urllib.request.urlopen(API, timeout=TIMEOUT) as response:
            data = json.load(response)
        with open(CACHE + ".tmp", "w") as cache:
            json.dump(data, cache)
        os.replace(CACHE + ".tmp", CACHE)
        return data, os.stat(CACHE).st_mtime


def moon():
    """(name, emoji, illuminated %) of the moon now."""
    age = ((time.time() - NEW_MOON) / 86400) % LUNATION
    name, emoji = PHASES[round(age / LUNATION * 8) % 8]
    return name, emoji, round((1 - math.cos(2 * math.pi * age / LUNATION)) / 2 * 100)


def describe(code):
    return CODES.get(code, ("Unknown", "cloudy"))[0]


def icon(code, day, tonight=False):
    """The emoji of the weather; `tonight`: at night, if clear or partly cloudy, the moon."""
    kind = CODES.get(code, ("", "cloudy"))[1]
    if tonight and not day and kind in ("sunny", "partly"):
        return moon()[1]
    return ICONS[kind][0 if day else 1]


def table(row):
    """A row of a table of the tooltip (pango markup). The emoji comes first: it
    has the same width in every row, so what follows lines up."""
    return f"<span font_family='{MONO_FONT}'>{row}</span>"


def rain_ahead(now, hourly, start):
    """(rain, probability %, mm) of the next two hours: the two hourly values
    after the current hour, which is over and is in `now`."""
    ahead = range(start + 1, start + 3)
    probability = max(hourly["precipitation_probability"][i] or 0 for i in ahead)
    millimetres = round(sum(hourly["precipitation"][i] or 0 for i in ahead), 1)
    wet = now["weather_code"] in WET or any(hourly["weather_code"][i] in WET for i in ahead)
    return wet or millimetres >= RAIN_MM, probability, millimetres


def hourly_rows(hourly, start):
    """Every two hours from the second, up to 8 hours from now."""
    for i in range(start + 2, min(start + 9, len(hourly["time"])), 2):
        temperature = f"{round(hourly['apparent_temperature'][i]):>2}°".ljust(9)  # as wide as "18° / 22°"
        yield table(
            f"{icon(hourly['weather_code'][i], hourly['is_day'][i])} {hourly['time'][i][11:]}  {temperature}  "
            f"{hourly['precipitation_probability'][i]:>3}%  {hourly['precipitation'][i]:>5.1f} mm"
        )


def daily_rows(daily):
    for d in range(3):
        day = "today" if d == 0 else DAYS[time.strptime(daily["time"][d], "%Y-%m-%d").tm_wday]
        yield table(
            f"{icon(daily['weather_code'][d], True)} {day:<5}  "
            f"{round(daily['temperature_2m_min'][d]):>2}° / {round(daily['temperature_2m_max'][d]):>2}°  "
            f"{daily['precipitation_probability_max'][d]:>3}%  {daily['precipitation_sum'][d]:>5.1f} mm"
        )


def build(data, fetched):
    now, hourly, daily = data["current"], data["hourly"], data["daily"]
    # now.time is local, "2026-10-08T14:15": its hour is in the hourly list
    start = hourly["time"].index(now["time"][:13] + ":00")
    soon = start + 2
    rain, probability, millimetres = rain_ahead(now, hourly, start)

    text = f"{icon(now['weather_code'], now['is_day'], tonight=True)} {round(now['apparent_temperature'])}°"
    # the rain of the next two hours only when the module is blue
    forecast = f"\n🌧️ {millimetres} mm • {probability}% chance" if rain else ""
    wind = f"{round(now['wind_speed_10m'])} km/h {WIND[round(now['wind_direction_10m'] / 45) % 8]}"
    lines = [
        f"{describe(now['weather_code'])} • {round(now['temperature_2m'])}° "
        f"(feels like {round(now['apparent_temperature'])}°)",
        "",
        f"Next 2 hours: {describe(hourly['weather_code'][soon])} • {round(hourly['apparent_temperature'][soon])}°{forecast}",
        "",
        f"🌀️ Wind {wind} (gusts {round(now['wind_gusts_10m'])})",
        f"💧 Humidity {now['relative_humidity_2m']}% • clouds {now['cloud_cover']}% • {round(now['pressure_msl'])} hPa",
        "",
        f"🌞 {daily['sunrise'][0][11:]} • 🌇 {daily['sunset'][0][11:]} • UV max {round(daily['uv_index_max'][0])}",
        "{1} {0} ({2}% lit)".format(*moon()),
        "",
        *hourly_rows(hourly, start),
        "",
        *daily_rows(daily),
        "",
        f"Open-Meteo • updated {time.strftime('%H:%M', time.localtime(fetched))}",
        "",
        "click: Windy • right click: ARPAL",
    ]
    return {"text": text, "tooltip": "\n".join(lines), "class": "rain" if rain else "dry"}


def main():
    try:
        print(json.dumps(build(*load())), flush=True)
    except (OSError, ValueError, KeyError, IndexError):
        print(json.dumps({"text": ""}), flush=True)


if __name__ == "__main__":
    main()
