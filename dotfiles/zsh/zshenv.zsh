# ----------------------------------------------------------------------------
# ================================== ZSHENV ==================================
# ----------------------------------------------------------------------------

export LANGUAGE="en_GB.UTF-8"
export LANG="en_GB.UTF-8"
export LC_ALL="en_GB.UTF-8"
export TZ="Europe/Rome"

export EDITOR='nvim'
export VISUAL=$EDITOR

export DEFAULT_USER='simo'

export PATH="/opt/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games"
export PATH="$PATH:$HOME/.bin:$HOME/.local/bin"

export MIBS=all
export LOGD=/var/log

export YUPZSHRC_HOME="$HOME/.zshlib"
export YUPZSHRC_MODULES="$YUPZSHRC_HOME/modules"

# Pulseaudio config for polybar module
export YUP_PULSEAUDIO_SINKS_BLACKLIST="*.monitor,alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__source"

# Default:
# export XDG_CONFIG_HOME="$HOME/.config"
