#!/usr/bin/env sh

cd "$(dirname "$0")" || exit
# echo "$(basename "$0"): running in $(pwd)"
{ cat "gh-header.html"; tail -n +2 "../README.md"; } > "../.github/README.md"
