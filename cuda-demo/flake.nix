{
  description = "Flake template with CUDA environment";

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }: (flake-utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
      };
    in {
      devShells.default = let
        # cudaToolkit = pkgs.cudaPackages_12_3.cudatoolkit;
        cudaToolkit = pkgs.symlinkJoin {
          name = "cudatoolkit-12.3-joined";
          paths = with pkgs.cudaPackages_12_3; [
            cuda_cudart
            cuda_nvcc
            cuda_nvprof
            cuda_profiler_api
          ];
        };
        gcc = pkgs.gcc11;
      in
        pkgs.mkShell {
          buildInputs = [
            cudaToolkit
            gcc
          ];
          shellHook =
            # Source: github.com/EspressoSystems/HotShot
            ''
              export CUDA_PATH=${cudaToolkit}
              export CPATH=${cudaToolkit}/include
              export LD_LIBRARY_PATH=${cudaToolkit}/lib
              export PATH="${gcc}/bin:${cudaToolkit}/bin:${cudaToolkit}/nvvm/bin:$PATH"
            '';
        };
    }
  ));

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
