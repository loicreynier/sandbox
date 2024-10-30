#!/usr/bin/env sh

case "$(hostname)" in
olympelogin*)
  module purge
  module load nvidia/nvhpc/22.7-cuda-11.7-majslurm
  module list
  ;;
topaze*)
  module load nvhpc/22.2 nsight/22.2
  module list
  ;;
esac
