#!/usr/bin/env bash

#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --time=00:01:00
#SBATCH --gres gpu:1
#SBATCH --mem=16g
#SBATCH --output=log-%j-stdout.txt
#SBATCH --error=log-%j-stederr.txt

log_basename="log-${SLURM_JOB_ID}"
exec="./exe"

module purge
module load nvidia/nvhpc/22.7-cuda-11.7-majslurm || exit

nvaccelinfo >>"${log_basename}-nvaccelinfo.txt" || exit
nvidia-smi topo -m >>"${log_basename}-nvidia-smi.txt" || exit

make -C .. || exit

nsys profile -o "nsys-report-${SLURM_JOBID}" -t openacc ${exec}
${exec}
