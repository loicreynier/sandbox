#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --gres gpu:4

module purge
module load intel/18.2 gcc/5.4.0 cuda/9.1.85.3 openmpi/icc/2.0.2.10

make -B AMGX_ROOT=/usr/local/amgx/AMGX
srun "$(placement "$SLURM_NTASKS_PER_NODE" "$SLURM_CPUS_PER_TASK")" ./bin/amgx.out
