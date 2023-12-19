from typing import get_type_hints
import inspect


def factorial(
    n: "(n := inspect.stack()[4].frame.f_locals['n']) and (n * factorial(n - 1)) or 1",
):
    return get_type_hints(factorial)["n"]
