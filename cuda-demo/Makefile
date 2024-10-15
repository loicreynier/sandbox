NVCC    := nvcc
FC      := nvfortran
FFLAGS  := -cuda


src_dir  := src
bin_dir  := bin
obj_dir  := obj
srcs_c   := $(wildcard $(src_dir)/*.cu)
srcs_f   := $(wildcard $(src_dir)/*.cuf)
objs_c   := $(srcs_c:$(src_dir)/%.cu=$(obj_dir)/%.c.o)
objs_f   := $(srcs_f:$(src_dir)/%.cuf=$(obj_dir)/%.f.o)
target_c := $(bin_dir)/c.out
target_f := $(bin_dir)/f.out

.PHONY: all clean test

all: $(target_c) $(target_f)

$(target_c): $(objs_c)
	@mkdir -p $(@D)
	$(NVCC) $(CFLAGS) $^ -o $@ $(LDFLAGS)

$(obj_dir)/%.c.o: $(src_dir)/%.cu
	@mkdir -p $(@D)
	$(NVCC) $(CFLAGS) -c $< -o $@

$(target_f): $(objs_f)
	@mkdir -p $(@D)
	$(FC) $(FFLAGS) $^ -o $@

$(obj_dir)/%.f.o: $(src_dir)/%.cuf
	@mkdir -p $(@D)
	$(FC) $(FFLAGS) -c $< -o $@ $(LDFLAGS)


clean:
	$(RM) -r $(bin_dir)
	$(RM) -r $(obj_dir)

