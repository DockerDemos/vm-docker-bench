Hypervisor + Docker Performance Benchmark
=========================================================

1. [Forward](#forward)
2. [Method](#method)
    1. [System Specs](#specs)
    2. [Host Benchmarks](#host_bench)
        * Serial container Boot
        * Container reboot
        * Container commit (snapshot)
    3. [Guest Benchmarks](#guest_bench)
        * CPU Performance
        * MySQL Performance
        * MySQL
        * File I/O Operation
        * (Modified) File I/O Operation
        * Memory Performance
        * Network Performance
        * Application type performance (Blogbench)
        * Application type performance (Apache Benchmark)
3. [Hypervisor + Docker Performance Benchmark](#vmhdp)
    1. [Host Benchmark Results](#host_results)
    2. [Guest Benchmark Results](#guest_results)


##<a name='forward'>Forward</a>##

##<a name='method'>Method</a>##

In order to cover as many bases as possible, the tests were run as follows:

1. On the Cisco USC blade with CoreOS installed
2. On the Cisco UCS blade with a hypervisor and a single VM with CoreOS installed
3. On a separate physical machine with the same hypervisor and a single VM with Coreos installed.

**Data Gathering**

_Host Benchmark Data_:

For each of the Host Benchmarks, multiple datapoints are collected using the [Resource Monitoring Scripts](https://github.com/DockerDemos/vm-docker-bench/tree/master/monitor-scripts) included in this repository.  These scripts were started prior to each test and collected data throughout.  Each monitors a specific aspect of the host's resources at set intervals and outputs to a remote log file via and SSH tunnel.

 * CPU Load average
 * Memory Usage
 * File I/O
 * Network Performance (if applicable)

The scripts were all placed on the host server via the CoreOS cloud-config.yml file.

_Guest Benchmark Data_:

Test data for guest benchmarks running from within the tested container was gathered via STDOUT from the containers themselves (for exampe the CPU performance testing times) and written to a remote log file via an SSH tunnel.

Test data for guest benchmarks being performed from remote hosts (for example, the Application Type Perfomance Apache Benchmark tests) were recorded via STDOUT from the process itself and written to a logfile.

**Literal Method**

This is here mostly just to help me keep the steps straight.

| SSH Session 1                      | SSH Sesson 2                          |
| -------------                      | ------------                          |
| Reboot (PXE Install)               |                                       |
| Login                              | Login                                 |
| Wait 10m for host to become stable | Wait 10 Min                           |
|                                    | Su to Root                            |
|                                    | Export REPO=(private docker registry) |
|                                    | Run clear cache script                |
| Start monitor script; out via SSH  |                                       |
| Wait 1m for base stats             |                                       |
|                                    | Run test script; out via SSH          |
| Wait 5m for base stats             |                                       |
| Stop monitor script                |                                       |

###<a name='specs'>System Specs</a>###

**Hardware**

|            | Primary System                | Secondary (control) System                 |
| ----       | --------------                | ----------------                           |
| Hardware   | Cisco UCS Blade CCSB-B200-M3  | Cisco UCS Blade CSSB-B200-M3               |
| Version    | B200M3.2.1.3a.0.082320131800  | B200M3.2.1.3a.0.082320131800               |
| CPU        | Intel E5-2665 @ 2.4GHz 8 Core | Intel E5-2697 v2 @ 2.70GHz 12 Core         |
| Memory     | 256GB 1600                    | 256GB 1866                                 |
| HDD        | Toshiba 300GB SAS 15KRPM      | EMC VNX5700 Array, 2TB 7200RPM (50 disks)  |

|            | Primary System w/Hypervisor      | Control System w/Hypervisor       |
| ----       | ---------------------------      | ----------------------------        |
| CPU        | Intel E5-2665 @ 2.4GHz (2 Cores) | Intel E5-2697 v2 @ 2.70GHz (2 Cores)|
| Memory     | 8GB 1600                         | 8GB 1866                            |
| HDD        | Virtual                          | Virtual                             |

**OS: CoreOS** 

Version:  Beta 324.5.0

[CoreOS](https://coreos.com) was chosen as the host OS for each of these tests.  The OS was PXE booted and configured with the CoreOS Cloud Config YAML file included in this repo.  The operating system was installed into RAM, and /var/lib/docker mounted to the first local hard disk.

**Docker**

Version: 0.11.1, build fb99f99

###<a name='host_bench'>Host Benchmarks</a>###
__Serial Container Boot__

The [Docker image with Apache and PHP](https://github.com/DockerDemos/vm-docker-bench/tree/master/) included in this repository was created to test performance during serial boot of fifteen and one hundred containers.  These two tests were performed two ways:

 * CoreOS starting 15 or 100 containers
 * Hypervisor with CoreOS starting 15 or 100 containers

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    #
    # Version 1.0 (2014-06-30)
    #
    # This image was uploaded to our private repository
    # server for ease of testing.
    # It can be built from the Docker files at
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/webbench
    #
    # Starts N number of Docker containers running
    # Apache and a basic PHP "Hello World" file.
    #
    COUNT="$1"
    docker pull $REPO/bench-webbench >> /dev/null
    for i in $(seq 1 $COUNT) ; do docker run -d $REPO/bench-webbench ; done

__Compute node steady-state Container Packing__

Using the Docker image with Apache and PHP from above, this test measures resource usage of fifteen and one hundred containers for fifteen minutes, from startup to when they have reached their "active" state, and finally shutdown.  The tests were performed two ways:
  * CoreOS starting 15 or 100 containers
  * Hypervisor with CoreOS starting 15 or 100 containers

The bash script from the above Serial Container Boot test was reused for this test. 

__Container Reboot__

Using the Docker image with Apache and PHP from above, this test measures resource usage over time as five containers are started, reach their stable "active" state fifteen minute wait), shutdown and deleted.  This process was repeated five times, and the results recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository
    # server for ease of testing.
    # It can be built from the Docker files at
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/webbench
    #
    # Starts 15 of Docker containers running
    # Apache and a basic PHP "Hello World" file.
    #
    COUNT="15"
    docker pull $REPO/webbench
    for n in {1..5} ; do
      for i in $(seq 1 $COUNT) ; do docker run -rm -i -t $REPO/webbench ; done
      sleep 5m
      docker ps | awk '{print $1}' |xargs docker stop
      sleep 5m
    done

__Container Commit (snapshot)__

TODO

###<a name='guest_bench'>Guest Benchmarks</a>###

__CPU Performance__

[Sysbench](http://sysbench.sourceforge.net/) was chosen to perform a number of benchmark tests, including this cpu computation benchmark.  The tests used the [Sysbench Docker image](https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench) included in this repository.  The resulting container was started, and ran `sysbench --test=cpu --cpu-max-prime=20000 run` (via the [cpu_prime.sh script](https://github.com/DockerDemos/vm-docker-bench/blob/master/sysbench/cpu_prime.sh)).  This process was repeated one hundred (100) times, and the total time taken for the test execution was recorded for each.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench
    #
    # Tests CPU calculations by running a prime number 
    # calculation benchmark test in 100 Docker 
    # containers, serially.
    docker pull $REPO/sysbench
    for i in {1..100} ; do docker run -i -t $REPO/sysbench \
    cpu_prime.sh 20000 | grep total\ time\: \
    | awk '{print $3}'| sed -i 's/s//g' ; done

__MySQL Performance__

Sysbench was also used to test MySQL performance (reads, writes, transactions, etc).  A Docker container based on the [tutum/mysql image](https://github.com/tutumcloud/tutum-docker-mysql) with MySQL + Sysbench installed was created and is available in this repository [\(https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench-mysql\)](https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench-mysql).

On startup, the container sets up the MySQL server and database, and then runs the following, recording results:

    sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=test --mysql-user=admin \
    --mysql-password=rootmysqlpassword prepare
    sysbench --test=oltp --oltp-table-size=1000000 --mysql-db=test --mysql-user=admin \
    --mysql-password=rootmysqlpassword --max-time=60 --oltp-read-only=on \
    --max-requests=0 --num-threads=8 run

This test was run one hundred times, serially, and the output recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench-mysql
    #
    # Tests MySQL performance with read, write and transaction
    # tests in 100 Docker containers, serially.
    docker pull $REPO/sysbench-mysql
    for i in {1..100} ; do docker run -i -t $REPO/sysbench-mysql 
    done

__MySQL__

"Indexed insertion benchmark"

(iibench, 1M inserts print stats at 100K)

__File I/O Operation__

 _Note: This test may not be an accurate representation of actual results.  The available disk space on each host was not large enough to create a file big enough to prevent caching in memory.  See the "Modified File I/O Operation" test below for a second, but probably still not 100% accurate, test._

File I/O benchmarking was done using the same [Sysbench Docker image](https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench) used for the CPU tests above.  The container was started, and ran (via the [io.sh script](https://github.com/DockerDemos/vm-docker-bench/blob/master/sysbench/io.sh)):

    sysbench --test=fileio --file-total-size=10G prepare
    sysbench --test=fileio --file-total-size=10G --file-test-mode=rndrw \
    --init-rng=on --max-time=300 --max-requests=0 run
    sysbench --test=fileio --file-total-size=10G cleanup

This test was run one hundred times, serially, and the Kb/sec value from the test output recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench
    #
    # Tests disk IO with a combined *Random Read and Write*
    # test in 100 Docker containers, serially.
    docker pull $REPO/sysbench
    for i in {1..100} ; do docker run -i -t $REPO/sysbench \
    /bench/io.sh 5G \ 
    |grep total\ time\: \
    | awk '{print $3}'| sed -i 's/s//g' ; done

__(Modified) File I/O Operation__

This is the exact same test as the File I/O Operation test above, but with memory limitations in place on the Docker containers (512MB).

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench
    #
    # Tests disk IO with a combined *Random Read and Write*
    # test in 100 Docker containers, serially, with a 
    # 512MB memory limit enforced on the containers.
    docker pull $REPO/sysbench
    for i in {1..100} ; do docker run -i -t -m=524288 $REPO/sysbench \
    /bench/io.sh 5G \ 
    |grep total\ time\: \
    | awk '{print $3}'| sed -i 's/s//g' ; done

__Memory Performance__

(`mbw 10001 mbw array size of 1000 MiB)

__Network Performance__

(netperf server on contol server, netperf in ipv4 on guest)

__Application type performance (Blogbench)__

[Blogbench](http://www.pureftpd.org/project/blogbench) was used to simulate file I/O as it would exist on a webserver, with mostly-read, some-write traffic.  The tests used the [Blogbench Docker image](https://github.com/DockerDemos/vm-docker-bench/tree/master/blogbench) included in this repository.  The resulting container was started and ran `blogbench -c 30 -i 20 -r 40 -W 5 -w 5 --directory=/srv`.  This process was repeated one hundred times and the results recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository
    # server for ease of testing.
    # It can be built from the Docker files at
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/blogbench
    #
    # Tests file I/O operations simulating a 
    # real-world server.
    docker pull $REPO/blogbench
    for i in {1..100} ; do docker run -i -t $REPO/blogbench \
    -c 30 -i 20 -r 40 -W 5 -w 5 --directory=/srv ; done

__Application type performance (Apache + PHP)__

Very basic application performance testing was done using the same [Apache + PHP Docker image](https://github.com/DockerDemos/vm-docker-bench/tree/master/webbench) used for the serial container boot host benchmark tests above.  In addition, a [Docker image with Apache Bench](https://github.com/DockerDemos/vm-docker-bench/tree/master/abbench) was created to be run from another location (Laptop, second server, etc) to test the performance of the Apache + PHP container.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository
    # server for ease of testing.
    # It can be built from the Docker files at
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/webbench
    #
    # Starts N number of Docker containers running
    # Apache and a basic PHP "Hello World" file.
    #
    docker pull $REPO/webbench
    docker run -d -p 80:80 $REPO/webbench 

Then, from a remote host (in this case, my laptop), the following script was run to initiate the Apache Benchmark tests, grabbing the contents of the index.php "Hello World" file one million (1,000,000) times, with four requests at a time:

    #!/bin/bash
    # This image was uploaded to our private repository
    # server for ease of testing.
    # It can be built from the Docker files at
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/abbench
    #
    # $DOCKER_BENCHMARK_HOST should be the name or IP of the Docker 
    # host server being tested.
    #
    # Starts the Apache Benchmark program with any flags specified
    # by the command passed to Docker
    #
    docker pull $REPO/abbench
    docker run -i -t $REPO/abbench -n 1000000 -c 4 http://$DOCKER_BENCHMARK_HOST/index.php


##<a name='vmhdp'>Hypervisor + Docker Performance Benchmark</a>##

###<a name='host_results'>Host Benchmark Results</a>###

__Serial Container Boot__

![Graph of Primary System w/no Hypervisor, Serial Container Boot Test](/raw-results/primary_no_hypervisor-serial-container-boot.png?raw=true "Graph of Primary System w/no Hypervisor, Serial Container Boot Test")


![Graph of Control System, Serial Container Boot Test](/raw-results/control-serial-container-boot.png?raw=true "Graph of Control System, Serial Container Boot Test")

__Compute node steady-state Container Packing__

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test](/raw-results/primary_no_hypervisor-ssp-15.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (15) Test")

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test: Boot Detail](/raw-results/primary_no_hypervisor-ssp-15-boot_detail.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (15) Test: Boot Detail")

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test: Shutdown Detail](/raw-results/primary_no_hypervisor-ssp-15-shutdown_detail.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (15): Shutdown Detail Test")

![Graph of Control System, Steady-State Packing Test](/raw-results/control-ssp-15.png?raw=true "Graph of Control System, Steady State Packing (15) Test")

![Graph of Control System, Steady-State Packing Test: Boot Detail](/raw-results/control-ssp-15-boot_detail.png?raw=true "Graph of Control System, Steady State Packing (15) Test: Boot Detail")

![Graph of Control System, Steady-State Packing Test: Shutdown Detail](/raw-results/control-ssp-15-shutdown_detail.png?raw=true "Graph of Control System, Steady State Packing (15): Shutdown Detail Test")

![Graph of Control System, Steady-State Packing Test](/raw-results/control-ssp-15.png?raw=true "Graph of Control System, Steady State Packing (15) Test")

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test](/raw-results/primary_no_hypervisor-ssp-100.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (100) Test")

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test: Boot Detail](/raw-results/primary_no_hypervisor-ssp-100-boot_detail.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (100) Test: Boot Detail")

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test: Shutdown Detail](/raw-results/primary_no_hypervisor-ssp-100-shutdown_detail.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (100): Shutdown Detail Test")

![Graph of Control System, Steady-State Packing Test](/raw-results/control-ssp-100.png?raw=true "Graph of Control System, Steady State Packing (100) Test")

![Graph of Control System, Steady-State Packing Test: Boot Detail](/raw-results/control-ssp-100-boot_detail.png?raw=true "Graph of Control System, Steady State Packing (100) Test: Boot Detail")

![Graph of Control System, Steady-State Packing Test: Shutdown Detail](/raw-results/control-ssp-100-shutdown_detail.png?raw=true "Graph of Control System, Steady State Packing (100): Shutdown Detail Test")

###<a name='guest_results'>Guest Benchmark Results</a>###

##Acknowledgements##

Thanks to: 

Boden Russell [\(http://bodenr.blogspot.com\)](http://bodenr.blogspot.com) for the initial benchmarking test and methodology used in his [KVM and Docker LXC Benchmarking with OpenStack](http://bodenr.blogspot.com/2014/05/kvm-and-docker-lxc-benchmarking-with.html) article, much of which I've tweaked or repurposed here.

Falko Timme [\(https://twitter.com/falko\)](https://twitter.com/falko) for his [HowtoForge article with basic guidance on benchmarking with Sysbench](http://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench).

Tutum [\(https://github.com/tutumcloud\)](https://github.com/tutumcloud) for the [tutum-docker-mysql image](https://github.com/tutumcloud/tutum-docker-mysql), which saved me a ton of time getting MySQL ready for testing inside a container.

##Copyright Information##

Copyright (C) 2014 Chris Collins

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
