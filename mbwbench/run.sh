#! /usr/bin/env bash
# This will run an mbw instance for each core on the machine
#
# This script from: http://jamesslocum.com/post/64209577678

NUMCORES=$(grep "processor" /proc/cpuinfo | wc -l)
TMP="/tmp/mbw_result_tmp"

echo "Starting test on $NUMCORES cores"
for (( i=0; i<$NUMCORES; i++ )); do
   mbw -b 4096 32 -n 100 > ${TMP}_${i} & 
done

echo "Waiting for tests to finish"
wait

MEMCPY_RESULTS=()
DUMB_RESULTS=()
MCBLOCK_RESULTS=()

for (( i=0; i<$NUMCORES; i++ )); do
   MEMCPY_RESULTS[$i]=`grep -E "AVG.*MEMCPY" ${TMP}_${i} | \
      tr "[:blank:]" " " | cut -d " " -f 9`

   DUMB_RESULTS[$i]=`grep -E "AVG.*DUMB" ${TMP}_${i} | \
      tr "[:blank:]" " " | cut -d " " -f 9`

   MCBLOCK_RESULTS[$i]=`grep -E "AVG.*MCBLOCK" ${TMP}_${i} | \
      tr "[:blank:]" " " | cut -d " " -f 9`
done

MEMCPY_SUM=0
DUMB_SUM=0
MCBLOCK_SUM=0

# Need to use `bc` because of floating point numbers
for (( i=0; i<$NUMCORES; i++ )); do
   MEMCPY_SUM=`echo "$MEMCPY_SUM + ${MEMCPY_RESULTS[$i]}" | bc -q`
   DUMB_SUM=`echo "$DUMB_SUM + ${DUMB_RESULTS[$i]}" | bc -q`
   MCBLOCK_SUM=`echo "$MCBLOCK_SUM + ${MCBLOCK_RESULTS[$i]}" | bc -q`
done

echo "MEMCPY Total AVG: $MEMCPY_SUM MiB/s"
echo "DUMB Total AVG: $DUMB_SUM MiB/s"
echo "MCBLOCK Total AVG: $MCBLOCK_SUM MiB/s"
