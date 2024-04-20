import nix
from pathlib import Path

# Pythonix has some issues evaluating relative paths
TEST_FILE = Path(__file__).parent.resolve() / "math.nix"


def isEvenv_expr(file: Path, value: int) -> bool:
    return """
    (
      {pkgs ? import <nixpkgs> {}}: let
        inherit (pkgs) lib;
        math = import %s {inherit lib;};
      in
        math.isEven (%s)
    ) {}
    """ % (file, str(value))  # f-strings require to escape curly braces


def test_isEven_1():
    expr = nix.eval(isEvenv_expr(TEST_FILE, 2))
    assert expr is True


def test_isEven_2():
    expr = nix.eval(isEvenv_expr(TEST_FILE, -17))
    assert expr is True
