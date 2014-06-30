#!/bin/sh
#
# Version 1.0 (2014-06-30)
#
# What:		`free`
# Description:
#    total:   Full amount of memory allocated to the server
#    used:    Total memory used, including buffers and cache
#    free:    Memory available, and not being used for buffers or cache
#    shared:  Memory used and available to multiple CPUs
#    buffers: Memory dedicated to cache disk block devices
#    cached:  Memory dedicated to caching pages from file reads

echo 'total,used,free,shared,buffers,cached'

while true; do
  free -m |awk '/Mem/ { OFS = ","; print $2, $3, $4, $5, $6, $7}'
  sleep 1s
done
