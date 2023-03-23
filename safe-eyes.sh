#!/bin/bash

##################################################################################
# Simple break reminder based on YAD. Inspired by https://github.com/slgobinath/SafeEyes.
# Motivation: Limit number of dependencies and be simpler than original SafeEyes.
# Usage: ./safe-eyes.sh start
##################################################################################

# ----------- CONFIG ---------------
WORK_TIME_IN_SECONDS=$((20*60))
BREAK_TIME_IN_SECONDS=$((1*60))
# ----------------------------------

_break_countdown(){
    for i in `seq 1 $BREAK_TIME_IN_SECONDS`;
    do
        echo $((100*$i/$BREAK_TIME_IN_SECONDS))
        sleep 1
    done
    return 1;
}

_break_dialog() {
  if [[ `_is_webcam_used` == 1 ]]; then
    echo "Webcam used - skipping break"
    return
  fi

  # TODO "GDK_BACKEND=x11" is workaround on Wayland to prevent minimizing break dialog (i.e. skip break) trough shortcuts like "showing desktop (Win+D)"
  # original "safeeyes" locks keyboard: https://github.com/slgobinath/SafeEyes/blob/master/safeeyes/ui/break_screen.py#L239
  # possible solution: fork process to focus on break dialog using "wmctrl" every 1s
  _break_countdown | GDK_BACKEND=x11 yad --progress --no-escape --sticky --on-top  --undecorated --skip-taskbar --fullscreen  --timeout="${BREAK_TIME_IN_SECONDS}" \
  --text="\n${BREAK_TIME_IN_SECONDS} seconds break"  --hide-text --text-align=center --css='*{background-color: #31363b; color: #fcfcfc; font: 25px Sans;}' \
  --no-buttons

  _beep_end_of_break
}

# returns 1 if true, 0 otherwise
_is_webcam_used() {
  lsmod | grep ^uvcvideo | rev | cut -d' ' -f-1
}

_beep_end_of_break() {
  # if doesn't work, search other sounds at /usr/share/sounds/..
  paplay /usr/share/sounds/Oxygen-Sys-App-Message.ogg
}

_main_program() {
  while true
  do
    sleep ${WORK_TIME_IN_SECONDS}

    # TODO get time from journal to postpone if needed
     # https://superuser.com/questions/357275/how-to-find-the-uptime-since-last-wake-from-standby
     # datediff -f%H:%M:%S  $(journalctl -n4 -u sleep.target -o short-iso | tail -n 1 | cut -d' ' -f 1) now
     # journalctl -q -n1 -u sleep.target -o json | jq -r ._SOURCE_REALTIME_TIMESTAMP
     #journalctl -n1 --grep USER_AUTH
     #journalctl -n10 --grep sleep.target

    _break_dialog
  done
}

case "$1" in
  start)
    if [[ `pgrep -cf "$(basename $0) start"` -gt 1 ]]; then
      echo "Already started - skipping"
      exit 0
    fi
    _main_program 2>& 1 & # run in background
    exit 0 ;;
  stop)
    pkill -e -9 -f "$(basename $0) start"
    exit 0 ;;
  help | --help | -help | "") # prints this help
    echo "Usage: $0 [start|stop]"
    echo
    echo "Current configuration:"
    echo "\$WORK_TIME_IN_SECONDS: $WORK_TIME_IN_SECONDS"
    echo "\$BREAK_TIME_IN_SECONDS: $BREAK_TIME_IN_SECONDS"
    echo "(edit source code in order to change config)"
    exit 0 ;;
esac
