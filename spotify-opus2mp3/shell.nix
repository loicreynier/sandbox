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
      mutagen
      ffmpeg-python
      typer
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      pythonWithPackages
    ];
  }
