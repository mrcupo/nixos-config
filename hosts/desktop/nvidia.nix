{ config, ... }:

{
  # NVIDIA RTX 5080 (Blackwell) on AMD Ryzen 9800X3D
  # No PRIME/Optimus needed — 9800X3D has no integrated graphics
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # Open kernel modules are REQUIRED for RTX 50 series (Blackwell)
    # Proprietary modules do not support these GPUs at all
    open = true;

    # Modesetting is required for Wayland compositors (niri)
    modesetting.enable = true;

    # PINNED to 595.71.05 — the previous working driver. nixpkgs bumped
    # stable/production to 595.80 (2026-06-08) which caused issues, so this
    # rebuilds the older driver against the current kernel via mkDriver.
    # To upgrade later: delete this block and restore
    #   package = config.boot.kernelPackages.nvidiaPackages.stable;
    # (hashes copied from nixpkgs ffa10e26's production definition)
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "595.71.05";
      sha256_64bit = "sha256-NiA7iWC35JyKQva6H1hjzeNKBek9KyS3mK8G3YRva4I=";
      sha256_aarch64 = "sha256-XzKloS00dFKTd4ATWkTIhm9eG/OzR/Sim6MboNZWPu8=";
      openSha256 = "sha256-Lfz71QWKM6x/jD2B22SWpUi7/og30HRlXg1kL3EWzEw=";
      settingsSha256 = "sha256-mXnf3jyvznfB3OfKd657rxv0rYHQb/dX/Riw/+N9EKU=";
      persistencedSha256 = "sha256-Z/6IvEEa/XfZ5F5qoSIPvXJLGtscYVqjFxHZaN/M2Ts=";
    };

    # Power management — safe to enable on desktop, helps with idle power draw
    powerManagement.enable = true;
    # Fine-grained power management is for laptops with PRIME, skip on desktop
    powerManagement.finegrained = false;

    # nvidia-settings GUI — useful for checking GPU state, fan curves, etc.
    nvidiaSettings = true;
  };

  # Enable OpenGL / Vulkan
  hardware.graphics = {
    enable = true;
    enable32Bit = true;   # needed for 32-bit games via Steam/Proton
  };

  # Kernel params for Wayland + NVIDIA
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"     # framebuffer device — fixes TTY resolution
  ];

  # Ensure nvidia modules load early
  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  # AMD CPU microcode updates (Ryzen 9800X3D)
  hardware.cpu.amd.updateMicrocode = true;

  # Environment variables for NVIDIA + Wayland
  environment.variables = {
    # Use GBM as the backend (not EGLStreams — that's dead)
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    # Help Electron/Chrome pick the right GPU
    LIBVA_DRIVER_NAME = "nvidia";
    # Explicit sync — niri supports this, reduces tearing
    __GL_GSYNC_ALLOWED = "1";
  };

  # Stop the NVIDIA driver hoarding VRAM under Wayland compositors.
  # Without this, idle niri sits on ~1 GiB of VRAM instead of ~100 MiB.
  # https://niri-wm.github.io/niri/Nvidia.html
  environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json".text = builtins.toJSON {
    rules = [{
      pattern = { feature = "procname"; matches = "niri"; };
      profile = "Limit Free Buffer Pool On Wayland Compositors";
    }];
    profiles = [{
      name = "Limit Free Buffer Pool On Wayland Compositors";
      settings = [{ key = "GLVidHeapReuseRatio"; value = 0; }];
    }];
  };

  # CUDA support (useful for ML work, video encoding, etc.)
  # Uncomment if you need it:
  # environment.systemPackages = [ pkgs.cudatoolkit ];
}
