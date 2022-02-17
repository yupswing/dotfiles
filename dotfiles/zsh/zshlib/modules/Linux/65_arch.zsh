# if [[ $(uname -a) =~ "arch" ]]; then
if [ -f "/etc/arch-release" ]; then
  alias y=paru
  alias pac=pacman

  function pulse-again() {
    pulseaudio -k && pulseaudio --start && /home/simo/.config/polybar/launch.zsh
    \killall -v Discord
    \killall -v spotify
    sleep 2
    discord &
    spotify &
  }

  alias pacman_mirrors="sudo reflector --verbose \
                                      --latest 20 \
                                      --sort rate \
                                      --country Italy --country France --country Germany --country Switzerland \
                                      --protocol https --protocol rsync \
                                      --save /etc/pacman.d/mirrorlist"

  function maintenance() {
    if [[ -z "${LOCAL_MAINTENANCE_DIR}" ]]; then
      LOCAL_MAINTENANCE_DIR=$HOME/maintenance
    fi
    echo "* Maintenance dir: $LOCAL_MAINTENANCE_DIR"

    LOCAL_MAINTENANCE_PACMAN_DIR="$LOCAL_MAINTENANCE_DIR/pacman_backup"
    \mkdir -p $LOCAL_MAINTENANCE_PACMAN_DIR
    \rm $LOCAL_MAINTENANCE_PACMAN_DIR/date*
    touch $LOCAL_MAINTENANCE_PACMAN_DIR/date_$(date '+%Y_%m_%d')
    echo "---------------------------------------"
    echo "* Backup packages list"
    pacman -Qqe >$LOCAL_MAINTENANCE_PACMAN_DIR/packages.txt
    echo "---------------------------------------"
    echo "* Backup pacman database"
    tar -cjf $LOCAL_MAINTENANCE_PACMAN_DIR/pacman_database.tar.bz2 /var/lib/pacman/local
    echo "---------------------------------------"
    echo "* Remove orphaned packages"
    pacman -Qtdq | sudo pacman -Rns - # if no orphans were found the output is a error. all good

    command -v paru >/dev/null
    if [ $? -eq 0 ]; then
      echo "---------------------------------------"
      echo "* AUR: Clean unused dependencies"
      paru -c
      echo "---------------------------------------"
      echo "* AUR: Clean cache"
      paru -Sc # clean cache
    fi

    echo "---------------------------------------"
    echo ""
    echo "You may use 'ncdu' to check space usage"
    echo "You may use GUI 'BleachBit' to clean up unused space"
    echo "You may check broken link with 'find / -xtype l -print | less'"

    pacman -Qi linux-lts >/dev/null
    if [ $? -eq 1 ]; then
      echo ""
      echo "*** PLEASE INSTALL linux-lts FOR YOUR SAFETY***"
    fi

  }
fi
