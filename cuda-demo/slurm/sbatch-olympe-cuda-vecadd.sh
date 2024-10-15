#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:05:00
#SBATCH --gres=gpu:1
#SBATCH --mem=1g

module purge
module load nvidia/nvhpc/22.7-cuda-11.7-majslurm

nvidia-smi
make -B
./bin/c.out
./bin/f.out
