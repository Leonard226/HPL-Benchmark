#!/bin/bash

module load slurm

OUTPUT=OUTPUT.txt
SIF=/home/sleonard/isc24/hpl/hpc-benchmarks_24.03.sif

srun -u \
     --job-name="go-HPL" \
     --mpi=pmi2 \
     --nodes=2 \
     --exclusive \
     --ntasks-per-node=1 \
     --cpu-freq=Performance \
     --cpus-per-task=72 \
     --gpus-per-task=1 \
     --cpu-freq=Performance  \
     --mem-per-gpu=0 \
     apptainer exec --no-mount home -B${PWD}:/scratch --nv $SIF /workspace/hpl.sh \
     --dat /scratch/HPL.dat | tee $OUTPUT

