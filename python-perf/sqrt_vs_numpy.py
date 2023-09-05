import math
from timeit import Timer

import numpy as np

N = int(10e6)
X = 1012.1234215

t = Timer(lambda: math.sqrt(X))
print(f"`math.sqrt`:\t{t.timeit(number=N):1.3f} seconds")

t = Timer(lambda: np.sqrt(X))
print(f"`numpy.sqrt`:\t{t.timeit(number=N):1.3f} seconds")
