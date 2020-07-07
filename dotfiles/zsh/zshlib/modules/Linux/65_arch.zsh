# if [[ $(uname -a) =~ "arch" ]]; then
if [ -f "/etc/arch-release" ]; then
  alias y=yay
  alias pac=pacman

  function pulseagain() {
    pulseaudio -k && pulseaudio --start && /home/simo/.config/polybar/launch.zsh
    \killall -v Discord
    \killall -v spotify
    sleep 2
    discord &
    spotify &
  }
fi
