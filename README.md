<<<<<<< HEAD
Virtual Machine Hypervisor + Docker Performance Benchmark
=========================================================

1. [Forward](#forward)
2. [Method](#method)
  i. [System Specs](#specs)
  ii. [Host Benchmarks](#host_bench)
    * Serial VM Boot
    * Compute node steady-state VM Packing\*
    * VM reboot
    * VM snapshot\*
  iii. [Guest Benchmarks](#guest_bench)
    * CPU Performance
    * MySQL Performance\*
    * MySQL\*
    * File I/O Operation
    * Memory Performance
    * Network Performance
    * Application type performance\*
3. [Virtual Machine Hypervisor + Docker Performance Benchmark](#vmhdp)
  i. [Host Benchmark Results](*host_results)
  ii. [Guest Benchmark Results](*guest_results)


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

###<a name='specs'>System Specs</a>###

**OS: CoreOS**

[CoreOS](https://coreos.com) was chosen as the host OS for each of these tests.  The OS was PXE booted and configured with the CoreOS Cloud Config YAML file included in this repo.  The operating system was installed into RAM, and /var/lib/docker mounted to the first local hard disk.

###<a name='host_bench'>Host Benchmarks</a>###

###<a name='guest_bench'>Guest Benchmarks</a>###

##<a name='vmhdp'>Virtual Machine Hypervisor + Docker Performance Benchmark</a>##

###<a name='host_results'>Host Benchmark Results</a>###

###<a name='guest_results'>Guest Benchmark Results</a>###

##Copyright Information##

Copyright (C) 2014 Chris Collins

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.
                                           
=======
vm-docker-bench
===============

Virtual Machine Hypervisor + Docker Performance Benchmark
>>>>>>> 3bd5297e259d564933e3d763d28f95c4469cab6b
