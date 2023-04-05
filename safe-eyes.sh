#!/bin/bash

#########################################################################################
# Simple break reminder based on YAD. Inspired by https://github.com/slgobinath/SafeEyes.
# Motivation: Limit number of dependencies and be simpler than original SafeEyes.
# Usage: ./safe-eyes.sh start
#########################################################################################

MY_PATH="$(dirname $0)"

if [ ! -f $MY_PATH/config-current.sh ]; then
  # copy default config if not exists
  cp $MY_PATH/config-default.sh $MY_PATH/config-current.sh
fi
source $MY_PATH/config-current.sh

DEBUG=false
DEBUG_LOG_PATH=$MY_PATH/debug.log

_break_countdown() {
  for i in $(seq 1 $BREAK_TIME_IN_SECONDS); do
    LAST_LOCK=$(_seconds_since_last_event 'screenlocker')
    if ((BREAK_TIME_IN_SECONDS > LAST_LOCK)); then
      pkill -f "safe-eyes-break"
    fi
    echo $((100 * i / BREAK_TIME_IN_SECONDS))
    sleep 1
  done
}

_log() {
  if ${DEBUG}; then
    local msg="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $msg" >>$DEBUG_LOG_PATH
  fi
}

_break_dialog() {

  if [[ $(_is_webcam_used) == 1 || $(_is_microphone_used) == 1 ]]; then
    _log "Webcam or microphone used - skipping break"
    return
  fi

  _log "break"

  # TODO "GDK_BACKEND=x11" is workaround on Wayland to prevent minimizing break dialog (i.e. skip break) trough shortcuts like "showing desktop (Win+D)"
  # original "safeeyes" locks keyboard: https://github.com/slgobinath/SafeEyes/blob/master/safeeyes/ui/break_screen.py#L239
  # possible solution: fork process to focus on break dialog using "wmctrl" every 1s
  _break_countdown | GDK_BACKEND=x11 yad --progress --title="safe-eyes-break" --no-escape --sticky --on-top --undecorated --skip-taskbar --fullscreen --timeout="${BREAK_TIME_IN_SECONDS}" \
    --text="\n${BREAK_TIME_IN_SECONDS} seconds break" --hide-text --text-align=center --css='*{background-color: #31363b; color: #fcfcfc; font: 25px Sans;}' \
    --no-buttons

  _beep_end_of_break
}

# returns 1 if true, 0 otherwise
_is_webcam_used() {
  lsmod | grep ^uvcvideo | rev | cut -d' ' -f-1
}

# returns 1 if true, 0 otherwise
_is_microphone_used() {
  pactl list sources | grep -c RUNNING
}

_beep_end_of_break() {
  # if doesn't work, search other sounds at /usr/share/sounds/..
  paplay /usr/share/sounds/Oxygen-Sys-App-Message.ogg
}

_seconds_since_last_event() {
  local event_keyword="$1"
  # https://superuser.com/questions/357275/how-to-find-the-uptime-since-last-wake-from-standby
  LAST_LOGIN_TIMESTAMP=$(journalctl -n1 --grep "$event_keyword" -o short-unix | cut -d. -f1)
  TIMESTAMP=$(date +%s)
  DIFF=$((TIMESTAMP - LAST_LOGIN_TIMESTAMP))
  echo $DIFF
}

_postpone_break_if_screen_was_locked() {
  LAST_LOGIN=$(_seconds_since_last_event 'USER_AUTH')
  POSTPONE=$((WORK_TIME_IN_SECONDS - LAST_LOGIN))
  if ((POSTPONE > 0)); then
    _log "Detected locked screen - postponing break by $POSTPONE seconds"
    sleep ${POSTPONE}
  fi
}

_main_program() {
  _log "Program has started"
  while true; do
    sleep ${WORK_TIME_IN_SECONDS}

    _postpone_break_if_screen_was_locked

    _break_dialog
  done
}

case "$1" in
start)
  if [[ $(pgrep -cf "$(basename $0) start") -gt 1 ]]; then
    echo "Already started - skipping"
    exit 0
  fi
  if [[ "$2" == "--debug" ]]; then
    echo "Program will save logs at $DEBUG_LOG_PATH"
    DEBUG=true
  fi
  _main_program 2>&1 & # run in background
  exit 0
  ;;
stop)
  pkill -e -9 -f "$(basename $0) start"
  exit 0
  ;;
config)
  vi config-current.sh
  exit 0
  ;;
help | --help | -help | "") # prints this help
  echo "Usage: $0 [start|stop|config]"
  exit 0
  ;;
esac
