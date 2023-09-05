{pkgs ? import <nixpkgs> {}}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      numpy
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      ruff
      pythonWithPackages
    ];
  }
