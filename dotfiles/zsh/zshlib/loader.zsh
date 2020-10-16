# ============================================================================
# Loading function

function loadRC() {
  # Load all .zsh in a folder
  if [ -d $1 ]; then
    for zshFile in $1/*.zsh; do
      source $zshFile
    done
  fi
  unset zshFile
}

# ============================================================================
# Load main library
loadRC $YUPZSHRC_MODULES

# ============================================================================
# Load platform library (Darwin, Linux...)
loadRC "$YUPZSHRC_MODULES/$(uname -s)"

# ============================================================================
# Load hostname library
hostnameDir="$YUPZSHRC_MODULES/Hostname/$(cat /proc/sys/kernel/hostname)"
if [ -d $hostnameDir ]; then
  loadRC $hostnameDir
fi

# ============================================================================
# Local (per Host) customizations
for localDir in ~ /etc/zsh /etc /usr/local/etc /usr/local/etc/zsh; do
  if [ -f ${localDir}/zshrc.local ]; then
    source ${localDir}/zshrc.local
  fi
done

# ============================================================================
# Unset temporary variables and functions

unset hostnameDir
unset localDir
unset loadRC
