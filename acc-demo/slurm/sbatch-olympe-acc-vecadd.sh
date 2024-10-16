#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:10:00
#SBATCH --gres gpu:1
#SBATCH --mem=16g

module purge
module load nvidia/nvhpc/22.7-cuda-11.7-majslurm

make
./bin/out
