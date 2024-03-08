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
    {
      templates = {
        flake = {
          path = ./.templates/flake;
          description = "Sandbox with flake";
        };
        shell = {
          path = ./.templates/shell;
          description = "Sandbox with only a Nix shell";
        };
      };
    }
    // flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;

          hooks = {
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
