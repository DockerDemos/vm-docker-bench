# Docker container with Sysbench installed
# for running multiple types of benchmark tests

FROM ubuntu:precise
MAINTAINER Chris Collins <collins.christopher@gmail.com>

RUN apt-get install -y sysbench

ENTRYPOINT ["sysbench"]
CMD ["--help"]
