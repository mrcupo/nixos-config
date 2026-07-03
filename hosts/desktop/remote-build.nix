{ ... }:

# Accept distributed builds from laptop over the tailnet. laptop's side
# (nix.buildMachines) lives in hosts/laptop/remote-build.nix.
{
  # Run SSH for remote Nix builds, but do not let the OpenSSH module open port
  # 22 globally. The firewall rule below exposes it only on the tailnet.
  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  users.users.nixremote = {
    isNormalUser = true;
    description = "Nix remote build user (laptop offloads builds here)";
    openssh.authorizedKeys.keys = [
      # root@laptop build key (private half lives at /root/.ssh/nixremote on laptop).
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKeyDoNotUse0000000000000000 user@example.com"
    ];
  };

  # Let the build user register store paths it produces for remote builds.
  nix.settings.trusted-users = [ "nixremote" ];
}
