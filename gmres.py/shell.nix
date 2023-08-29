{pkgs ? import <nixpkgs> {}}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      matplotlib
      numpy
      scipy
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      ruff
      pythonWithPackages
    ];
  }