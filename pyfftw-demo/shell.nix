{
  pkgs ? (
    let
      # Last commit before `pyfftw` was removed from `nixpkgs`
      commit = "755b915a158c9d588f08e9b08da9f7f3422070cc";
      nixpkgs = builtins.fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
        sha256 = "sha256:15brcl2i6hk7nq8mmg71pfkf61swq2swjw11i1pc7bcb59hmh909";
      };
    in
      import nixpkgs {}
  ),
}: let
  pythonWithPackages = pkgs.python3.withPackages (p:
    with p; [
      numpy
      pyfftw
      scipy
    ]);
in
  pkgs.mkShell {
    packages = [
      pythonWithPackages
    ];
  }
