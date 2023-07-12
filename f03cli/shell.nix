{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = with pkgs; [
    fprettify
    gfortran
    gnumake
    just
  ];
}
