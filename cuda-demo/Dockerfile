FROM nvidia/cuda:12.4.1-devel-ubuntu22.04

# Copy the CUDA hello world program into the container
RUN mkdir /tmp/cuda
COPY src/main.cu /tmp/cuda/main.cu

# Set the working directory
WORKDIR /tmp/cuda

# Compile the CUDA program
RUN nvcc main.cu -o run

# Set the entry point
ENTRYPOINT ["/tmp/cuda/run"]
