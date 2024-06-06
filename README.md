### HPL-Benchmark
The HPL (High-Performance Linpack) benchmark is a widely used performance benchmark in the field of high-performance computing (HPC). It measures a system's floating-point computing power by solving a dense system of linear equations using double-precision (64-bit) arithmetic on distributed-memory computers.

It is recommended to use preoptimized NVIDIA containers to run HPL on NVIDIA GPUs. I use the following version: 
``` Shell
module load apptainer
apptainer pull docker:////nvcr.io/nvidia/hpc-benchmarks:24.03
```

I am running HPL on two nodes, each equipped with an NVIDIA GH200 Superchip. The goal is to maximize computational power. This involves utilizing roughly 95% of the GPU memory and determining an optimal blocking size so that small matrix blocks fit into the caches. These settings can be adjusted in the input file `HPL.dat`.
Additionally, optimizations can be applied to how the benchmark runs. For example, you can use performance flags like `--cpu-freq=Performance`, `--gpu-freq=high`, and `--exclusive`. Details of my configurations can be found in `run.sh`.

It is also possible to optimize for NUMA locality. A NUMA domain/node refers to a set of processors and their associated memory within a NUMA system that share relatively fast access to a common pool of memory. Since there is only one NUMA domain on my cluster no such optimization can be applied. But assume you are on a strance cluster where you have two NUMA domains per node, 64 cores per NUMA domain, i.e. 128 cores per node, and 4 GPUs per node. More precisely: 
``` Shell
$ nvidia-smi topo -m
       GPU0    GPU1   GPU2   GPU3     CPU Affinity    NUMA Affinity 
GPU0     X     NODE    SYS    SYS        0-63              0         
GPU1    NODE    X      SYS    SYS        0-63              0          
GPU2    SYS    SYS      X     NODE      64-127             1          
GPU3    SYS    SYS    NODE     X        64-127             1   
```

Then you can apply CPU and GPU masking, i.e. you can write bit masks to map MPI tasks to a certain set of CPUs and GPUs. So we want that task one is bound to the set of CPUs and GPUs that belong to the same NUMA domain. The problem is that we have only two NUMA domains per node, but four tasks will be executed on one node. The idea is that two tasks will share a NUMA domain. Thus write the following masks: 
``` Shell
m0="0xFFFFFFFF"                         #cpus: 0-31
m1="0xFFFFFFFF00000000"                 #cpus: 32-63
m2="0xFFFFFFFF0000000000000000"         #cpus: 64-95
m3="0xFFFFFFFF000000000000000000000000" #cpus: 96-127

g0="0x1" #gpu: 1
g1="0x2" #gpu: 2
g2="0x4" #gpu: 3
g3="0x8" #gpu: 4
```
Then use binding-flags provided by the Slurm scheduler: 
``` Shell
#SBATCH --cpu-bind=verbose,mask_cpu:$m0,$m1,$m2,$m3
#SBATCH --gpu-bind=verbose,mask_gpu:$g0,$g1,$g2,$g3
```
This yields significant speedup. 

