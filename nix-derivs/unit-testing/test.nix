# Usage: `nix eval --impure --expr 'import ./test.nix {}'`
{
  pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ../../flake.lock)).nodes) nixpkgs;
    in
      import (fetchTree nixpkgs.locked) {}
  ),
}: let
  inherit (pkgs) lib;
  inherit (lib) runTests;
  math = import ./math.nix {inherit lib;};
in
  runTests {
    testIsEven_1 = {
      expr = math.isEven 2;
      expected = true;
    };
    testIsEven_2 = {
      expr = math.isEven (-17);
      expected = true; # For testing
      # expected = false;
    };
  }
