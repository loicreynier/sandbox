{pkgs ? import <nixpkgs> {}}: let
  dontCheckPython = drv: drv.overridePythonAttrs (old: {doCheck = false;});
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      numpy
      pyfftw
      scipy
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      ruff
      pythonWithPackages
    ];
  }
