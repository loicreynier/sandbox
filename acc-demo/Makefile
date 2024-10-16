src_dir = ./src
bin_dir = ./bin
target  = $(bin_dir)/out

FC     = nvfortran
FFLAGS = -fast -acc=gpu -Minfo=all

.PHONY: all clean test

$(target): $(src_dir)/main.f90
	@mkdir -p $(@D)
	nvfortran $^ -o $@ $(FFLAGS)

clean:
	$(RM) -r $(bin_dir)
