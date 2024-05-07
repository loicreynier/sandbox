#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define N (2048 * 2028)
#define MAX_ERR 1e-6

__global__ void VecAdd(float *a, float *b, float *c, int n) {
  int i = blockDim.x * blockIdx.x + threadIdx.x;
  if (i < n)
    c[i] = a[i] + b[i];
}

void fill_array_random_floats(float *array, float size, float min, float max) {
  srand(time(NULL));

  for (int i = 0; i < size; i++) {
    array[i] = min + ((float)rand() / RAND_MAX) * (max - min);
  }
}

int main(void) {
  float *h_a, *h_b, *h_c;
  float *d_a, *d_b, *d_c;
  size_t size = N * sizeof(float);

  // Allocate host memory
  h_a = (float *)malloc(size);
  h_b = (float *)malloc(size);
  h_c = (float *)malloc(size);

  // Allocate device memory
  cudaMalloc(&d_a, size);
  cudaMalloc(&d_b, size);
  cudaMalloc(&d_c, size);

  // Initialize input vectors
  fill_array_random_floats(h_b, N, 0.0f, 7.0f);
  fill_array_random_floats(h_a, N, 11.0f, 17.0f);

  // Copy vectors from host memory to device memory
  cudaMemcpy(d_a, h_a, size, cudaMemcpyHostToDevice);
  cudaMemcpy(d_b, h_b, size, cudaMemcpyHostToDevice);

  // Invoke kernel
  int threadsPerBlock = 256;
  int blocksPerGrid = (N + threadsPerBlock - 1) / threadsPerBlock;
  VecAdd<<<blocksPerGrid, threadsPerBlock>>>(d_a, d_b, d_c, N);

  // Copy result from device memory to host memory
  cudaMemcpy(h_c, d_c, size, cudaMemcpyDeviceToHost);

  // Synchronize before running more host code
  cudaDeviceSynchronize();

  // Verification
  for (int i = 0; i < N; i++) {
    assert(fabs(h_c[i] - h_a[i] - h_b[i]) < MAX_ERR);
  }

  // Deallocate host memory
  free(h_a);
  free(h_b);
  free(h_c);

  // Deallocate device memory
  cudaFree(d_a);
  cudaFree(d_b);
  cudaFree(d_c);

  return 0;
}
