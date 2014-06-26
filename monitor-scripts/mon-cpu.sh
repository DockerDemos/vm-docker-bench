#!/bin/sh
#What:		/proc/stat
#Description:
#   user: normal processes executing in user mode
#   nice: niced processes executing in user mode
#   system: processes executing in kernel mode
#   idle: twiddling thumbs
#   iowait: waiting for I/O to complete
#   irq: servicing interrupts
#   softirq: servicing softirqs
#   steal: involuntary wait
HOSTNAME="$(hostname)"
DATE="$(date '+%Y%m%d')"
BASE='/bench/results'
LOGFILE="$BASE/$DATE-$HOSTNAME-cpu.csv"

if [[ ! -d $BASE ]] ; then
  sudo mkdir -p $BASE
fi

sudo chmod 666 $LOGFILE

echo 'user,nice,system,idle,iowait,irq,softirq,steal' >> $LOGFILE


while true ; do 
  echo "$(cat /proc/stat |grep cpu\
  |sed -e 's/^[ \t]*//' | sed -e 's/[ ][ ]*/,/g')" >> $LOGFILE
  sleep 1s
done
