"""GMRES algorithm for the resolution of a :math:`Ax = b` system."""

import numpy as np
from numpy.typing import NDArray
import scipy.linalg
import scipy.sparse
import scipy.sparse.linalg

# import matplotlib.pyplot as plt


def arnoldi_iteration(
    a: NDArray,
    b: NDArray,
    n: int,
    tol: float = 1e-12,
) -> tuple[NDArray, NDArray]:
    """Compute a basis of the (n + 1)-Krylov subspace of `a`.

    Parameters
    ----------
    a : ndarray
        m-by-m system matrix.
    b : ndarray
        Initial vector of shape (m,).
    n : int
        Dimension of Krylov subspace.
    tol : float, optional
        Tolerance.

    Returns
    -------
    q : ndarray
        m-by-(n + 1) matrix of the orthonormal basis of the Krylov
        subspace.
    h : ndarray
        A matrix projected on basis Q. Has shape (n + 1, n) and is a
        Hessenberg matrix.

    Notes
    -----
    This function is inspired from the algorithm provided by the
    Wikipedia article [1]_ on Arnoldi iteration and a Stack Overflow
    question [2]_ on the behavior of the latter algorithm for complex
    algorithms.

    References
    ----------
    .. [1] Wikipedia contributors, "Arnoldi iteration," Wikipedia,
       The Free Encyclopedia,
       https://en.wikipedia.org/w/index.php?title=Arnoldi_iteration&oldid=1088703662
       (accessed October 18, 2022).
    .. [2] MPA, Oct 29th, 2018, answer on MPA "Wiki example for Arnoldi
       iteration only works for real matrices?", StackOverflow,
       https://stackoverflow.com/questions/53042140
       (accessed October 18, 2022)
    """
    h = np.zeros((n + 1, n), dtype=a.dtype)
    q = np.zeros((a.shape[0], n + 1), dtype=a.dtype)
    q[:, 0] = b / np.linalg.norm(b, 2)

    for k in range(n):
        v = a @ q[:, k]
        for j in range(k + 1):
            h[j, k] = q[:, j].conj().T @ v
            v = v - h[j, k] * q[:, j]
        h[k + 1, k] = np.linalg.norm(v, 2)
        if h[k + 1, k] > tol:
            q[:, k + 1] = v / h[k + 1, k]
        else:
            break
    return q, h


def test_arnoldi_iteration(
    n: int = 16,
    atol: float = 1e-6,
    rtol: float = 1e-4,
) -> None:
    r"""Test Arnoldi iteration.

    Test is performed over a matrix with eigenvalues
    :math:`1...n` by checking if :math:`AQ_n = Q_{n+1}\hat{H}_n`
    and if :math:`Q_n` is orthogonal.

    Parameters
    ----------
    n : int, optional
        Test matrix dimension.
    atol : float, optional
        Test relative tolerance.
    rtol : float, optional
        Test absolute tolerance.
    """
    np.random.seed(0)
    eigvals = np.linspace(1.0, n, n)
    eigvecs = np.random.randn(n, n)
    a = np.linalg.solve(eigvecs, np.diag(eigvals) @ eigvecs)
    # print(np.linalg.eigvals(a))
    x0 = np.random.randn(n)
    q, h = arnoldi_iteration(a, x0, n)
    qn = q[:, :-1]
    # plt.imshow(h)
    # plt.show()

    # Check that Q_n is orthogonal
    # plt.imshow(qn.conj().T @ qn)
    # plt.show()
    assert np.allclose(
        qn.conj().T @ qn, np.eye(qn.shape[1]), rtol=rtol, atol=atol
    )

    # Check that AQ_n = Q_(n+1)H
    assert np.allclose(a @ qn, q @ h, rtol=rtol, atol=atol)
    # assert np.allclose(
    #     q.conj().T @ a @ qn - h, np.zeros(h.shape), rtol=rtol, atol=atol
    # )


def test_arnoldi_iteration_hermitian(n: int = 64) -> None:
    """Test Arnoldi iteration.

    Test is performed over a Hermitian matrix by checking if the
    Hessenberg matrix is tridiagonal.

    Parameters
    ----------
    n : int, optional
        Test matrix dimension.

    Notes
    -----
    This test is inspired by the StackOverflow question [1]_ on the
    behavior of the Arnoldi iteration for Hermitian matrices.

    References
    ----------
    .. [2] MPA, Oct 29th, 2018, "Wiki example for Arnoldi
       iteration only works for real matrices?", StackOverflow,
       https://stackoverflow.com/questions/53042140
       (accessed October 18, 2022)
    """
    k = np.fft.fftfreq(n, 1.0 / n) + 0.5
    alpha = np.linspace(0.1, 1.0, n) * 2e2
    c = scipy.linalg.circulant(np.fft.fft(alpha) / n)
    a = np.einsum("i, ij, j->ij", k, c, k)
    # Check that A is Hermitian
    # print(np.allclose(a, a.conj().T))

    np.random.seed(0)
    x0 = np.random.rand(n)
    _, h = arnoldi_iteration(a, x0, n)
    h = h[:-1]
    # plt.imshow(np.abs(h))
    # plt.show()
    # Check that H is diagonal
    w, v = np.linalg.eig(h)
    assert np.allclose(h @ v - v @ np.diag(w), np.zeros(h.shape))


# pylint: disable=too-many-arguments
def gmres(
    a: NDArray,
    b: NDArray,
    x0: NDArray,
    maxiter: int = 50,
    tol: float = 1e-8,
    print_info: bool = False,
) -> NDArray:
    """Solve linear system using GMRES method.

    Parameters
    ----------
    a : ndarray
        Linear system matrix. Has shape (n, n).
    b : ndarray
        Right hand side of the linear system. Has shape (n,).
    x0 : ndarray
        Starting guess for the solution. Has shape (n,).
    maxiter : int, optional
        Maximum number of iterations.
    tol : float, optional
        Tolerance for convergence.
    print_info : bool, optional
        Whether to print iteration information.

    Returns
    -------
    x : ndarray
        Converged solution.
    """
    r0 = b - a @ x0
    beta = np.linalg.norm(r0, 2)
    for k in range(maxiter):
        q, h = arnoldi_iteration(a, r0, k)
        e1 = np.zeros((k + 1,))
        e1[0] = 1.0
        y = np.linalg.lstsq(h, beta * e1, rcond=None)[0]
        r = np.linalg.norm(h @ y - beta * e1)
        if print_info:
            print(f"{k:03d} {r:08e}", flush=True)
        if r < tol:
            break
    return x0 + q[:, :-1] @ y


def test_gmres(n: int = 64) -> None:
    """Test GMRES on a random sparse system.

    Parameters
    ----------
    n : int, optional
        Test matrix dimension.
    """
    np.random.seed(40)
    shape = n, n
    coords = np.random.choice(n * n, size=n, replace=False)
    coords = np.unravel_index(coords, shape)
    values = np.random.normal(size=n)
    a_sparse = scipy.sparse.coo_matrix((values, coords), shape=shape)
    a_sparse = a_sparse.tocsr()
    a_sparse += scipy.sparse.eye(n)
    a = a_sparse
    b = np.random.normal(size=n)
    b = a_sparse @ b
    x0 = np.zeros((n,))
    x = gmres(a, b, x0)
    # assert np.allclose(x, scipy.sparse.linalg.gmres(a, b, x0)[0])
    assert np.allclose(a @ x - b, np.zeros(shape))


if __name__ == "__main__":
    test_arnoldi_iteration()
    test_arnoldi_iteration_hermitian()
    test_gmres(n=256)
