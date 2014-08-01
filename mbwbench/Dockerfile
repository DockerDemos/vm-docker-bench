# Docker container with mbw installed
# for running memory benchmark tests

FROM centos:centos6
MAINTAINER Chris Collins <collins.christopher@gmail.com>

RUN yum install -y git gcc bc
RUN git clone https://github.com/raas/mbw.git /mbw
RUN cd /mbw/ && make
RUN cp /mbw/mbw /usr/bin/mbw
ADD run.sh /run.sh

CMD ["/run.sh"]
