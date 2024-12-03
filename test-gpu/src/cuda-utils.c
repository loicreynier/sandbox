#include <openacc.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "cuda-utils.h"

// UUID example (from `nvidia-smi`): (GPU-)295af94b-04bc-5f1f-097e-c5aa2a2d698d
char *cudaUUID_str(cudaUUID_t uuid) {
  int i, j;
  char *str = (char *)malloc(33);
  char hex[3];
  int uuid_segments[][2] = {{0, 4}, {4, 6}, {6, 8}, {8, 10}, {10, 16}};

  str[0] = '\0';
  for (i = 0; i < 5; i++) {
    if (i != 0)
      strcat(str, "-");
    for (j = uuid_segments[i][0]; j < uuid_segments[i][1]; j++) {
      sprintf(hex, "%02x", (unsigned)(unsigned char)uuid.bytes[j]);
      strcat(str, hex);
    }
  }

  return str;
}

void cudaGetDeviceUUIDStr(int deviceID, char *str, int str_length) {
  CUDA_DEVICE_PROP deviceProp;
  cudaError_t cudaStatus = cudaGetDeviceProperties(&deviceProp, deviceID);
  const char *deviceUUID = cudaUUID_str(deviceProp.uuid);

  strncpy(str, deviceUUID, str_length);
  if (str_length > 0) {
    str[str_length - 1] = '\0';
  }
}

int cudaDeviceCount() {
  int deviceCount = 0;
  cudaError_t cudaStatus = cudaGetDeviceCount(&deviceCount);

  if (cudaStatus != cudaSuccess) {
    fprintf(stderr, "Failed to get device count: %s\n",
            cudaGetErrorString(cudaStatus));
  }

  return deviceCount;
}

void cudaListDevices_stdout() {
  cudaListDevices(stdout, stderr);
}

void cudaListDevices(FILE *out_file, FILE *err_file) {
  cudaError_t cudaStatus;
  CUDA_DEVICE_PROP deviceProp;
  int i, n;
  int gpuDirectSupport;
  char *uuid;

  n = cudaDeviceCount();

  fprintf(out_file, "=== Listing devices using CUDA C API\n");
  for (i = 0; i < n; ++i) {

    // Get props
    cudaStatus = cudaGetDeviceProperties(&deviceProp, i);
    if (cudaStatus != cudaSuccess) {
      fprintf(err_file, "Failed to get device properties for device %d: %s\n",
              i, cudaGetErrorString(cudaStatus));
      continue;
    }

    uuid = cudaUUID_str(deviceProp.uuid);

    // Check GPU Direct support - Should return 1 if supported
    cudaError_t cudaStatus = cudaDeviceGetAttribute(
        &gpuDirectSupport, cudaDevAttrDirectManagedMemAccessFromHost, i);
    if (cudaStatus != cudaSuccess) {
      fprintf(err_file, "Failed to get GPUDirect attribute: %s\n",
              cudaGetErrorString(cudaStatus));
    }

    fprintf(out_file, "- Device %d: %s / UUID: %s", i, deviceProp.name, uuid);
    if (gpuDirectSupport == 1) {
      fprintf(out_file, " / GPU Direct\n");
    } else {
      fprintf(out_file, " / NO GPU Direct\n");
    }
  }
}
