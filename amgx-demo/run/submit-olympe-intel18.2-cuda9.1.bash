#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --gres gpu:1
#SBATCH --mem=16g

module purge
module load intel/18.2 gcc/5.4.0 cuda/9.1.85.3 openmpi/icc/2.0.2.10

make -B -C .. AMGX_ROOT=/usr/local/amgx/AMGX

mpirun --np 1 ./amgx.out

jobinfo "${SLURM_JOBID}"
