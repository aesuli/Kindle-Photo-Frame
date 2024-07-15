#!/bin/sh

if [ ! -e $BASE_DIR/NO_LOGGING ]; then
  LOG_FILE=/mnt/us/photoframe/fbink.log
else
  LOG_FILE=/dev/null
fi

/usr/local/bin/fbink -i "$1" -g h=-2,w=-2,halign=CENTER,valign=CENTER -B WHITE -c -f >$LOG_FILE 2>&1

batt=$(lipc-get-prop com.lab126.powerd battLevel)
if [ $batt -lt 10 ]; then
  /usr/local/bin/fbink -x -1 -y -1 $batt >$LOG_FILE 2>&1
fi

