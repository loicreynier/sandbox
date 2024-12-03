#ifndef CUDA_UTILS_H

#include <cuda_runtime_api.h>

#ifdef __cplusplus
typedef cudaDeviceProp CUDA_DEVICE_PROP_T;
#else
typedef struct cudaDeviceProp CUDA_DEVICE_PROP_T;
#endif

#ifdef __cplusplus
typedef cudaDeviceProp CUDA_DEVICE_PROP;
#else
typedef struct cudaDeviceProp CUDA_DEVICE_PROP;
#endif

char *cudaUUID_str(cudaUUID_t uuid);
void cudaGetDeviceUUIDStr(int deviceID, char *str, int str_length);

int cudaDeviceCount();

void cudaListDevices(FILE *out_file, FILE *err_file);
void cudaListDevices_stdout();

#endif // CUDA_UTILS_H
