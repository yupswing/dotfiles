#!/usr/bin/env zsh

# Minutes to wait before lock & powersave:
local MINS=5

# Set X power settings after an additional 30 seconds:
xset s $(( ${MINS} * 60 + 30 ))
xset dpms 0 0 $(( ${MINS} * 60 + 30 ))

# Run the real locking command every 15 minutes via xautolock:
xautolock -time ${MINS} -locker ~/.config/i3/scripts/lock.sh
