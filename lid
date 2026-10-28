#!/bin/zsh
# lid: keep your Mac awake with the lid closed, for a set number of minutes (macOS)
STATE=~/.lid-until          # epoch when awake mode ends
PM=/usr/bin/pmset
USER_NAME=$(id -un)

left() { local s=$1; printf "%dh %02dm" $((s / 3600)) $((s % 3600 / 60)); }
is_on() { $PM -g | grep -q 'SleepDisabled[[:space:]]*1'; }
need_setup() { echo "One-time setup needed: run  lid setup"; exit 1; }

check() {
  if ! is_on; then echo "OFF (Mac sleeps when the lid closes)"; return; fi
  local end=$(cat $STATE 2>/dev/null) now=$(date +%s)
  if [[ -n $end ]] && (( end > now )); then
    echo "ON until $(date -r $end +%H:%M) ($(left $((end - now))) left)"
  else
    echo "ON, no end time (turn off: lid off)"
  fi
}

help() {
  cat <<H
lid: stay awake with the lid closed

  lid on-<minutes>   stay awake for that long, e.g. lid on-120 = 2 hours
  lid off            go back to normal sleep now
  lid check          show whether it is on and the time left
  lid setup          one-time admin password, then no more prompts
  lid update         get the latest version
  lid uninstall      remove lid completely
  lid help           this list

Tip: don't leave a running Mac closed in a bag. It gets hot.
H
}

case ${1:-help} in
  help|-h|--help) help ;;
  check|status)   check ;;
  setup)
    f=$(mktemp)
    echo "$USER_NAME ALL=(root) NOPASSWD: $PM -a disablesleep 0, $PM -a disablesleep 1" > $f
    sudo sh -c "visudo -cf $f && install -m 440 -o root -g wheel $f /etc/sudoers.d/lid" \
      && echo "Done. lid no longer asks for a password."
    rm -f $f ;;
  update)
    tmp=$(mktemp)
    curl -fsSL https://raw.githubusercontent.com/mijanlab/lid-on/main/lid -o $tmp && zsh -n $tmp \
      && sudo install -m 755 $tmp /usr/local/bin/lid && echo "Updated." ; rm -f $tmp; exit ;;
  uninstall)
    sudo -n $PM -a disablesleep 0 2>/dev/null; pkill -f lid-timer; rm -f $STATE
    sudo rm -f /usr/local/bin/lid /etc/sudoers.d/lid && echo "lid removed."; exit ;;
  off)
    sudo -n $PM -a disablesleep 0 2>/dev/null || need_setup
    pkill -f lid-timer; rm -f $STATE; echo "Lid-closed awake OFF." ;;
  on-*)
    mins=${1#on-}
    [[ $mins =~ '^[1-9][0-9]*$' ]] || { echo "Use a whole number of minutes, e.g. lid on-120"; exit 1; }
    sudo -n $PM -a disablesleep 1 2>/dev/null || need_setup
    pkill -f lid-timer
    secs=$(( mins * 60 ))
    /usr/bin/perl -MPOSIX -e 'POSIX::setsid(); exec @ARGV' /bin/sh -c "sleep $secs; sudo -n $PM -a disablesleep 0; rm -f $STATE; : lid-timer" </dev/null >/dev/null 2>&1 &
    echo $(( $(date +%s) + secs )) > $STATE
    echo "Lid-closed awake $(check)" ;;
  *) echo "Unknown command: $1\n"; help; exit 1 ;;
esac
