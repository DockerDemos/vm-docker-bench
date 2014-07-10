#!/bin/sh
USER='admin'
PASS='rootmysqlpassword'

#sed -i 's|/var/run/mysqld/mysqld.sock|/tmp/mysql.sock|g' /etc/mysql/my.cnf
#sed -i "s|'rows_per_report', 1000000|'rows_per_report', 100000|" iibench.py
#sed -i "s|'setup', False|'setup', True|" iibench.py

chmod +x iibench.py

/run.sh &
sleep 15

echo 'rows seconds total_seconds cum_ips table_size last_ips queries cum_qps last_qps'
python iibench.py --db_user=$USER --db_password=$PASS --max_rows=1000000 \
	          --setup --rows_per_report=100000 \
		  --db_socket=/var/run/mysqld/mysqld.sock
