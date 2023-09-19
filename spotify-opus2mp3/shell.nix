{pkgs ? import <nixpkgs> {}}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      mutagen
      ffmpeg-python
      typer
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      ruff
      pythonWithPackages
    ];
  }
