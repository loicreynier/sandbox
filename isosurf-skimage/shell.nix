let
  nixpkgs-version = "ed20d94473a7811ee9f8c045c6be326176fd648d";
  pkgs = import (builtins.fetchTarball {
    name = "nixpkgs-${nixpkgs-version}";
    url = "https://github.com/nixos/nixpkgs/archive/${nixpkgs-version}.tar.gz";
    sha256 = "sha256-qR+/HFGZxlAmSKUIlQOM+WRIcEG6oRrdVm4KUvS7694=";
  }) {};

  dontCheckPython = drv: drv.overridePythonAttrs (_: {doCheck = false;});
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      matplotlib
      numpy
      scikit-image
      (dontCheckPython tikzplotlib)
    ]);
in
  pkgs.mkShell {
    packages = [
      pythonWithPackages
    ];
  }
