import math
from timeit import Timer

N = int(10e6)
X = 1012.1234215
Y = 7.654321

t = Timer(lambda: X**Y)
print(f"`**`:\t\t{t.timeit(number=N):1.3f} seconds")

t = Timer(lambda: float(X) ** Y)
print(f"`float` + `**`:\t{t.timeit(number=N):1.3f} seconds")

t = Timer(lambda: pow(X, Y))
print(f"`pow`:\t\t{t.timeit(number=N):1.3f} seconds")

# `math.pow` is slower because it always uses float semantics
t = Timer(lambda: math.pow(X, Y))
print(f"`math.pow`:\t{t.timeit(number=N):1.3f} seconds")
