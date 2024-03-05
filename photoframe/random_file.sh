#!/bin/sh

DIR=$1
COUNT=`ls "$DIR" | wc -l`

set -- `date '+%H %M %S'`
RND=`expr $$ \* $1 \* $2 \+ $3`
N=`expr \( $RND % $COUNT \) + 1`

ls "$DIR" | head -$N | tail -1
