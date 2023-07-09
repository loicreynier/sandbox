{pkgs ? import <nixpkgs> {}}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      pyudev
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      jmtpfs
      ruff
      pythonWithPackages
    ];
  }
