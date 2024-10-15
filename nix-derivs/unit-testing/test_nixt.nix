# Usage: `nix run github:nix-community/nixt -- test_nixt.nix`
# Does not work? Test are not collected
{
  pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ../../flake.lock)).nodes) nixpkgs;
    in
      import (fetchTree nixpkgs.locked) {}
  ),
  nixt,
}: let
  inherit (pkgs) lib;
  math = import ./math.nix {inherit lib;};
in
  nixt.mkSuite "check isEven" {
    "even number" = math.isEven 2 == true;
    "odd number" = math.isEven (-18) == true;
  }
