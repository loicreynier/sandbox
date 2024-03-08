{
  pkgs ? (
    let
      inherit (builtins) fetchTree fromJSON readFile;
      inherit ((fromJSON (readFile ../flake.lock)).nodes) nixpkgs;
    in
      import (fetchTree nixpkgs.locked) {}
  ),
}:
pkgs.mkShell {
  packages = with pkgs; [
    hello
  ];
}
