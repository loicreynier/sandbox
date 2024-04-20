#!/usr/bin/env sh

nix shell \
  --impure \
  --expr '(import <nixpkgs> {}).python3.withPackages (p: with p; [ pytest pythonix ])' \
  --command pytest ./test_pythonix.py
