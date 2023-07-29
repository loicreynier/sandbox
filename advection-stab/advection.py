import numpy as np
import matplotlib.pyplot as plt

A = -1.0  # advection coefficient
CFL = 0.1
T = 1.0
N = 128

x = np.linspace(-np.pi, np.pi, N, endpoint=False)
k = np.fft.rfftfreq(N, d=1.0 / N)  # Fourier modes
dt = CFL / (np.abs(A) * N)

# Fourier time-advancement operators
alias_filter = k < N * 2.0 / 6.0
g = 1.0 - 1.0j * dt * A * k
h = g * alias_filter
G = np.diag(g)
H = np.diag(h)
print(np.linalg.eigvals(H))

# Time integration
u = np.sin(2.0 * x) ** 2 * (x < -np.pi / 2.0)
u_c = np.fft.rfft(u)
u0_c = u_c.copy()
for i in range(0, int(T / dt)):
    u_c = H @ u_c
    # u_c *= g

# Comparison with exact solution
plt.plot(
    x,
    np.fft.irfft(np.exp(-1.0j * k * A * T) * u0_c),
    x,
    np.fft.irfft(u_c),
    "*",
    markevery=0.01,
)
plt.show()
