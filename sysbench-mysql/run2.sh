#!/bin/sh

/run.sh &

sleep 15

sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=test --mysql-user=admin --mysql-password=rootmysqlpassword prepare
sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=test --mysql-user=admin --mysql-password=rootmysqlpassword --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=8 run

