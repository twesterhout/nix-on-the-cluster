{
  description = "Utilities for running rootless nix on a compute cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    {
      lib = {
        nvidiaComputeDriversFor = settings@{ cudaArch, cudaVersion, ... }: final: prev: {
          nvidiaComputeDrivers = final.callPackage ./nvidiaComputeDrivers.nix settings;
        };
      };

      overlays = {
        lilo = inputs.self.lib.nvidiaComputeDriversFor {
          cudaArch = "tesla";
          cudaVersion = "535.104.12";
        };
      };
    };
}
