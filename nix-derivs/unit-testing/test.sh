#!/usr/bin/env sh

nix eval --impure --expr 'import ./test.nix {}'
