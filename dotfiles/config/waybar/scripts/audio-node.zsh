#!/usr/bin/env zsh
# Waybar module to show and rotate the default PulseAudio sink/source
# (port of polybar's audio-pulse-output.conf / audio-pulse-input.conf)
# Requires: pulseaudio-control
#
# Usage: audio-node.zsh <output|input> <listen|next|mute|up|down>

TYPE=${1:-output}
ACTION=${2:-listen}

# Nicknames: icomoon-feather icons ( headphones,  speaker,
#  mic,  monitor)
# to make nicknames use `pactl list sinks short | cut -f2`
# or `pactl list sources short | cut -f2`
if [[ $TYPE == input ]]; then
  BLACKLIST=${YUP_PULSEAUDIO_SOURCES_BLACKLIST:-*.monitor}
  NICKNAMES=(
    "bluez_input.50:F3:51:E5:1E:6E:"$''
    "alsa_input.usb-GeneralPlus_USB_Audio_Device-00.mono-fallback:"$''
    "alsa_input.usb-Corsa_ir_Components_Inc._CORSAIR_HS60_PRO_SURROUND_v0.1-00.mono-fallback:"$''
    "alsa_input.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Mic1__source:"$''
  )
else
  BLACKLIST=${YUP_PULSEAUDIO_SINKS_BLACKLIST:-*HDMI*,*hdmi*}
  NICKNAMES=(
    "bluez_output.50_F3_51_E5_1E_6E.1:"$''
    "alsa_output.usb-GeneralPlus_USB_Audio_Device-00.analog-stereo:"$''
    "alsa_output.usb-Corsa_ir_Components_Inc._CORSAIR_HS60_PRO_SURROUND_v0.1-00.analog-stereo:"$''
    "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__Speaker__sink:"$''
  )
fi

ARGS=(--node-type $TYPE --node-blacklist $BLACKLIST --volume-max 150)

case $ACTION in
listen)
  for n in $NICKNAMES; do ARGS+=(--node-nickname $n); done
  # one JSON line per change: waybar adds the `muted` class (colors from CSS)
  pulseaudio-control $ARGS --node-nicknames-from "device.description" \
    --color-muted "" --format '$IS_MUTED $NODE_NICKNAME' listen |
    while read -r line; do
      # drop the polybar color tags wrapped around the muted output
      line=${line//'%{F#}'/}
      line=${line//'%{F-}'/}
      muted=${line%% *}
      name=${line#* }
      name=${name//\\/\\\\}
      name=${name//\"/\\\"}
      [[ $muted == yes ]] && class=muted || class=
      print -r -- "{\"text\":\"$name\",\"class\":\"$class\"}"
    done
  ;;
next) pulseaudio-control $ARGS next-node ;;
mute) pulseaudio-control $ARGS togmute ;;
up | down) pulseaudio-control $ARGS $ACTION ;;
esac
