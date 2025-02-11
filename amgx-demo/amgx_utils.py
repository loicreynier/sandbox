import numpy as np
from scipy.sparse import coo_matrix


class AMGXSystem:
    def __init__(self, file_path: str):
        self.file_path = file_path
        self._load_data()

    def _load_data(self) -> None:
        with open(self.file_path, "r") as file:
            lines = file.readlines()

        size_data = lines[2].strip().split()
        num_rows = int(size_data[0])
        num_cols = int(size_data[1])
        shape = (num_rows, num_cols)
        num_entries = int(size_data[2])

        # Matrix
        data_start_idx = 3
        matrix_data = lines[data_start_idx : data_start_idx + num_entries]
        self._parse_matrix(matrix_data, shape)

        # RHS vector
        data_start_idx += num_entries + 1  # +1 to remove
        rhs_data = lines[data_start_idx : data_start_idx + num_rows]
        self._rhs = self._vector_from_lines(rhs_data)

        # Solution vector
        data_start_idx += num_rows + 1  # +1 to remove header
        sol_data = lines[data_start_idx:]
        self._sol = self._vector_from_lines(sol_data)

    def _parse_matrix(self, lines: list, shape: tuple[int, int]) -> None:
        rows, cols, data = [], [], []
        for line in lines:
            col, row, value = map(float, line.split())
            # Convert to 0-based indexing
            rows.append(int(row - 1))
            cols.append(int(col - 1))
            data.append(value)
        self._matrix = coo_matrix((data, (rows, cols)), shape=shape).tocsr().toarray()

    def _vector_from_lines(self, lines: list) -> np.ndarray:
        return np.array([float(line.strip()) for line in lines])

    @property
    def matrix(self) -> np.ndarray:
        return self._matrix

    @property
    def rhs(self) -> np.ndarray:
        return self._rhs

    @property
    def sol(self) -> np.ndarray:
        return self._sol


def print_array_diff(a, b, tol: float = 1e-12, strict: bool = False) -> None:
    if a.ndim != 1 or b.ndim != 1:
        raise ValueError("Both arrays must be 1D.")
    if a.shape != b.shape:
        raise ValueError("Both arrays must have the same length")

    if strict:
        diff = np.where(a != b)[0]
    else:
        diff = np.where(~np.isclose(a, b, atol=tol))[0]

    for i in diff:
        print(f"Difference at index {i}: {a[i]} \t {b[i]}")


if __name__ == "__main__":
    system = AMGXSystem("./AMGX_system.mtx")
    rhs = np.loadtxt("./rhs.dat")
    sol = np.loadtxt("./sol.dat")
    print_array_diff(system.rhs, rhs)
    print_array_diff(system.sol, sol)
