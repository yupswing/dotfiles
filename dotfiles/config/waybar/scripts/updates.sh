#!/usr/bin/env sh
# Pending updates (repos + AUR) as waybar JSON: the total as text (empty when up
# to date), the pacman/AUR split as tooltip
# (port of polybar's checkupdates.sh)
# Requires: pacman-contrib (checkupdates), paru

# One bar per monitor runs this at the same moment, and two concurrent
# `checkupdates` fail ("Cannot fetch updates"): run one at a time and let the
# others reuse its fresh result
CACHE="${XDG_RUNTIME_DIR:-/tmp}/waybar-updates"
CACHE_SECONDS=30

exec 9>"$CACHE.lock"
flock 9

if [ -f "$CACHE" ] && [ $(($(date +%s) - $(stat -c %Y "$CACHE"))) -lt $CACHE_SECONDS ]; then
  read -r updates_arch updates_aur <"$CACHE"
else
  updates_arch=$(checkupdates 2>/dev/null | wc -l)
  updates_aur=$(paru -Qum 2>/dev/null | wc -l)
  echo "$updates_arch $updates_aur" >"$CACHE"
fi

updates=$((${updates_arch:-0} + ${updates_aur:-0}))

if [ "$updates" -gt 0 ]; then
  printf '{"text": "%s", "tooltip": "pacman: %s\\nAUR: %s"}\n' "$updates" "${updates_arch:-0}" "${updates_aur:-0}"
else
  echo '{"text": ""}'
fi
