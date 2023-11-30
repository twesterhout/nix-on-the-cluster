{
  description = "Utilities for running rootless nix on a compute cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    let
      nvidiaComputeDriversFor = settings@{ cudaArch, cudaVersion, ... }: final: prev: {
        nvidiaComputeDrivers = final.callPackage ./nvidiaComputeDrivers.nix settings;
      };

      pkgsFor = system: import inputs.nixpkgs ({
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
        config.nvidia.acceptLicense = true;
        overlays = [
          (nvidiaComputeDriversFor { cudaArch = "tesla"; cudaVersion = "535.104.12"; })
        ];
      });
    in
    {
      packages = inputs.flake-utils.lib.eachDefaultSystemMap (system:
        with pkgsFor system; {
          inherit nvidiaComputeDrivers;
        });

      lib = {
        inherit nvidiaComputeDriversFor;
      };

      overlays = {
        lilo = inputs.self.lib.nvidiaComputeDriversFor {
          cudaArch = "tesla";
          cudaVersion = "535.104.12";
        };
      };
    };
}
