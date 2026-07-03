{ config, lib, ... }:

# Declarative disk layout for the VPS, applied by nixos-anywhere during install.
#
# WARNING: nixos-anywhere will WIPE the target disk according to this file.
# Keep the default as a non-existent by-id path so an unconfirmed install fails
# safely instead of wiping whatever `/dev/sda` happens to be on the provider.
{
  options.server.installDisk = lib.mkOption {
    type = lib.types.str;
    default = "/dev/disk/by-id/CHANGE-ME-SERVER-INSTALL-DISK";
    description = ''
      Absolute disk path to wipe/install Server onto. Before the real install,
      confirm the provider's disk name and firmware from the rescue image:
      disks are often /dev/vda or /dev/nvme0n1, not /dev/sda. Prefer a stable
      /dev/disk/by-id path when available.

      This layout assumes UEFI. If the provider is BIOS-only, replace the ESP
      with a 1M bios_grub partition (type "EF02") and use GRUB in
      hosts/server/default.nix instead of systemd-boot.
    '';
  };

  config.disko.devices.disk.main = {
    type = "disk";
    device = config.server.installDisk;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
