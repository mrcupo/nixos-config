{ globals, ... }:

# Headless admin access.
#
# SSH is reachable only over Tailscale. The provider firewall should also keep
# port 22 closed on public interfaces.
{
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  # user's personal key (laptop/desktop ~/.ssh/id_ed25519). Single source of
  # truth is globals.ssh.user (also the agenix recovery recipient in secrets.nix).
  users.users.user.openssh.authorizedKeys.keys = [ globals.ssh.user ];
}
