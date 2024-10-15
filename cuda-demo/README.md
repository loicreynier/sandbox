# `cuda-demo`

Small CUDA samples.

## NixOS

Currently (2024/05), on NixOS (or at least in my WSL-NixOs setup),
the code must be compiled and run from the NVIDIA HPC SDK Container
since I wasn't able to set up HPC SDK.

```shell
just run-container ./c.out # Compile and run C code
just run-container ./f.out # Compile and run Fortran code
```
