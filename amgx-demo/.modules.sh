#!/usr/bin/env sh

case "$(hostname -a)" in
olympelogin*)
  module purge

  # module load intel/18.2 gcc/5.4.0 cuda/9.1.85.3 openmpi/icc/2.0.2.10
  # export AMGX_ROOT=/usr/local/amgx/AMGX

  module load nvidia/nvhpc/22.1-cuda-11.5-majslurm
  module load amgx/2.2.x-nvhpc

  module list
  ;;
esac
