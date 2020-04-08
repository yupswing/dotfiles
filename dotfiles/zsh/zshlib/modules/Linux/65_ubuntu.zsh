if [[ $(uname -a) =~ "Ubuntu" ]]; then
  # Ubuntu snaps (bleh)
  export PATH=$PATH:/snap/bin

  alias upgrade="sudo -- sh -c 'apt-get update; apt-get upgrade -y; apt-get dist-upgrade -y; apt-get autoremove -y; apt-get autoclean -y'"
fi
