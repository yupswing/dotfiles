#!/usr/bin/env sh
# Number of pending updates (repos + AUR), empty when up to date
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
  updates=$(cat "$CACHE")
else
  updates_arch=$(checkupdates 2>/dev/null | wc -l)
  updates_aur=$(paru -Qum 2>/dev/null | wc -l)
  updates=$((updates_arch + updates_aur))
  echo "$updates" >"$CACHE"
fi

if [ "$updates" -gt 0 ]; then
  echo "$updates"
else
  echo ""
fi
