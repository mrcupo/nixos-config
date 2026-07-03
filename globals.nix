# Repo-wide identity facts, threaded into every host via mkHost's specialArgs
# (flake.nix). Deliberately tiny — this is NOT oddlama's typed network/VLAN
# registry, just a single home for facts that would otherwise be copy-pasted
# (SSH keys, hostnames, the server domain). Keep it small; if it ever grows a
# VLAN/wireguard topology we've taken a wrong turn.
{
  ssh = {
    # user's personal key (laptop/desktop ~/.ssh/id_ed25519). Consumed by
    # modules/server/ssh.nix and the agenix recipient registry (secrets.nix).
    user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKeyDoNotUse0000000000000000 user@example.com";
  };

  # Per-host facts. tailnet is the MagicDNS short name on the tailnet.
  hosts = {
    laptop.tailnet = "laptop";
    desktop.tailnet = "desktop";
    console.tailnet = "console";
    server.tailnet = "server";
  };
}
