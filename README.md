Hypervisor + Docker Performance Benchmark
=========================================================

1. [Forward](#forward)
2. [Method](#method)
    1. [System Specs](#specs)
    2. [Host Benchmarks](#host_bench)
        * Serial container Boot
        * Computer Node Steady-State Container Packing 
    3. [Guest Benchmarks](#guest_bench)
        * CPU Performance
        * MySQL Transaction Performance
        * MySQL Index and Query Performance
        * File I/O Operation
        * (Modified) File I/O Operation
        * Memory Performance
        * Application type performance (Blogbench)
        * Application type performance (Apache Benchmark)
3. [Hypervisor + Docker Performance Benchmark](#vmhdp)
    1. [Host Benchmark Results](#host_results)
    2. [Guest Benchmark Results](#guest_results)
4. [Final Throughts](#final)
5. [Acknowledgments](#ack)
6. [Copyright Information](#copyright)


##<a name='forward'>Forward</a>##

##<a name='method'>Method</a>##

In order to cover as many bases as possible, the tests were run as follows:

1. On the Cisco USC blade with CoreOS installed
2. On the Cisco UCS blade with a hypervisor and a single VM with CoreOS installed
3. On a separate physical machine with the same hypervisor and a single VM with Coreos installed.

**Data Gathering**

_Host Benchmark Data_:

For each of the Host Benchmarks, multiple data points are collected using the [Resource Monitoring Scripts](/supplemental/monitor-scripts) included in this repository.  These scripts were started prior to each test and collected data throughout.  Each monitors a specific aspect of the host's resources at set intervals and outputs to a remote log file via and SSH tunnel.

 * CPU Load average
 * Memory Usage
 * File I/O

The scripts were all placed on the host server via the CoreOS cloud-config.yml file.

_Guest Benchmark Data_:

Test data for guest benchmarks running from within the tested container was gathered via STDOUT from the containers themselves (for exampe the CPU performance testing times) and written to a remote log file via an SSH tunnel.

Test data for guest benchmarks being performed from remote hosts (for example, the Application Type Perfomance Apache Benchmark tests) were recorded via STDOUT from the process itself and written to a logfile.

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
| ----       | ---------------------------      | ----------------------------      |
| CPU        | Intel E5-2665 @ 2.4GHz           | Intel E5-2697 v2 @ 2.70GHz        |
| Memory     | 80GB 1600                        | 8GB 1866                          |
| HDD        | Virtual                          | Virtual                           |

**OS: CoreOS** 

Version:  Beta 324.5.0

[CoreOS](https://coreos.com) was chosen as the host OS for each of these tests.  The OS was PXE booted and configured with the CoreOS Cloud Config YAML file included in this repository.  The operating system was installed into RAM, and /var/lib/docker mounted to the first local hard disk.

**Docker**

Version: 0.11.1, build fb99f99

###<a name='host_bench'>Host Benchmarks</a>###
__Serial Container Boot__

The [Docker image with Apache and PHP](/webbench) included in this repository was created to test performance during serial boot of fifteen and one hundred containers.  These two tests were performed two ways:

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

###<a name='guest_bench'>Guest Benchmarks</a>###

__CPU Performance__

[Sysbench](http://sysbench.sourceforge.net/) was chosen to perform a number of benchmark tests, including this CPU computation benchmark.  The tests used the [Sysbench Docker image](/sysbench) included in this repository.  The resulting container was started, and ran `sysbench --test=cpu --cpu-max-prime=20000 run` (via the [cpu_prime.sh script](/sysbench/cpu_prime.sh)).  This process was repeated one hundred times, and the total time taken for the test execution was recorded for each.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    #
    # Version 1.0 (2014-07-08)
    #
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench\sysbench
    #
    # Tests CPU calculations by running a prime number 
    # calculation benchmark test in 100 Docker 
    # containers, serially.
    docker pull $REPO/bench-sysbench >> /dev/null
    for i in {1..100} ; do docker run --rm -i -t $REPO/bench-sysbench \
    sysbench --test=cpu --cpu-max-prime=20000 run |grep total\ time\: \
    | awk '{print $3}'| sed 's/s//g' ; done


__MySQL Transaction Performance__

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
    docker pull $REPO/bench-sysbench-mysql
    for i in {1..100} ; do docker run --rm -i -t $REPO/bench-sysbench-mysql 
    done

__MySQL Index Insertion and Query Performance__

Iibench [\(https://bazaar.launchpad.net/~mdcallag/mysql-patch/mytools/download/head:/iibench.py-20090327210349-wgv0sum50kpukctz-1/iibench.py\)](https://bazaar.launchpad.net/~mdcallag/mysql-patch/mytools/download/head:/iibench.py-20090327210349-wgv0sum50kpukctz-1/iibench.py) was used to run indexed insertion benchmark tests for MySQL.  A Docker image based on the [tutum/mysql image](https://github.com/tutumcloud/tutum-docker-mysql) with MySQL + Iibench was created and is available in this repository [\(https://github.com/DockerDemos/vm-docker-bench/tree/master/iibench-mysql\)](https://github.com/DockerDemos/vm-docker-bench/tree/master/iibench-mysql).

On startup, the container sets up the MySQL server and database, and then runs the following, recording results:

    python iibench.py --db_user=$USER --db_password=$PASS --max_rows=1000000 \
                      --setup --rows_per_report=100000 \
                      --db_socket=/var/run/mysqld/mysqld.sock

The test was run twenty five times, serially, and the output recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository
    # server for ease of testing.
    # It can be built from the Docker files at
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/iibench-mysql
    #
    # Tests MySQL Indexed Insertion performance
    # Test runs in 25 Docker containers, serially.
    docker pull $REPO/bench-iibench-mysql
    for i in {1..25} ; do docker run --rm -i -t $REPO/bench-iibench-mysql
    done

__File I/O Operation__

 _Note: This test may not be an accurate representation of actual results.  The available disk space on the primary host without a hypervisor was not large enough to create a file big enough to prevent caching in memory.  See the "Modified File I/O Operation" test below for a better, but probably still not 100% accurate, attempt at this test._

File I/O benchmarking was done using the same [Sysbench Docker image](/sysbench) used for the CPU tests above.  The container was started, and ran (via the [io.sh script](/sysbench/io.sh)):

    sysbench --test=fileio --file-total-size=10G prepare
    sysbench --test=fileio --file-total-size=10G --file-test-mode=rndrw \
    --init-rng=on --max-time=300 --max-requests=0 run
    sysbench --test=fileio --file-total-size=10G cleanup

This test was run twenty five times, serially, and the Kb/sec value from the test output recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    #
    # Version 1.0 (2014-07-08)
    #
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench
    #
    # Tests disk IO with a combined *Random Read and Write*
    # test in 25 Docker containers, serially.
    # 
    # Writes total transfer speed in Mb/s to stdout
    docker pull $REPO/bench-sysbench >> /dev/null
    for i in {1..25} ; do docker run --rm -i -t $REPO/bench-sysbench \
    /bench/io.sh 5G \
    |awk '/transferred/ {print $8}'| sed 's/[\(\)(Mb/sec)]//g' ; done

__(Modified) File I/O Operation__

This is the exact same test as the File I/O Operation test above, but with memory limitations in place on the Docker containers (512MB).

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    #
    # Version 1.0 (2014-07-08)
    #
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench
    #
    # Tests disk IO with a combined *Random Read and Write*
    # test in 25 Docker containers, serially, with a 
    # 512MB memory limit enforced on the containers.
    docker pull $REPO/bench-sysbench >> /dev/null
    for i in {1..25} ; do docker run --rm -i -t -m="524288k" $REPO/bench-sysbench \
    /bench/io.sh 5G \
    |awk '/transferred/ {print $8}'| sed 's/[\(\)(Mb/sec)]//g' ; done


__Memory Performance__

[mbw](https://github.com/raas/mbw) was chosen as the test application for testing the "copy" memory bandwidth available to userspace programs in order to mimic real applications.  The tests used the [mbwbench Docker image](/mbwbench) included in this repository.  The resulting container runs a [bash script for running mbw](http://jamesslocum.com/post/64209577678) developed by James Slocum that detects the number of CPU cores available to the container and runs a corresponding number of mbw threads.  The process was repeated one hundred times and the results recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    #
    # Version 1.0 (2014-07-10)
    #
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/mbwbench
    #
    # Tests "copy" memory bandwidth 
    # Runs 100 Docker containers, serially 
    # Host swap is disabled before the test and re-enabled after
    docker pull $REPO/bench-mbwbench >> /dev/null
    /sbin/swapoff -a
    for i in {1..100} ; do docker run --rm -i -t $REPO/bench-mbwbench ; done
    /sbin/swapon -a

__Application type performance (Blogbench)__

[Blogbench](http://www.pureftpd.org/project/blogbench) was used to simulate file I/O as it would exist on a webserver, with mostly-read, some-write traffic.  The tests used the [Blogbench Docker image](/blogbench) included in this repository.  The resulting container was started and ran `blogbench -c 30 -i 20 -r 40 -W 5 -w 5 --directory=/srv`.  This process was repeated twenty times and the results recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    #
    # Version 1.0 (2014-07-11) 
    #
    # This image was uploaded to our private repository
    # server for ease of testing.
    # It can be built from the Docker files at
    # https://github.com/DockerDemos/vm-docker-bench/tree/master/blogbench
    #
    # Tests file I/O operations simulating a 
    # real-world server.
    # Runs 25 docker containers, serially
    docker pull $REPO/bench-blogbench
    for i in {1..25} ; do docker run --rm -i -t $REPO/bench-blogbench \
    -c 30 -i 20 -r 40 -W 5 -w 5 --directory=/srv ; done

__Application type performance (Apache + PHP)__

Very basic application performance testing was done using the same [Apache + PHP Docker image](/webbench) used for the serial container boot host benchmark tests above.  In addition, a [Docker image with Apache Bench](/abbench) was created to be run from another location (Laptop, second server, etc) to test the performance of the Apache + PHP container.

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
    docker pull $REPO/bench-webbench
    docker run -d -p 80:80 $REPO/bench-webbench 

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
    docker pull $REPO/bench-abbench
    docker run -i -t $REPO/bench-abbench -n 1000000 -c 4 http://$DOCKER_BENCHMARK_HOST/index.php


##<a name='vmhdp'>Hypervisor + Docker Performance Benchmark</a>##

###<a name='host_results'>Host Benchmark Results</a>###

__Serial Container Boot__

This test measures the CPU and I/O usage on the host during the startup of 100 Docker containers.  The graphs below show the user, system and IOWait, in USER_Hz.  The polling period was once per second.  For all three values, lower is better.

![Graph of Primary System w/no Hypervisor, Serial Container Boot Test](/images/primary_no_hypervisor-serial-container-boot.png?raw=true "Graph of Primary System w/no Hypervisor, Serial Container Boot Test")

The results above support others' (especially Boden Russell's) findings that Disk I/O is the largest limiting factor for Docker containers.  The I/O Wait caused by booting containers one after another with little gap in between was a bit much for the single hard disk, despite being a SAS 15,000 RPM drive. Downloading the image from the private repository produced a small spike, but the majority of the I/O was generated by the startup of the containers themselves.

![Graph of Primary System with Hypervisor, Serial Container Boot Test](/images/primary-serial-container-boot.png?raw=true "Graph of Primary System with Hypervisor, Serial Container Boot Test")

Somewhat surprisingly, the addition of a hypervisor layer did little to change the overall CPU utilization during the initial download and Docker startup.  More surprising, however, is while I/O remains the bottleneck, adding the hypervisor ended up _lowering_ the I/O Wait a little and resulted in a smaller amount of variation overall.

![Graph of Control System, Serial Container Boot Test](/images/control-serial-container-boot.png?raw=true "Graph of Control System, Serial Container Boot Test")

The control system mimics the performance of primary system, but with less I/O congestion due to the 50 disk EMC Array backing the control hypervisor's virtual disks.  Any difference in user and system performance is largely negligible.

__Compute node steady-state Container Packing__

This test measures the same metrics as the above, CPU and I/O usage on the host, through a full startup and 15 minute normalization period.  Again, lower numbers are better.

In all three cases, the 15 minute normalization ended up holding no significant data, so the graphs below are cropped views of the boot process itself.  This in effect make results in data similar to 100 container Serial Container Boot test, and as a result the images are almost the same.

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test: Boot Detail](/images/primary_no_hypervisor-ssp-15-boot_detail.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (15) Test: Boot Detail")

In the detail of the startup process, the data is as expected. Disk I/O is again the limiting factor

![Graph of Primary System with Hypervisor, Steady-State Packing Test: Boot Detail](/images/primary-ssp-15-boot_detail.png?raw=true "Graph of Primary System with Hypervisor, Steady State Packing (15) Test: Boot Detail")

Once again, there is almost no difference in the CPU usage of the system with or without a hypervisor layer.  The difference is small enough as to make little difference in everyday use.

![Graph of Control System, Steady-State Packing Test: Boot Detail](/images/control-ssp-15-boot_detail.png?raw=true "Graph of Control System, Steady State Packing (15) Test: Boot Detail")

The control system has somewhat faster disks than the primary system (it's backed by a 50 disk EMC array), so the IO peak itself isn't as high, but disk I/O continues to be the limiting factor.

![Graph of Primary System w/no Hypervisor, Steady-State Packing Test: Boot Detail](/images/primary_no_hypervisor-ssp-100-boot_detail.png?raw=true "Graph of Primary System w/no Hypervisor, Steady State Packing (100) Test: Boot Detail")

In the 100 container steady state packing test (with hypervisor), the I/O again spikes to around the same level as previous tests when container creation begins and unsurprisingly stays peaked for a much longer time due to the increased number of containers.

The consistency of peak I/O Wait across both 15 and 100 container boots implies a maximum startup rate for each container on the host - starting a greater or lesser number of containers serially will not be likely to have additional impact on performance.

![Graph of Primary System with Hypervisor, Steady-State Packing Test: Boot Detail](/images/primary-ssp-100-boot_detail.png?raw=true "Graph of Primary System with Hypervisor, Steady State Packing (100) Test: Boot Detail")

With the hypervisor, the performance difference is again similar to previous tests comparing hypervisor and physical servers, and once again the system reaches a "terminal velocity" of I/O; generally between 275 and 375 USER_Hz, though it trails off more at the end.

![Graph of Control System, Steady-State Packing Test: Boot Detail](/images/control-ssp-100-boot_detail.png?raw=true "Graph of Control System, Steady State Packing (100) Test: Boot Detail")

The control system's results match it's previous results as well.

###<a name='guest_results'>Guest Benchmark Results</a>###

__CPU Performance__

![Comparison Graph of Sysbench Max Prime tests (100): Total Time for Tests](/images/CPU_comparison.png?raw=true "Comparison Graph of Sysbench Max Prime tests (100): Time Taken for Tests")

![Graph of Primary System w/no Hypervisor, Sysbench Max Prime tests (100): Total Time for Test](/images/primary_no_hypervisor-CPU_cpu-time.png?raw=true "Graph of Primary System w/no Hypervisor, Sysbench Max Prime tests (100): Total Time for Test")

This graph shows the time required to run each of the max prime tests in the 100 containers on the primary system with no hypervisor.  The lower the time, the better.

![Graph of Primary System with Hypervisor, Sysbench Max Prime tests (100): Total Time for Test](/images/primary-CPU_cpu-time.png?raw=true "Graph of Primary System with Hypervisor, Sysbench Max Prime tests (100): Total Time for Test")

And this is totally unexpected.  The graph shows the total time taken to run the max prime tests on the primary system with a hypervisor, and the results are _actually faster_ (and in fact varies less) than the primary without a hypervisor.

![Graph of Control System, Sysbench Max Prime tests (100): Total Time for Test](/images/control-CPU_cpu-time.png?raw=true "Graph of Control System, Sysbench Max Prime tests (100): Total Time for Test")

The control system graph for the time taken for the max prime tests is similar to the primary, but the system is about 10 seconds faster per test. Of note is the time scale (in seconds) on the vertical axis.  Despite the appearance of the graph, the time taken for each test is incredibly consistent - there's only about 1/10 of a second in variance.

__MySQL Transaction Performance__

The MySQL Transaction Performance test measured the total number of transactions per second accomplished by the Sysbench MySQL test within a Docker container running the MySQL server.

![Graph of Sysbench MySQL tests (100), Transactions per Second Comparison](/images/MySQL_comparison.png?raw=true "Graph of Sysbench MySQL tests (100), Transactions per Second Comparison")

The Primary system without a hypervisor was considerably faster at MySQL transactions per second in this test, almost 150% that of the performance with a hypervisor.

Somewhat strangely, the control system, which has been generally out-performing the other two, scored very poorly on this test, enough so that I retested all three to see if I'd made a mistake.  However, across all the restests, the data remains the same.  More testing from other people is needed to confirm the validity of this test.

__MySQL Index and Query Performance__

The Iibench MySQL performance test mesured the lenght of time required to insert 1,000,000 rows into a MySQL database across 25 successive runs in a Docker container running MySQL.  Additionally, it measured the number of queries per second that could be accomplished during the testing.

![Graph of Iibench MySQL tests (25), Row Insertions per Second Comparison](/images/MySQL_index_insertion_comparison.png?raw=true "Graph of Iibench MySQL tests (25), Row Insertions per Second Comparison")

The results of the Index Insertion test confirm the conventional wisdom surrouding hypervisor performance hits, with the primary system performing more row insertions per second than the same system with a hypervisor installed.  As it has in most tests to this point, the control system outperformed both.

![Graph of Iibench MySQL tests (25), Queries per Second Comparison](/images/MySQL_index_query_comparison.png?raw=true "Graph of Iibench MySQL tests (25), Queries per Second Comparison")

The bare-metal primary server again out-performed itself while using the hypervisor, this time with the number of queries that could be performed during the duration of the testing.  And, again, the control system scored higher marks than the rest.

__File I/O Operation__

As noted above, this test is most likely not accurate in this environment due to the inability to prevent caching in memory.  The tests were performed, but are included in the [unmodified_file_io_results.md](/supplemental/unmodified_file_io_results.md) file.

__(Modified) File I/O Operation__

![Graph of (Modified) Sysbench File I/O tests (25), Transfer Speed Comparison](/images/bench_io_mod-results.png?raw=true "Graph of (Modified) Sysbench File I/O tests (25), Transfer Speed Comparison")

File I/O measured over twenty five consecutive tests in twenty five Docker containers shows little surprising results between the primary system with or without a hypervisor.  Over the entirety of the testing, there is little difference between the two, with each averaging a transfer speed of about 1.7 Mb/second or so to their local disks.

The control system, however, is a VM backed by an enterprise storage array.  The transfer speeds start to climb significantly shortly after the third test as the array identifies the blocks used by the VM as "hot" and transfers them from conventional storage onto solid-state disks.  While this has no bearing on the hypervisor vs. no hypervisor testing, it's an excellent argument for using an enterprise storage array for Docker containers that have a significant amount of file I/O, whether or not the host is physical or virtual.

__Memory Performance__

For the Memory Performance benchmark tests, the primary system is fastest copying data from one location in memory to another without the addition of a hypervisor layer.

![Graph of MBW Memory Benchmark Tests (100), MEMCPY Operations Comparison](/images/mbw-MEMCPY_comparison.png?raw=true "Graph of MBW Memory Benchmark Tests (100), MEMCPY Operations Comparison")

The MEMCPY opeartaion test from _mbw_ measures the speed achieved while copying a 32 MB array from one area of memory to another.  In this test, the primary system performs slightly better without a hypervisor layer.  The control system performs considerably slower than either of the primary system tests, despite having a higher RAM clock speed (1866 MHz vs 1600 MHz).

The first explanation that jumps to mind is the considerably less available RAM on the control system. However, this assumes that the system being tested can intelligently spread the memory writes over the total physical RAM chips available.  This assumption only works if the control system hypervisor applies a strict one-to-one assignment of RAM and does not use the entirety of the host system's available RAM for writing.

![Graph of MBW Memory Benchmark Tests (100), MCBLOCK Operations Comparison](/images/mbw-MCBLOCK_comparison.png?raw=true "Graph of MBW Memory Benchmark Tests (100), MCBLOCK Operations Comparison")

The MCBLOCK test is the same as the MEMCPY, but copies the 32 MB array in 4096-byte blocks of data.  The results here were predictably similar to the MEMCPY test, though the gap in performance between the primary with hypervisor and the primary without hypervisor was smaller than that of the previous test.

![Graph of MBW Memory Benchmark Tests (100), DUMB Operations Comparison](/images/mbw-DUMB_comparison.png?raw=true "Graph of MBW Memory Benchmark Tests (100), DUMB Operations Comparison")

The DUMB operation "\(b[i]=a[i] style\)" test results are similar to those above, but all three systems' performance is lower overall.

__Application Type Performance (Blogbench)__

The Blogbench tests attempted to roughly simulate a real-world website, running 20 tests of 20 iterations \(5 "writers", 5 "rewriters", 30 "commenters" and 40 "readers"\).  The results are interesting, with the hypervisor improving simulated read performance, but the physical system outperforming each of the others during simulated write performance.

![Graph of Blogbench Benchmark Tests (20), Read Score Comparison](/images/blogbench-reads_comparison.png?raw=true "Graph of Blogbench Benchmark Tests (20), Read Score Comparison")

The primary system with hypervisor scores a significatntly higher "Read Score" across 20 iterations of the Blogbench test.  The control system was considerably lower than either of the primary system tests.

![Graph of Blogbench Benchmark Tests (20), Write Score Comparison](/images/blogbench-writes_comparison.png?raw=true "Graph of Blogbench Benchmark Tests (20), Write Score Comparison")

During the Blogbench testing, the primary system without a hypervisor outscored the other two systems in the achieved "Write Score".  Unlike the test above, the two systems with a hypervisor were pretty clone in their scores, with the physical system scoring much higher.

Overall, it is not clear what these results mean.  They appear to suggest that random writes are faster without a hypervisor.  Perhaps the randomized writes prevent the hypervisor from performing any smart caching.  This may explain why the control system performed more poorly, despite the considerable performance boost it received from the storage array during the File I/O tests, above.

The read results make much less sense.  The hypervisor performes random reads faster on the primary system that the bare primary system itself, but the control system, which should have been remarkably faster than either of them, is considerably slower.  Even with randomized reads removing the benefit of the control system's backing storage array, one would expect the score to be nearer the score of the hypervisor on the primary system, at least.

__Application Type Performance (Apache Benchmark)__

The Apache Bench benchmark test measures the overall performnace and transfer speed of the Apache server running in a Docker container and serving a static HTML file.  A second Docker container on a separate system runs the actual benchmark requests, and records the results.

![Graph of Apache Bench Benchmark Tests (20), Requests Per Second Comparison](/images/ab_comparison.png?raw=true "Graph of Apache Bench Benchmark Tests (20), Requests Per Second Comparison")

The primary system without the hypervisor layer scored significantly better than with the hypervisor installed.  This would seem to contadict the earlier Blogbench Read-only results. The control system perfromed better than the primary with hypervisor, but that can likely be explained by the better disk I/O due to the storage array backing the control system.

##<a name='final'>Final Thoughts</a>##

When all is said and done, the question that demands an answer is: "Which is the better host for a CoreOS system running Docker containers - Hypervisor or Bare Metal?".  Overall, the answer to that question is __Bare Metal__.  The primary server without a hypervisor performed better in the majority of the tests conducted here.

However, this generalization does not take into account some pecularities.  Certainly, in terms of raw CPU performance, the addition of the hypervisor layor inexplicably benefited performance overall.  If this holds out across other tests conducted by other independent testers, then the use of a hypervisor is a clear win for calculation-intensive applications.

Simulations of real-world webserver traffic using Blogbench also showed a benefit using the hypervisor, assuming the traffic was much heaver in reads than writes.  A highly read-only website may which to consider running their site in Docker containers on top of a hypervisor-backed host.

Outside of the main question, there are a few bits of interesting information raised by the tests:

* Disk I/O is usually the largest limiting factor in performance of Docker-related tasks (especially starting new containers)
* Difference in Hypervisor vs. Bare Metal performance of Docker-related tasks appears to be neglegible
* Storage arrays that detect "hot" blocks and automatically allocate them to SSDs have a huge impact on high File I/O
* They hypervisor may receive a significant performance boost in memory writes just by having more physical RAM to use for allocation


##<a name='ack'>Acknowledgments</a>##

Thanks to: 

Boden Russell [\(http://bodenr.blogspot.com\)](http://bodenr.blogspot.com) for the initial benchmarking test and methodology used in his [KVM and Docker LXC Benchmarking with OpenStack](http://bodenr.blogspot.com/2014/05/kvm-and-docker-lxc-benchmarking-with.html) article, much of which I've tweaked or re-purposed here.

Falko Timme [\(https://twitter.com/falko\)](https://twitter.com/falko) for his [HowtoForge article with basic guidance on benchmarking with Sysbench](http://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench).

Tutum [\(https://github.com/tutumcloud\)](https://github.com/tutumcloud) for the [tutum-docker-mysql image](https://github.com/tutumcloud/tutum-docker-mysql), which saved me a ton of time getting MySQL ready for testing inside a container.

James Slocum [\(http://jamesslocum.com/\)](http://jamesslocum.com/) for the [script to run mbw on multiple-core systems](http://jamesslocum.com/post/64209577678), which made automating the testing a lot easier.

##<a name='copyright'>Copyright Information</a>##

Copyright (C) 2014 Chris Collins

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
