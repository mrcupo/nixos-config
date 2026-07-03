{ pkgs, ... }:

{
  # Game storage
  # - /mnt/games-nvme lives on the NVMe root filesystem.
  # - /mnt/games-ssd is a dedicated Samsung 860 QVO ext4 partition.
  # Both are intended as Steam library locations owned by user:users.
  fileSystems."/mnt/games-ssd" = {
    device = "/dev/disk/by-label/DESKTOP-GAMES";
    fsType = "ext4";
    options = [ "defaults" "noatime" ];
  };

  environment.systemPackages = with pkgs; [ liquidctl cifs-utils ];

  # udev rules for liquidctl, allowing access to NZXT USB devices without root.
  services.udev.packages = [ pkgs.liquidctl ];
}
