#!/usr/bin/env bash

# If the NIX_STORE_PATH environment variable is not set, default to
# /scratch/$USER/nix
if [ -z ${NIX_STORE_PATH+x} ]; then
  NIX_STORE_PATH=/scratch/$USER/nix
fi
mkdir -p "$NIX_STORE_PATH"

# NIX_STATIC_BIN tells us the location of the nix-static executable. By
# default, we expect to find it in ~/.cache
if [ -z ${NIX_STATIC_BIN+x} ]; then
  NIX_STATIC_BIN="$HOME/.cache/nix-static"
fi

exec -a "$0" \
  "$NIX_STATIC_BIN" \
  --store "$STORE_PATH/root" \
  "$@"
