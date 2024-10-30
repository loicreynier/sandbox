#!/usr/bin/env bash

#MSUB -r test_acc
#MSUB -n 1
#MSUB -c 32
#MSUB -q a100
#MSUB -T 3600
#MSUB -A onera
#MSUB -o log-%J-stdout.txt
#MSUB -e log-%J-stderr.txt

log_basename="log-${BRIDGE_MSUB_JOBID}"
exec="./exe"

set -x
cd "${BRIDGE_MSUB_PWD}" || exit

module load nvhpc || exit

nvaccelinfo >>"${log_basename}-nvaccelinfo.txt" || exit
nvidia-smi topo -m >>"${log_basename}-nvidia-smi.txt" || exit

make -C .. || exit

ccc_mprun nsys profile -o "nsys-report-${BRIDGE_MSUB_JOBID}" -t openacc ${exec}
ccc_mprun ${exec}
