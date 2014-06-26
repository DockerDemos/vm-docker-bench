#!/bin/sh
#What:		/proc/diskstats
#Description:
#		The /proc/diskstats file displays the I/O statistics
#		of block devices. Each line contains the following 14
#		fields:
#		 1 - major number
#		 2 - minor mumber
#		 3 - device name
#		 4 - reads completed successfully
#		 5 - reads merged
#		 6 - sectors read
#		 7 - time spent reading (ms)
#		 8 - writes completed
#		 9 - writes merged
#		10 - sectors written
#		11 - time spent writing (ms)
#		12 - I/Os currently in progress
#		13 - time spent doing I/Os (ms)
#		14 - weighted time spent doing I/Os (ms)
#		For more details refer to Documentation/iostats.txt
HOSTNAME="$(hostname)"
DATE="$(date '+%Y%m%d')"
BASE='/bench/results'
LOGFILE="$BASE/$DATE-$HOSTNAME-io.csv"

if [[ ! -d $BASE ]] ; then
  sudo mkdir -p $BASE
fi

sudo chmod 666 $LOGFILE

echo 'major number,minor number,device name,reads completed successfully,reads merged,sectors read,time spent reading (ms),writes completed,writes merged,sectors written,time spent writing (ms),I/Os currently in progress,time spent doing I/Os (ms),weighted time spent doing I/Os (ms)' >> $LOGFILE


while true ; do 
  echo "$(cat /proc/diskstats |grep sda \
  |sed -e 's/^[ \t]*//' | sed -e 's/[ ][ ]*/,/g')" >> $LOGFILE
  sleep 1s
done
