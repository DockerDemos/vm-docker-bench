# Docker container with Sysbench and MySQL Server 
# installed for running MySQL benchmark tests

FROM tutum/mysql
MAINTAINER Chris Collins <collins.christopher@gmail.com>

ADD run2.sh /run2.sh 
ADD create_mysql_admin_user.sh /create_mysql_admin_user.sh
RUN apt-get update && apt-get install wget python python-mysqldb -y
RUN wget https://bazaar.launchpad.net/~mdcallag/mysql-patch/mytools/download/head:/iibench.py-20090327210349-wgv0sum50kpukctz-1/iibench.py

CMD ["/run2.sh"]
