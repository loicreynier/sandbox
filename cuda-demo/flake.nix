{
  description = "Flake with CUDA environment";

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: (flake-utils.lib.eachDefaultSystem (
    system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
        # Cannot import this easily
        # overlays = [
        #   (import "${inputs.nur-dguibert}/overlays/nvhpc-overlay/default.nix")
        # ];
      };
    in {
      devShells = rec {
        default = cudaToolkit;

        cudaToolkit = let
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

        hpcSDK = let
          lmod = pkgs.callPackage ./nix/lmod.nix {src = inputs.lmod;};
          nvhpc = pkgs.callPackage ./nix/nvhpc.nix {};
          gcc = pkgs.gcc11;
        in
          pkgs.mkShell {
            buildInputs = [
              nvhpc
              # pkgs.nvhpcPackages_21_7.nvhpc # from `nur-dguibert`
              lmod
              gcc
            ];
            # Dirty module load, doesn't work
            shellHook = ''
              . ${lmod}/share/lmod/lmod/init/bash
              module use ${nvhpc}/share/nvhpc/modulefiles
              module load nvhpc
            '';
          };
      };
    }
  ));

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nur-dguibert = {
      url = "github:dguibert/nur-packages";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lmod = {
      url = "github:TACC/Lmod";
      flake = false;
    };
  };
}
