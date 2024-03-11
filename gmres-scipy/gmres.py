"""Wrapper for the GMRES provided by SciPy."""

import sys
import warnings
from collections.abc import Callable
from typing import IO

import numpy as np
import scipy.sparse.linalg
from numpy.typing import NDArray
from scipy.sparse.linalg import LinearOperator


class GMRESSaturation(Warning):
    """GMRES saturation warning."""


class GMRESCallback:
    """Callback for ``scipy.sparse.linalg``.

    Count iterations and check if the residue is evolving. If not, a
    ``GMRESSaturation`` warning is raised.

    Attributes
    ----------
    _show : bool
        Whether to print iteration information.
    _stdout : IO
        Where to print iteration information.
    niter : int
        Iteration count.
    res : float
        Iteration residue.
    resvartol : float
        Residue evolution tolerance.

    Notes
    -----
    The saturation warning technique is inspired by a StackOverflow
    question [1]_ on how to terminate the behavior of a SciPy's
    optimization process.

    References
    ----------
    .. [1] Muhammad Mohsin Khan, Jan 17th, 2022, answer on sadra
       "How terminate the optimization in scipy?", StackOverflow,
       https://stackoverflow.com/questions/70724216
       (accessed November 07, 2022)
    """

    def __init__(
        self,
        show: bool = True,
        stdout: IO = sys.stdout,
        resvartol: float = 1e-5,
    ) -> None:
        self._show: bool = show
        self._stdout: IO = stdout
        self.resvartol: float = resvartol
        self.res: float = 1.0
        self.niter: int = 0

    def __call__(self, res) -> None:
        self.niter += 1
        res_old = self.res
        self.res = res
        if abs(res_old - res) / abs(res_old) < self.resvartol:
            warnings.warn("Terminating GMRES: saturation", GMRESSaturation)
        if self._show:
            print(res, flush=True, file=self._stdout)


def gmres_sp(
    L: Callable[[NDArray], NDArray],
    f: NDArray,
    x0: NDArray,
    precond: Callable[[NDArray], NDArray] | None = None,
    tol: float = 1e-8,
    maxiter: int = 50,
    log_file: IO = sys.stdout,
) -> NDArray:
    """Solve `L`(x) = `f` using GMRES from SciPy.

    Since the GMRES from SciPy solve the linear system Ax = b where
    x and b are 1D arrays, the function `L` and the preconditioner
    `precond` are interfaced using ``LinearOperator`` from
    ``scipy.sparse.linalg``.

    A callback is wrapped around the GMRES to count the iterations
    and to check if the residue is evolving.

    Parameters
    ----------
    L : callable
        Function computing L(x). L(x) and x have shape (m, n).
    x0 : ndarray
        Strating guess for the solution. Has shape (m, n)
    f : ndarray
        Right hand side of the linear system. Has shape (m, n).
    maxiter : int, optional
        Maximum number of iterations.
    tol : float, optional
        Tolerance for convergence.
    log_file : IO
        Where to print iteration logs.

    Returns
    -------
    x : ndarray
        Converged solution.
    """
    q0 = np.copy(x0).reshape(-1)
    g = np.copy(f).reshape(-1)
    shape = x0.shape
    size = x0.size

    def mvL(v):
        return L(v.reshape(shape)).reshape(-1)

    if precond:

        def mvM(v):
            return precond(v.reshape(shape)).reshape(-1)

        m = LinearOperator((size, size), matvec=mvM, matmat=precond)
    else:
        m = None

    callback = GMRESCallback(stdout=log_file)
    a = LinearOperator((size, size), matvec=mvL, matmat=L)
    q, _ = scipy.sparse.linalg.gmres(
        a,
        g,
        q0,
        M=m,
        tol=tol,
        maxiter=maxiter,
        callback=callback,
        callback_type="pr_norm",
    )
    x = q.reshape(shape)
    print(
        f"{callback.niter:03d} {callback.res:08e}",
        flush=True,
        file=log_file,
    )
    return x
