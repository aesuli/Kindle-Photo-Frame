#!/bin/sh

LOG_FILE="./photoframe.log"
DELTA_FILE="./delta.txt"
PICTURE_DIR="/mnt/us/documents/pictures"

log()
{
	[ ! -e ./NO_LOGGING ] &&  echo "[$$] `date`: $1" >> $LOG_FILE
}

changescreensaver()
{
	log "changescreensaver"
	PICTURE_FILE=`./random_file.sh "$PICTURE_DIR"`
	./show.sh "$PICTURE_DIR/$PICTURE_FILE"
}

wakeup()
{
	POWERD_STATE=`lipc-get-prop -s com.lab126.powerd state`
	log "wakeup: $POWERD_STATE"
	if [ "$POWERD_STATE" == "screenSaver" ] || [ "POWERD_STATES" == "suspended" ] ; then
	  changescreensaver
	fi
}

setwakeup()
{
	delta=`cat $DELTA_FILE`
	lipc-set-prop -i com.lab126.powerd rtcWakeup $delta
	log "setwakeup $delta"
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
