#!/usr/bin/env bash

set -eu

https://hydra.nixos.org/build/237603629/download/1/nix

# If the NIX_STORE_PATH environment variable is not set, default to
# /scratch/$USER/nix
if [ -z ${NIX_STORE_PATH+x} ]; then
  NIX_STORE_PATH=/scratch/$USER/nix
fi
mkdir -v -p "$NIX_STORE_PATH"
mkdir -v -p "$HOME/.local/share"
ln -v --symbolic "$NIX_STORE_PATH" "$HOME/.local/share/"

# NIX_STATIC_BIN tells us the location of the nix-static executable.
if [ -z ${NIX_STATIC_BIN+x} ]; then
  NIX_STATIC_BIN="$HOME/.cache/nix-static"
fi
mkdir -v -p "$(dirname \"$NIX_STATIC_BIN\")"
cp -v nix-static "$NIX_STATIC_BIN"
cp -v nix $HOME/.local/bin
