# Usage: `nix run github:nix-community/nixt -- test_nixt.nix`
# Does not work? Test are not collected
{
  pkgs ? import <nixpkgs> {},
  nixt,
}: let
  inherit (pkgs) lib;
  math = import ./math.nix {inherit lib;};
in
  nixt.mkSuite "check isEven" {
    "even number" = math.isEven 2 == true;
    "odd number" = math.isEven (-18) == true;
  }
# vim: ft=nix

