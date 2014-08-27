### CPU PERFORMANCE - CPU and RAM Usage Graphts ###

![Graph of Primary System w/no Hypervisor, Sysbench Max Prime tests (100): 200 Second CPU Usage sample](/images/primary_no_hypervisor-CPU_cpu.png?raw=true "Graph of Primary System w/no Hypervisor, Sysbench Max Prime tests (100): 200 Second CPU Usage sample")

This graph demonstrates a sampling of the CPU usage at the start of, and during, some of the Sysbench CPU usage tests.  There are a few peaks evident at the start while the Docker image is downloaded, but the results are very predictable after the actual tests start.  Each of the valleys you see in the _user_ load is the end of that max prime test.  The corresponding red _system_ spikes are where the kernel takes over as Docker destroys the container and starts a new one.  That pattern carried out over the full 100 runs with very little variation.

![Graph of Primary System with Hypervisor, Sysbench Max Prime tests (100): 200 Second CPU Usage sample](/images/primary-CPU_cpu.png?raw=true "Graph of Primary System with Hypervisor, Sysbench Max Prime tests (100): 200 Second CPU Usage sample")

![Graph of Control System, Sysbench Max Prime tests (100): 200 Second CPU Usage sample](/images/control-CPU_cpu.png?raw=true "Graph of Control System, Sysbench Max Prime tests (100): 200 Second CPU Usage sample")

The control system sample of the 100 max prime tests is very similar to the primary system, but each of the tests was completed more quickly, so there are more tests represented in the 200 second sample.

![Graph of Control System, Sysbench Max Prime tests (100): Memory Usage](/images/control-CPU_mem.png?raw=true "Graph of Control System, Sysbench Max Prime tests (100): Memory Usage")

This graph displays the memory used by the control system over the entirety of the 100 run max prime test (as opposed to the sample, above.)  There is a bit of an interesting result here with the memory usage graph for the 100 max prime test.  The amount of cached and used RAM grew, slowly, over the course of the run.
