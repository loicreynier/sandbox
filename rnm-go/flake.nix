{
  description = "A simple Go CLI util to rename files";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      rnm-go = pkgs.buildGoModule {
        pname = "rnm-go";
        version = "unstable";
        src = ./.;
        vendorHash = null;
      };
    });
    devShells = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      default = pkgs.mkShell {
        name = "rnm-nix-shell";
        buildInputs = with pkgs; [
          go
          gopls
          gotools
          go-tools
        ];
      };
    });
    defaultPackage = forAllSystems (system: self.packages.${system}.rnm-go);
  };
}
