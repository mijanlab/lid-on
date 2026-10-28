#!/bin/sh
# Installs `lid` to /usr/local/bin and runs the one-time setup (asks for your Mac password once).
# Local: sh install.sh    Remote: curl -fsSL https://raw.githubusercontent.com/mijanlab/lid-on/main/install.sh | sh
set -e
SRC=""
[ -f "$0" ] && [ "$(basename "$0")" = install.sh ] && SRC="$(dirname "$0")/lid"
if [ ! -f "$SRC" ]; then
  LID_URL=${LID_URL:-https://raw.githubusercontent.com/mijanlab/lid-on/main/lid}
  SRC=$(mktemp); curl -fsSL "$LID_URL" -o "$SRC"
fi
sudo mkdir -p /usr/local/bin
sudo install -m 755 "$SRC" /usr/local/bin/lid
/usr/local/bin/lid setup
echo "Installed. Try: lid help"
