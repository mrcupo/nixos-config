{ pkgs, ... }:

# Laptop host. Imports the shared modules/ via flake.nix; this file adds the
# laptop-only NixOS modules and laptop-specific system config.
{
  imports = [
    ./hardware-configuration.nix
    ./niri.nix
    ./noctalia.nix
    ./greeter.nix
    ./power.nix
    ./remote-build.nix
  ];

  system.stateVersion = "25.11";

  # LocalSend remains reachable over Tailscale via the shared trusted tailscale0
  # interface, but is not opened on every Wi-Fi network the laptop joins.

  # Noctalia v5 Cachix (the laptop runs Noctalia v5). Merges into the shared
  # nix.settings from modules/nix-settings.nix.
  nix.settings = {
    substituters = [ "https://noctalia.cachix.org" ];
    trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

  # Provide /bin/* and /usr/bin/* from PATH so non-NixOS scripts work.
  services.envfs.enable = true;

  # Printing — Brother MFC-9130CW uses the 9140CDN driver family.
  services.printing = {
    enable = true;
    drivers = with pkgs; [ mfc9140cdnlpr mfc9140cdncupswrapper ];
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    # Keep mDNS closed on travel/public Wi-Fi. Temporarily open on a trusted LAN
    # if printer discovery is needed.
    openFirewall = false;
  };
}
