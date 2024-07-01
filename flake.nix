{
  description = "Sandbox";

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
            checkmake.enable = true;
            clang-format.enable = true;
            deadnix.enable = true;
            editorconfig-checker.enable = true;
            gofmt.enable = true;
            markdownlint.enable = true;
            nil.enable = true;
            prettier.enable = true;
            ruff.enable = true;
            shfmt.enable = true;
            shellcheck.enable = true;
            statix.enable = true;
            taplo.enable = true;
            typos.enable = true;
            typstfmt.enable = true;
            yamllint.enable = true;
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

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    pre-commit-hooks = {
      url = "github:NorfairKing/nix-pre-commit-hooks/typstfmt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
