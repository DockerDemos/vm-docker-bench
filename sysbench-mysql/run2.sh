#!/bin/sh
USER='admin'
PASS='rootmysqlpassword'

/run.sh &

sleep 15

sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=test \
	 --mysql-user=$USER --mysql-password=$PASS prepare

sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=test \
	 --mysql-user=$USER --mysql-password=$PASS --max-time=60 \
	 --oltp-read-only=on --max-requests=0 --num-threads=8 run

sysbench --test=oltp --mysql-db=test --mysql-user=$USER \
	 --mysql-password=$PASS cleanup
