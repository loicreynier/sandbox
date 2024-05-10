# `cuda-demo`

Small CUDA samples.

Currently,
the code must be compiled and run from the NVIDIA HPC SDK Container
since I wasn't able to set up HPC SDK on (WSL-)NixOS:

```shell
just run-container ./c.out # Compile and run C code
just run-container ./f.out # Compile and run Fortran code
```
