# FROM nvidia/cuda:12.4.1-devel-ubuntu22.04
FROM nvcr.io/nvidia/nvhpc:24.3-devel-cuda_multi-ubuntu22.04

RUN mkdir /tmp/cuda
COPY src/main.cu  /tmp/cuda/main.cu
COPY src/main.cuf /tmp/cuda/main.cuf
WORKDIR /tmp/cuda
RUN nvcc main.cu -o c.out
RUN nvfortran main.cuf -o f.out

# ENTRYPOINT ["/tmp/cuda/f.out"]
