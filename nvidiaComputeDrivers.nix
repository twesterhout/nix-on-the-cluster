# A package with Nvidia drivers for CUDA and OpenCL. Very similar to
# nvidia_x11, but we skip the graphics libraries to have a smaller package.
{ fetchurl
, lib
, linuxPackages
, cudaArch
, cudaVersion
, cudaHash ? ""
}:

let
  knownSettings = [
    {
      cudaArch = "tesla";
      cudaVersion = "535.86.10";
      cudaHash = "sha256-zsN/2TFwkaAf0DgDCUAKFChHaXkGUf4CHh1aqiMno3A=";
    }
    {
      cudaArch = "tesla";
      cudaVersion = "535.104.12";
      cudaHash = "sha256-/8LYniM9JCftsf9fQ2AoqUs++G54+X4IjhHZBcgugAE=";
    }
    {
      cudaArch = "tesla";
      cudaVersion = "545.23.08";
      cudaHash = "";
    }
  ];

  builder = arch: version: hash:
    ((linuxPackages.nvidia_x11.override {
      libsOnly = true;
      kernel = null;
      firmware = null;
    }).overrideAttrs
      (oldAttrs: {
        pname = "nvidia-compute-drivers";
        name = "nvidia-compute-drivers-${arch}-${version}";
        inherit version;
        src = fetchurl {
          url = "https://us.download.nvidia.com/${arch}/${version}/NVIDIA-Linux-x86_64-${version}.run";
          inherit hash;
        };
        useGLVND = false;
        useProfiles = false;
        postFixup = ''
          ls -l $out/lib
          rm -v -r $out/bin
          rm -v -r $out/lib/nvidia
          rm -v -r $out/lib/systemd
          rm -v -r $out/lib/vdpau
          rm -v $out/lib/libEGL*
          rm -v $out/lib/libnvidia-egl*
          rm -v $out/lib/libnvidia-encode*
          rm -v $out/lib/libnvidia-fbc*
          rm -v $out/lib/libnvidia-gl*
          rm -v $out/lib/libnvidia-pkcs11*
          rm -v $out/lib/libnvidia-tls*
          rm -v $out/lib/libGL*
          rm -v $out/lib/libOpenGL*
          rm -v $out/lib/libglx*
          rm -v $out/lib/libnvcuvid*
        '';
      }));

  settings =
    lib.findFirst
      (x: x.cudaArch == cudaArch && x.cudaVersion == cudaVersion)
      { inherit cudaArch cudaVersion cudaHash; }
      knownSettings;
in
builder settings.cudaArch settings.cudaVersion settings.cudaHash
