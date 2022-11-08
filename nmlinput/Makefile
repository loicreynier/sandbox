src = test.f90
lib = nmlinput.f90

FC := gfortran
FCFLAGS := -fbackslash

all: test

test: $(src:.f90=.out)
	./$^

$(src:.f90=.out): $(src) $(lib:.f90=.o)
	$(FC) $(FCFLAGS) $^ -o $@

$(lib:.f90=.o): $(lib)
	$(FC) $(FCFLAGS) -c $< -o $@

.PHONY: all clean test
