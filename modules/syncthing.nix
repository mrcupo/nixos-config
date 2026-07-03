{ ... }:

# Syncthing for private note/file sync between devices.
{
  services.syncthing = {
    enable = true;
    user = "user";
    dataDir = "/home/user";
    configDir = "/home/user/.config/syncthing";
    # Do not open Syncthing ports on every network interface; the firewall rule
    # below keeps sync reachable over Tailscale without exposing it on public Wi-Fi.
    openDefaultPorts = false;
  };

  networking.firewall.interfaces.tailscale0 = {
    allowedTCPPorts = [ 22000 ];
    allowedUDPPorts = [ 22000 21027 ];
  };
}
