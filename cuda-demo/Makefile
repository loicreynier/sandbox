NVCC    := nvcc

src_dir := src
bin_dir := bin
obj_dir := obj
srcs    := $(wildcard $(src_dir)/*.cu)
objs    := $(srcs:$(src_dir)/%.cu=$(obj_dir)/%.o)
target  := $(bin_dir)/run

.PHONY: all clean test

all: $(target)

$(target): $(objs)
	@mkdir -p $(@D)
	$(NVCC) $(LDFLAGS) $^ -o $@

$(obj_dir)/%.o: $(src_dir)/%.cu
	@mkdir -p $(@D)
	$(NVCC) $(CFLAGS) -c $< -o $@

clean:
	$(RM) -r $(bin_dir)
	$(RM) -r $(obj_dir)

