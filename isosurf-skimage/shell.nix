{pkgs ? import <nixpkgs> {}}: let
  dontCheckPython = drv: drv.overridePythonAttrs (old: {doCheck = false;});
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      matplotlib
      numpy
      scikit-image
      (dontCheckPython tikzplotlib)
    ]);
in
  pkgs.mkShell {
    packages = with pkgs; [
      ruff
      pythonWithPackages
    ];
  }
