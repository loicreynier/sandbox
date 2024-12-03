#!/usr/bin/env bash

case $HOSTNAME in
olympe*)
  module load nvidia/nvhpc/23.9-cuda-11.8-majslurm
  ;;
esac
