{
  description = "Sandbox";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = inputs @ {
    self,
    flake-utils,
    nixpkgs,
    pre-commit-hooks,
    ...
  }: let
    supportedSystems = ["x86_64-linux"];
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in rec {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;

          hooks = with pkgs; {
            make_readme = {
              enable = true;
              name = "make-readme";
              entry = "${pkgs.stdenv.shell} .github/make-readme.sh";
              files = "README\.md";
              language = "system";
              pass_filenames = false;
            };
            alejandra.enable = true;
            commitizen.enable = true;
            editorconfig-checker.enable = true;
            markdownlint.enable = true;
            prettier.enable = true;
            shellcheck.enable = true;
            statix.enable = true;
            typos.enable = true;
          };
        };
      };

      devShells.default = pkgs.mkShell {
        propagatedBuildInputs = with pkgs; [
          just
        ];
        inherit (self.checks.${system}.pre-commit-check) shellHook;
      };
    });
}
