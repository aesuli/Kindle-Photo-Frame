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
  if kill -0 $pid 2>/dev/null; then
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

changescreensaver()
{
	PICTURE_FILE="$PICTURE_DIR/$($BASE_DIR/random_file.sh "$PICTURE_DIR")"
	log "changescreensaver $PICTURE_FILE"
	$BASE_DIR/show.sh "$PICTURE_FILE"
}

wakeup()
{
	POWERD_STATE=$(lipc-get-prop -s com.lab126.powerd state)
	log "wakeup: $POWERD_STATE"
	if [ "$POWERD_STATE" == "screenSaver" ] || [ "POWERD_STATES" == "suspended" ] ; then
	  changescreensaver
	fi
}

setwakeup()
{
	DELTA=$(cat $DELTA_FILE)
	lipc-set-prop -i com.lab126.powerd rtcWakeup $DELTA
	log "setwakeup $DELTA"
}

lipc-wait-event -m com.lab126.powerd goingToScreenSaver,resuming,readyToSuspend | while read event; do
	case "$event" in
		goingToScreenSaver*)
			changescreensaver;;
		resuming*)
			wakeup;;
		readyToSuspend*)
			setwakeup;;
	esac
done;
