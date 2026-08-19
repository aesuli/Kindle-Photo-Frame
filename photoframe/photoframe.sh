#!/bin/sh

BASE_DIR=$(dirname $0)
LOG_FILE=$BASE_DIR/photoframe.log
DELTA_FILE=$BASE_DIR/delta.txt
PICTURE_DIR="/mnt/us/documents/pictures"
PID_FILE=$BASE_DIR/pidfile

log()
{
	[ ! -e $BASE_DIR/NO_LOGGING ] &&  echo "[$$] $(date): $1" >> $LOG_FILE
}

if [ -f $PID_FILE ]; then
  pid=$(cat $PID_FILE)
  if kill -0 $pid 2>/dev/null && grep -q photoframe.sh /proc/$pid/cmdline 2>/dev/null; then
    log "photoframe is already running pid=$pid"
    exit 1
  else
    log "starting photoframe base_dir=$BASE_DIR pid=$$"
    echo $$ > $PID_FILE
  fi
else
    log "starting photoframe base_dir=$BASE_DIR pid=$$"
  echo $$ > $PID_FILE
fi

trap 'rm -f $PID_FILE' EXIT INT TERM

changescreensaver()
{
	PICTURE_FILE="$PICTURE_DIR/$($BASE_DIR/random_file.sh "$PICTURE_DIR")"
	log "changescreensaver $PICTURE_FILE"
	sleep 3
	$BASE_DIR/show.sh "$PICTURE_FILE"
}

wakeup()
{
	POWERD_STATE=$(lipc-get-prop -s com.lab126.powerd state)
	log "wakeup: $POWERD_STATE"
	if [ "$POWERD_STATE" == "screenSaver" ] || [ "$POWERD_STATE" == "suspended" ] ; then
	  changescreensaver
	fi
}

setwakeup()
{
	DELTA=$(cat $DELTA_FILE)
	lipc-set-prop -i com.lab126.powerd rtcWakeup $DELTA
	log "setwakeup $DELTA"
}

while true; do
	lipc-wait-event -m com.lab126.powerd goingToScreenSaver,resuming,wakeupFromSuspend,readyToSuspend | while read event; do
		case "$event" in
			goingToScreenSaver*)
				changescreensaver;;
			resuming*)
				wakeup;;
			wakeupFromSuspend*)
				wakeup;;
			readyToSuspend*)
				setwakeup;;
		esac
	done
	log "lipc-wait-event exited unexpectedly, restarting"
	sleep 1
done
