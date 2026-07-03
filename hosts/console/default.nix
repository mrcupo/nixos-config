{ lib, ... }:

# Living-room gaming PC. The gaming-console profile is selected in flake.nix;
# this file adds only console-specific modules and settings.
{
  imports = [
    ./jovian.nix
    ./tuning.nix
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  # Bootstrap defaults so the flake output can evaluate before the real
  # nixos-generate-config output exists. The generated hardware config copied
  # during install overrides these normal labels with the actual disk paths.
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [
      "fmask=0022"
      "dmask=0022"
    ];
  };

  system.stateVersion = "25.11";
}
