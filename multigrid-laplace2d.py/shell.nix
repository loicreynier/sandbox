{
  pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ../flake.lock)).nodes) nixpkgs;
    in
      import (fetchTree nixpkgs.locked) {}
  ),
}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      matplotlib
      numpy
      seaborn
    ]);
in
  pkgs.mkShell {
    packages = [
      pythonWithPackages
    ];
  }
