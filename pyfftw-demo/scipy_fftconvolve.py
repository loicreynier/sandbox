import pyfftw
import scipy.signal
import numpy
from timeit import Timer

# Planning first and enabling cache for optimization
shape = (1024, 512)
a = pyfftw.empty_aligned(shape, dtype="complex128")
b = pyfftw.empty_aligned(shape, dtype="complex128")
pyfftw.interfaces.cache.enable()

a[:] = numpy.random.randn(*shape) + 1j * numpy.random.randn(*shape)
b[:] = numpy.random.randn(*shape) + 1j * numpy.random.randn(*shape)

t = Timer(lambda: scipy.signal.fftconvolve(a, b))
print(f"Vanilla: {t.timeit(number=100):1.3f} seconds")

# Patching `fftpack` with `pyfftw.interfaces.scipy_fftpack`
scipy.fftpack = pyfftw.interfaces.scipy_fftpack
scipy.signal.fftconvolve(a, b)

print(f"Patched: {t.timeit(number=100):1.3f} seconds")
