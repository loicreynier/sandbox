#! /usr/bin/env bash

if [ -z "$_NIX_SHEBANG" ] && command -v nix-shell &> /dev/null; then
    # Install dependencies with nix
    _NIX_SHEBANG=1 nix shell \
        nixpkgs#hello \
        nixpkgs#cowsay \
        --command "$0" "$@"
    exit $?
fi

hello | cowsay
