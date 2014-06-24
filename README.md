Virtual Machine Hypervisor + Docker Performance Benchmark
=========================================================

1. [Forward](#forward)
2. [Method](#method)
    1. [System Specs](#specs)
    2. [Host Benchmarks](#host_bench)
        * Serial VM Boot
        * Compute node steady-state VM Packing\*
        * VM reboot
        * VM snapshot\*
    3. [Guest Benchmarks](#guest_bench)
        * CPU Performance
        * MySQL Performance\*
        * MySQL\*
        * File I/O Operation
        * Memory Performance
        * Network Performance
        * Application type performance\*
3. [Virtual Machine Hypervisor + Docker Performance Benchmark](#vmhdp)
    1. [Host Benchmark Results](#host_results)
    2. [Guest Benchmark Results](#guest_results)


\* Included in the inital *KVM and Docker LXC Benchmarking with OpenStack* presentation.  Are these valid for our purposes?

##<a name='forward'>Forward</a>##

##<a name='method'>Method</a>##

In order to cover as many bases as possible, the tests were run as follows:

**For Single Guest Tests**

1. On the Cisco USC blade with CoreOS installed
2. On the Cisco UCS blade with a hypervisor and a single VM with CoreOS installed
3. On a separate physical machine with the same hypervisor and a single VM with Coreos installed.

**For Multiple Guest Tests** 

1. On the Cisco USC blade with CoreOS installed, running multiple Docker containers
2. On the Cisco USC blade with a hypervisor, and a single VM with CoreOS installed, running multiple Docker containers
3. On the Cisco USC blade with a hypervisor, and multiple VMs with CoreOS installed, running a single Docker container per VM
4. On a separate physical machine with the same hypervisor, and a single VM with CoreOS installed, running multiple Docker containers

**Data Gathering**

Some test data was gathered via output to STDOUT from the containers themselves (most notibly the CPU performance testing times).

###<a name='specs'>System Specs</a>###

|          | Test System                  | Comparison System |
| ----     | -----------                  | ----------------- |
| Hardware | Cisco UCS Blade CCSB-B200-M3 |                   |
| Version  | B200M3.2.1.3a.0.082320131800 |                   |
| CPU      | Intel E5-2665 @ 2.4GHz       | here              |
| Memory   | 256GB 1600                   |                   |
| HDD      |                              |                   |

**OS: CoreOS** 

Version:  Beta 324.5.0

[CoreOS](https://coreos.com) was chosen as the host OS for each of these tests.  The OS was PXE booted and configured with the CoreOS Cloud Config YAML file included in this repo.  The operating system was installed into RAM, and /var/lib/docker mounted to the first local hard disk.

**Docker**

Version: 0.11.1, build fb99f99

###<a name='host_bench'>Host Benchmarks</a>###

###<a name='guest_bench'>Guest Benchmarks</a>###

__CPU Performance__

[Sysbench](http://sysbench.sourceforge.net/) was chosen to perform a number of benchmark tests, including this cpu computation benchmark.  The tests used the [Sysbench Docker image](https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench) included in this repository.  The resulting container was started, and ran `sysbench --test=cpu --cpu-max-prime=20000 run` (via the [cpu_prime.sh script](https://github.com/DockerDemos/vm-docker-bench/blob/master/sysbench/cpu_prime.sh)).  This process was repeated one hundred (100) times, and the total time taken for the test execution was recorded for each.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/sysbench
    #
    # Tests CPU calculations by running a prime number 
    # calculation benchmark test in 100 Docker 
    # containers, serially.
    docker pull $REPO/sysbench
    for i in {1..100} ; do docker run -i -t $REPO/sysbench \
    cpu_prime.sh 20000 | grep total\ time\: \
    | awk '{print $3}'| sed -i 's/s//g' ; done

__MySQL Performance__

__MySQL__

__File I/O Operation__

 _Note: This test may not be an accurate representation of actual results.  The available disk space on each host was not large enough to create a file big enough to prevent caching in memory.  See the "Modified File I/O Operation" test below for a second, but probably still not 100% accurate, test._

File I/O benchmarking was done using the same [Sysbench Docker image](https://github.com/DockerDemos/vm-docker-bench/tree/master/sysbench) used for the CPU tests above.  The container was started, and ran (via the [io.sh script](https://github.com/DockerDemos/vm-docker-bench/blob/master/sysbench/io.sh)):

    sysbench --test=fileio --file-total-size=10G prepare
    sysbench --test=fileio --file-total-size=10G --file-test-mode=rndrw \
    --init-rng=on --max-time=300 --max-requests=0 run
    sysbench --test=fileio --file-total-size=10G cleanup

This test was run one hundred (100) times, serially, and the Kb/sec value from the test output recorded.

The following bash script was placed on the host server via the CoreOS cloud-config.yml file, and used to run the tests:

    #!/bin/bash
    # This image was uploaded to our private repository 
    # server for ease of testing.
    # It can be built from the Docker files at 
    # https://github.com/DockerDemos/vm-docker-bench/sysbench
    #
    # Tests CPU calculations by running a prime number 
    # calculation benchmark test in 100 Docker 
    # containers, serially.
    docker pull $REPO/sysbench
    for i in {1..100} ; do docker run -i -t $REPO/sysbench \
    /bench/io.sh 10G \ 
    |grep total\ time\: \
    | awk '{print $3}'| sed -i 's/s//g' ; done

__(Modified) File I/O Operation__

Performed with memory limitations in place on the Docker containers (1GB) and the same memory available on the VM created to compare results.

(Info goes here)

__Memory Performance__

__Network Performance__

__Application type performance__

##<a name='vmhdp'>Virtual Machine Hypervisor + Docker Performance Benchmark</a>##

###<a name='host_results'>Host Benchmark Results</a>###

###<a name='guest_results'>Guest Benchmark Results</a>###

##Acknowledgements##

Thanks to: 

Boden Russell [\(http://bodenr.blogspot.com\)](http://bodenr.blogspot.com) for the initial benchmarking test and methodology used in his [KVM and Docker LXC Benchmarking with OpenStack](http://bodenr.blogspot.com/2014/05/kvm-and-docker-lxc-benchmarking-with.html) article, much of which I've tweaked or repurposed here.

Falko Timme [\(https://twitter.com/falko\)](https://twitter.com/falko) for his [HowtoForge article with basic guidance on benchmarking with Sysbench](http://www.howtoforge.com/how-to-benchmark-your-system-cpu-file-io-mysql-with-sysbench).

##Copyright Information##

Copyright (C) 2014 Chris Collins

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
