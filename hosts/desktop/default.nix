{ inputs, ... }:

# Desktop host. Imports the shared modules/ via flake.nix; this file adds the
# desktop-only NixOS modules and desktop-specific system config.
{
  imports = [
    ./hardware-configuration.nix
    ./niri.nix
    ./noctalia.nix
    ./nvidia.nix
    ./gaming.nix
    ./openrgb.nix
    ./storage.nix
    ./sunshine-support.nix
    ./remote-build.nix
  ];

  system.stateVersion = "25.11";

  # Proton-CachyOS overlay (used by gaming.nix). Merges with the Helium
  # overlay applied for all hosts in flake.nix.
  nixpkgs.overlays = [ inputs.proton-cachyos.overlays.default ];

  # Desktop DNS servers are stable on the home network. The laptop keeps
  # NetworkManager's DHCP/default DNS behavior for travel/public Wi-Fi.
  networking = {
    nameservers = [ "192.0.2.53" "192.0.2.54" ];
    networkmanager.dns = "none";
  };

  # Desktop boot extras: uinput for Sunshine, nzxt-smart2 for the NZXT case
  # controller (driven by liquidctl). Generation limit is set in modules/boot.nix.
  boot.kernelModules = [ "uinput" "nzxt-smart2" ];

  # user needs the "input" group for VIA WebHID + Sunshine uinput access.
  users.users.user.extraGroups = [ "input" ];

  # QMK/VIA raw-HID access.
  hardware.keyboard.qmk.enable = true;

  # Helium NVIDIA fix — native GLES instead of ANGLE on the RTX 5080
  # (driver 595.x). Appended to the shared programs.helium.flags.
  programs.helium.flags = [ "--use-gl=egl" ];
}
