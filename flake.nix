{
  description = "Sandbox";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
              entry = "${pkgs.python3}/bin/python make_readme.py";
              files = ".*\\.(nix|py|md)";
              language = "system";
              pass_filenames = false;
            };
            make_readme_gh = {
              enable = true;
              name = "make-readme-gh";
              entry = "${pkgs.stdenv.shell} .github/make-readme.sh";
              files = ".*\\.(md|html)";
              language = "system";
              pass_filenames = false;
            };

            alejandra.enable = true;
            commitizen.enable = true;
            editorconfig-checker.enable = true;
            markdownlint.enable = true;
            prettier.enable = true;
            shellcheck.enable = true;
            ruff.enable = true;
            statix.enable = true;
            typos.enable = true;
          };
        };
      };

      devShells = {
        default = pkgs.mkShell {
          propagatedBuildInputs = with pkgs; [
            just
          ];
          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
            export NIX_PATH="nixpkgs=${inputs.nixpkgs}"
          '';
        };
      };
    });
}
