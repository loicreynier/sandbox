{pkgs ? import <nixpkgs> {}}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      matplotlib
      numpy
      pdoc
      scipy
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      ruff
      just
      pythonWithPackages
    ];
  }
