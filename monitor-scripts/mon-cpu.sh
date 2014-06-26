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

sudo touch $LOGFILE
sudo chmod 666 $LOGFILE

echo 'x,user,nice,system,idle,iowait,irq,softirq,steal,guest,guest_nice' >> $LOGFILE


while true ; do 
  echo "$(cat /proc/stat |head -n 1\
  |sed -e 's/^[ \t]*//' | sed -e 's/[ ][ ]*/,/g')" >> $LOGFILE
  sleep 1s
done
