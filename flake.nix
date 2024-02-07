{
  description = "Utilities for running rootless nix on a compute cluster";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    let
      nvidiaComputeDriversFor = settings@{ cudaArch, cudaVersion, ... }: final: prev: rec {
        nvidiaComputeDrivers = final.callPackage ./nvidiaComputeDrivers.nix settings;
        nvidiaComputeDriversHook = ''
          if which nvidia-smi; then
            _123_NVIDIA_COMPUTE_DRIVERS_VERSION=$(nvidia-smi --query-gpu driver_version --format csv,nounits,noheader)
            if [[ $_123_NVIDIA_COMPUTE_DRIVERS_VERSION != ${nvidiaComputeDrivers.version} ]]; then
              echo "WARNING: nvidiaComputeDrivers.version (${nvidiaComputeDrivers.version}) from Nix does not match the driver version on the device ($_123_NVIDIA_COMPUTE_DRIVERS_VERSION). This will likely cause your program to crash."
            fi
          fi
          export LD_LIBRARY_PATH=${nvidiaComputeDrivers}/lib:$LD_LIBRARY_PATH
        '';
      };

      pkgsFor = system: version: import inputs.nixpkgs ({
        inherit system;
        config.allowUnfree = true;
        config.cudaSupport = true;
        config.nvidia.acceptLicense = true;
        overlays = [
          (nvidiaComputeDriversFor { cudaArch = "tesla"; cudaVersion = version; })
        ];
      });
    in
    {
      packages = inputs.flake-utils.lib.eachDefaultSystemMap (system:
        with pkgsFor system "535.104.12"; {
          inherit nvidiaComputeDrivers;
        });

      devShells = inputs.flake-utils.lib.eachDefaultSystemMap (system:
        with pkgsFor system "535.104.12"; {
          testSnellius = mkShell {
            shellHook = ''
              ${nvidiaComputeDriversHook}
            '';
          };
        });

      lib = {
        inherit nvidiaComputeDriversFor;
      };

      overlays = {
        lilo = inputs.self.lib.nvidiaComputeDriversFor {
          cudaArch = "tesla";
          cudaVersion = "535.104.12";
        };
        snellius = inputs.self.lib.nvidiaComputeDriversFor {
          cudaArch = "tesla";
          cudaVersion = "545.23.08";
        };
      };
    };
}
