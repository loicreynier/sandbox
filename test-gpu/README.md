# Compilation notes

`mpif90` wrapper of `nvfortran` requires `-acc=gpu` or `-cuda` to compile a binary that can detect GPUs

Cannot use c interface if using `mpic++`
