ifdef NVHPC_ROOT
	CUDA_HOME      = $(NVHPC_CUDA_HOME)
	MATH_LIBS_PATH = $(NVHPC_ROOT)/math_libs/lib64
endif

ifndef CUDA_HOME
	$(error CUDA_HOME is not set)
endif

ifndef AMGX_ROOT
	$(error AMGX_ROOT is not set)
endif

AMGX_INCLUDE   = -I$(AMGX_ROOT)/include
AMGX_LIBS_PATH = $(AMGX_ROOT)/lib
AMGX_LIBS      = -L$(AMGX_LIBS_PATH)
CUDA_LIBS_PATH = $(CUDA_HOME)/lib64
CUDA_LIBS      = -L$(CUDA_LIBS_PATH)

ifeq ($(NVHPC_ROOT),)
	# CC = icc
	# FC = ifort
	CC = mpicc
	FC = mpifort
else
	# CC = nvcc
	# FC = nvfortran
	CC = mpicc
	FC = mpif90
endif

ifeq ($(FC), ifort)
	FFLAGS  += -O3 -xCOMMON-AVX512
	LDFLAGS += -lmpi
else ifeq ($(FC), nvfortran)
	FFLAGS = -O3
else
	FFLAGS = -O3
endif
FFLAGS += -module $(obj_dir)
CFLAGS  = $(AMGX_INCLUDE)
LDFLAGS = $(AMGX_LIBS) -lamgxsh -Wl,-rpath=$(AMGX_LIBS_PATH)

# With proper environment configuration (probably `LD_LIBRARY_PATH`)
# linking the CUDA libraries doesn't seem necessary (tested on Olympe)
# `ldl` doesn't seem necessary, at least when the CUDA libraries are not linked.
# Similarly, if the CUDA libraries are properly configured in the environment,
# specifying the math library path doesn't seem necessary
# (tested on Olympe: Intel + CUDA without NVHPC).
# LDFLAGS = $(CUDA_LIBS) \
# 	$(AMGX_LIBS) \
# 	-lcudart     \
# 	-lcublas     \
# 	-lcusparse   \
# 	-ldl         \
# 	-lamgxsh     \
# 	-Wl,-rpath=$(AMGX_LIBS_PATH) \
# 	-Wl,-rpath=$(CUDA_LIBS_PATH) \
# `dl`      : Link dynamic linking library, required ?
# `cudart`  : Link CUDA runtime, required
# `cublas`  : Link cuBLAS, required depending on AMGX functionality?
# `cusparse`: Link cuSPARSE, required depending on AMGX functionality?
# `amgxsh`  : Link AMGX, "sh" = "shared" -> dynamic version -> `-ldl`

# ifdef NVHPC_ROOT
# 	LDFLAGS += -L$(MATH_LIBS_PATH) -Wl,-rpath=$(MATH_LIBS_PATH)
# endif

src_dir     := src
bin_dir     := bin
obj_dir     := obj
target      := $(bin_dir)/amgx.out

.PHONY: all clean test print-vars

all: $(target)

$(target): $(obj_dir)/amgx.o $(obj_dir)/main.o
	@mkdir -p $(@D)
	$(FC) $(FFLAGS) $^ -o $@ $(LDFLAGS)

$(obj_dir)/%.o: $(src_dir)/%.c
	@mkdir -p $(@D)
	$(CC) $(CFLAGS) -c $< -o $@

$(obj_dir)/%.o: $(src_dir)/%.f90
	@mkdir -p $(@D)
	$(FC) $(FFLAGS) -c $< -o $@

clean:
	$(RM) -r $(bin_dir)
	$(RM) -r $(obj_dir)

print-vars:
	@echo $(AMGX_ROOT)
	@echo $(CUDA_HOME)
	@echo $(CC) $(CFLAGS)
	@echo $(FC) $(FFLAGS)
	@echo $(LDFLAGS)
