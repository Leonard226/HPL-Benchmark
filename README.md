### HPL-Benchmark
The HPL (High-Performance Linpack) benchmark is a widely used performance benchmark in the field of high-performance computing (HPC). It measures a system's floating-point computing power by solving a dense system of linear equations using double-precision (64-bit) arithmetic on distributed-memory computers.

It is recommended to use preoptimized NVIDIA containers to run HPL on NVIDIA GPUs. I use the following version: 
``` Shell
module load apptainer
apptainer pull docker:////nvcr.io/nvidia/hpc-benchmarks:24.03
```

I am running HPL on two nodes, each equipped with NVIDIA GH200 Superchip. The goal is to get as much compute power as possible. This is done by using roughly 95% of GPU's memory and by finding a good blocking size such that small matrix block fit into your caches. Those options can be set in the input file `HPL.dat`. 

You can also apply optimization in the way how you let the benchmark run. For instance you can use performance flags like `--cpu-freq=Performance`, `--gpu-freq=high` and `--exclusive`. My configurations can be found in `run.sh`. It is also possible to optimize for NUMA locality. A NUMA domain/node refers to a set of processors and their associated memory within a NUMA system that share relatively fast access to a common pool of memory. Since there is only one NUMA domain on my cluster no such optimization can be applied. But assume you are on a weird cluster where you have ... Then you can apply CPU and GPU masking, i.e. you can write bit masks to map MPI tasks to a certain set of CPUs and GPUs. This yields significant speedup. 

To be completed...
