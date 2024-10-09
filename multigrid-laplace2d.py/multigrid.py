"""
Multigrid method for solving the 2D Laplace equation

This script test a simple multigrid method for solving the Laplace equation.
The dirty implemented "algorithm" performs a reduction and prolongation once,
without checking for a specific value before ascending and descending the grid.
The number of steps on each grid size is also arbitrary (and not optimized).
Further work is required to really capture the possible performance gains.

The initial condition is a square room, with:

- a window at `T_WINDOW`
- one cold wall at `T_WALLE`
- three walls at `T_WALLI`
- two heaters (H1 & H2) at `T_HEATER`

The below scheme represents the situation:

           T_WINDOW
    +---------------------+ T_WALLE
    |                     |
    |                     |
    | H2                  |
    |                     |
    |                     |
    |                     |
    |                  H1 |
    |                     |
    |                     |
    |                     |
    +---------------------+ T_WALL_I

"""

import time

import numpy as np
import numpy.linalg as LA
import seaborn as sns
import matplotlib.pyplot as plt

from numpy.typing import NDArray

N = 128
NSTEPS = 20000
T_WINDOW: float = 5.0
T_WALLSE: float = 13.5
T_WALLSI: float = 21.0
T_HEATER: float = 38.0


def temperature_initial(
    n: int,
    t_window: float = T_WINDOW,
    t_walls: float = T_WALLSE,
    t_wall_bottom: float = T_WALLSI,
    t_heater: float = T_HEATER,
) -> NDArray:
    t = np.zeros((n, n))

    # Top
    t_top_left = np.linspace(t_walls, t_window, n // 4, endpoint=False)
    t_top_right = np.linspace(t_window, t_walls, n // 4, endpoint=False)
    t[:2, : n // 4] = t_top_left
    t[:2, 3 * n // 4 :] = t_top_right
    t[:2, n // 4 : 3 * n // 4] = t_window

    # Bottom
    t[n - 2 :, :] = t_wall_bottom

    # Left
    t_left_top = np.linspace(t_walls, t_heater, 3 * n // 8, endpoint=False)
    t_left_bottom = np.linspace(t_heater, t_wall_bottom, n // 2, endpoint=False)
    t[: (3 * n // 8), :2] = t_left_top[:, np.newaxis]  # Assign to both columns
    t[(n // 2) :, :2] = t_left_bottom[:, np.newaxis]

    # Right
    t_right_top = np.linspace(t_walls, t_heater, n // 2, endpoint=False)
    t_right_bottom = np.linspace(t_heater, t_wall_bottom, 3 * n // 8, endpoint=False)
    t[: (n // 2), -2:] = t_right_top[:, np.newaxis]
    t[(5 * n // 8) :, -2:] = t_right_bottom[:, np.newaxis]

    # Heater
    t = temperature_heater(t, t_heater)

    return t


def temperature_heater(grid: NDArray, t_heater: float) -> NDArray:
    n, _ = grid.shape

    grid[(3 * n // 8) : (n // 2) + 1, : (n // 8 + 1)] = t_heater
    grid[(n // 2) : (5 * n // 8) + 1, -(n // 8 + 1) :] = t_heater

    return grid


def temperature_update_jacobi(t: NDArray) -> NDArray:
    # _t = t.copy()
    # m, n = _t.shape
    # for i in range(2, m - 1):
    #     for j in range(2, n - 1):
    #         _t[i, j] = (t[i + 1, j] + t[i - 1, j] + t[i, j - 1] + t[i, j + 1]) / 4.0
    # t = _t

    t[2:-2, 2:-2] = (
        t[3:-1, 2:-2] + t[1:-3, 2:-2] + t[2:-2, 1:-3] + t[2:-2, 3:-1]
    ) / 4.0

    return t


def temperature_restriction(t: NDArray, s: int = 2) -> NDArray:
    return t[::s, ::s]


def temperature_prolongation(t: NDArray, s: int = 2) -> NDArray:
    n, _ = tuple(dim * 2 for dim in t.shape)

    _t = temperature_initial(n)

    # for i in range(2, n - 2):
    #     for j in range(2, n - 2):
    #         _t[i, j] = (
    #             t[int(np.floor((i + 1) / 2)), int(np.floor((j + 1) / 2))]
    #             + t[int(np.ceil((i + 1) / 2)), int(np.floor((j + 1) / 2))]
    #             + t[int(np.floor((i + 1) / 2)), int(np.ceil((j + 1) / 2))]
    #             + t[int(np.ceil((i + 1) / 2)), int(np.ceil((j + 1) / 2))]
    #         ) / 4

    # Index arrays for the grid
    i_indices = np.arange(2, n - 2)[:, np.newaxis]
    j_indices = np.arange(2, n - 2)

    # Compute the corresponding indices in `t`
    i1 = np.floor((i_indices + 1) / 2).astype(int)
    i2 = np.ceil((i_indices + 1) / 2).astype(int)
    j1 = np.floor((j_indices + 1) / 2).astype(int)
    j2 = np.ceil((j_indices + 1) / 2).astype(int)

    # Gather value from `t`
    t_vals = (t[i1, j1] + t[i1, j2] + t[i2, j1] + t[i2, j2]) / 4

    # Assign values in `_t`
    _t[2 : n - 2, 2 : n - 2] = t_vals

    return _t


def test_restriction(n: int = N, t_heater: float = T_HEATER) -> None:
    t = temperature_initial(n, t_heater=t_heater)
    t_res = temperature_restriction(t)
    t_pro = temperature_prolongation(t_res)

    _, axes = plt.subplots(1, 3)
    sns.heatmap(t, ax=axes[0], cbar=True)
    sns.heatmap(t_res, ax=axes[1], cbar=True)
    sns.heatmap(t_pro, ax=axes[2], cbar=True)
    axes[0].set_title("Original")
    axes[1].set_title("Restriction")
    axes[2].set_title("Prolongation")
    plt.show()


def temperature_solved(
    t: NDArray,
    t_heater: float,
    eps: float = 1e-5,
    nsteps: int = NSTEPS,
    print_res: bool = False,
) -> tuple[NDArray, float, int]:
    t = t.copy()
    # l2norm_list: list[float] = []
    res: float = 1.0

    for i in range(nsteps):
        i += 1
        _t = t.copy()
        t = temperature_update_jacobi(t)

        if res < eps:
            print(f"Solution converged in {i} iterations")
            break

        # l2norm = LA.norm(t - _t).astype(float)
        # l2norm_list.append(l2norm)
        # res = l2norm / np.asarray(l2norm_list).max()
        res = LA.norm(t - _t) / LA.norm(t).astype(float)

        if print_res:
            print(i, res)

        t = temperature_heater(t, t_heater)

    return t, res, i


def test_solve(
    n: int = N,
    t_heater: float = T_HEATER,
    eps: float = 1e-5,
    nsteps: int = NSTEPS,
    print_res: bool = False,
    plot: bool = False,
) -> None:
    t0 = temperature_initial(n, t_heater=t_heater)
    start = time.time()
    tf, res, i = temperature_solved(
        t0,
        t_heater,
        eps=eps,
        nsteps=nsteps,
        print_res=print_res,
    )
    end = time.time()

    print(res, i, f"{end - start:.4f}")

    if plot:
        _, axes = plt.subplots(1, 2)
        sns.heatmap(t0, ax=axes[0], cbar=True)
        sns.heatmap(tf, ax=axes[1], cbar=True)
        axes[0].set_title("Initial")
        axes[1].set_title("Solved")
        plt.show()


def temperature_solved_mg(
    t: NDArray,
    t_heater: float,
    eps: float = 1e-5,
    nsteps: int = NSTEPS,
    print_res: bool = False,
) -> tuple[NDArray, float, int]:
    t = t.copy()
    i = 0

    params = {
        "eps": eps,
        "nsteps": nsteps,
        "print_res": print_res,
    }

    t, res, i_ = temperature_solved(t, t_heater, **params)  # type: ignore[arg-type]
    i += i_

    t = temperature_restriction(t)
    t, res, i_ = temperature_solved(t, t_heater, **params)  # type: ignore[arg-type]
    i += i_

    t = temperature_prolongation(t)
    t, res, i_ = temperature_solved(t, t_heater, **params)  # type: ignore[arg-type]
    i += i_

    return t, res, i


def test_solve_mg(
    n: int = N,
    t_heater: float = T_HEATER,
    eps: float = 1e-5,
    nsteps: int = NSTEPS // 2,
    print_res: bool = False,
    plot: bool = False,
) -> None:
    t0 = temperature_initial(n, t_heater=t_heater)
    start = time.time()
    tf, res, i = temperature_solved_mg(
        t0,
        t_heater,
        eps=eps,
        nsteps=nsteps,
        print_res=print_res,
    )
    end = time.time()

    print(res, i, f"{end - start:.4f}")

    if plot:
        _, axes = plt.subplots(1, 2)
        sns.heatmap(t0, ax=axes[0], cbar=True)
        sns.heatmap(tf, ax=axes[1], cbar=True)
        axes[0].set_title("Initial")
        axes[1].set_title("Solved")
        plt.show()


if __name__ == "__main__":
    # test_restriction()

    plot = True
    print_res = False

    test_solve(
        n=256,
        plot=plot,
        print_res=print_res,
    )
    test_solve_mg(
        n=256,
        plot=plot,
        print_res=print_res,
    )
