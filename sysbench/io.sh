#!/bin/sh

SIZE="$1"

sysbench --test=fileio --file-total-size=$SIZE prepare
sysbench --test=fileio --file-total-size=$SIZE --file-test-mode=rndrw --init-rng=on --max-time=300 --max-requests=0 run
sysbench --test=fileio --file-total-size=$SIZE cleanup

