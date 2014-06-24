#!/bin/sh

PRIME="$1"

sysbench --test=cpu --cpu-max-prime=$PRIME run
