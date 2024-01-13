# Nix shell where the source of a package is downloaded with a custom command.
#
# From my answer on a question on Unix & Linux Stack Exchange:
# https://unix.stackexchange.com/questions/766754
#
# `runCommandLocal` is used to downloaded the source using `axel`:
#
# editorconfig-checker-disable
{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  name = "cuda-env-shell";
  buildInputs = with pkgs; [
    (cudatoolkit.overrideAttrs (finalAttrs: previousAttrs: {
      inherit (previousAttrs) pname;
      src =
        runCommandLocal "${previousAttrs.pname}.run" {
          nativeBuildInputs = [axel];
          # outputHashMode = "flat";
          # outputHashAlgo = "sha256";
          # outputHash = "";
          outputHash = "sha256-kiPErzrr5Ke77Zq9mxY7A6GzS4VfvCtKDRtwasCaWhY=";
        } ''
          # ${pkgs.axel}/bin/axel \
          axel \
            --num-connections=10 \
            --verbose \
            --insecure \
            --output "$out" \
            "https://developer.download.nvidia.com/compute/cuda/11.8.0/local_installers/cuda_11.8.0_520.61.05_linux.run"
        '';
    }))
  ];
}
