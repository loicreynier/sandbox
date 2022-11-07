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
              entry = "${pkgs.stdenv.shell} .github/make-gh-readme.sh";
              files = "README\.md";
              language = "system";
              pass_filenames = false;
            };
            alejandra.enable = true;
            commitizen = {
              enable = true;
              entry = "${pkgs.commitizen}/bin/cz check --commit-msg-file";
              stages = ["commit-msg"];
            };
            editorconfig-checker = {
              enable = true;
              entry = "${pkgs.editorconfig-checker}/bin/editorconfig-checker";
              types = ["file"];
            };
            markdownlint = {
              enable = true;
              excludes = [".github/README.md"];
            };
            prettier.enable = true;
            shellcheck.enable = true;
            statix.enable = true;
            typos = {
              enable = true;
              entry = "${pkgs.typos}/bin/typos";
            };
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
