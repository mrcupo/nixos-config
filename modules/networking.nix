{ ... }:

# Shared networking. networking.hostName is supplied per-host by mkHost in
# flake.nix. Host-specific firewall/DNS extras live in hosts/<host>/.
{
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    # Both hosts trust the tailnet interface. Host-specific port openings
    # (e.g. the laptop's LocalSend) live in hosts/<host>/.
    firewall.trustedInterfaces = [ "tailscale0" ];
  };

  services.tailscale.enable = true;
}
