#!/usr/bin/env sh

case "$(hostname -a)" in
olympelogin*)
  module purge
  module load nvidia/nvhpc/22.7-cuda-11.7-majslurm
  module list
  ;;
esac
