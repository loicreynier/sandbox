#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --gres gpu:1
#SBATCH --mem=16g

module purge
module load nvidia/nvhpc/22.1-cuda-11.5-majslurm
module load amgx/2.2.x-nvhpc

make -B -C ..

mpirun --np 1 ./amgx.out

jobinfo "${SLURM_JOBID}"
