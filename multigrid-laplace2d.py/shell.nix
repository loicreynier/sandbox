{pkgs ? import <nixpkgs> {}}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      matplotlib
      numpy
      seaborn
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      pythonWithPackages
    ];
  }
