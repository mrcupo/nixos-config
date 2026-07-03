{ ... }:

# Server networking: tailnet-trusted firewall, DHCP on the primary NIC, and no
# NetworkManager (cloud images get a DHCP lease directly). hostName is set
# per-host by mkHost. Host-specific port openings live in hosts/<host>/.
{
  networking = {
    useDHCP = true;
    firewall = {
      enable = true;
      trustedInterfaces = [ "tailscale0" ];
      allowedTCPPorts = [ ];
    };
  };

  services.tailscale.enable = true;
}
