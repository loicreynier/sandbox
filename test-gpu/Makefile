#ACCFLAGS = -acc=gpu -Minfo=accel
CC       = mpicc
CCFLAGS  = -cuda -acc=gpu
FC       = mpif90
FFLAGS   = -Mfree -module $(obj_dir)
FFLAGS  += -cuda -acc=gpu -Minfo=accel
LDFLAGS  = -cuda -acc=gpu -I${NVHPC_CUDA_HOME}/include -L${NVHPC_CUDA_HOME}/lib64 -ldl -lcudart -lcuda

src_dir     := src
bin_dir     := bin
obj_dir     := obj
target      := $(bin_dir)/gpu.out

all: $(target)

$(obj_dir)/%.o: $(src_dir)/%.f90
	@mkdir -p $(@D)
	$(FC) -c $^ -o $@ $(FFLAGS)

$(obj_dir)/%.o: $(src_dir)/%.c
	@mkdir -p $(@D)
	$(CC) -c $^ -o $@ $(CCFLAGS) $(LDFLAGS)

$(target): $(obj_dir)/openacc-mod.o $(obj_dir)/cuda-utils.o $(obj_dir)/cuda-mod.o $(obj_dir)/main.o
	@mkdir -p $(@D)
	$(FC) $^ -o $@ $(LDFLAGS)

clean:
	$(RM) -r $(bin_dir)
	$(RM) -r $(obj_dir)

.PHONY: all test clean
