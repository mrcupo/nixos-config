{ ... }:

# Offload heavy builds to the desktop (desktop) over the tailnet, so the laptop
# doesn't compile large Rust trees itself. desktop's side (sshd +
# the `nixremote` build user) lives in hosts/desktop/remote-build.nix.
#
# The build key is root-owned at /root/.ssh/nixremote and is generated
# out-of-band (not stored in the repo):
#   sudo ssh-keygen -t ed25519 -N "" -f /root/.ssh/nixremote -C root@laptop
{
  nix.distributedBuilds = true;

  # Let the builder fetch dependencies from binary caches itself, instead of
  # laptop shipping every input over SSH.
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = [
    {
      hostName = "desktop.example.internal";
      sshUser = "nixremote";
      sshKey = "/root/.ssh/nixremote";
      systems = [ "x86_64-linux" ];
      protocol = "ssh-ng";
      # desktop is the fast desktop; raise these if it has spare cores.
      maxJobs = 8;
      speedFactor = 2;
      supportedFeatures = [ "big-parallel" "benchmark" "kvm" "nixos-test" ];
    }
  ];

  # The nix-daemon connects to the builder as root; pin connection details so
  # the first handshake succeeds non-interactively.
  programs.ssh.extraConfig = ''
    Host desktop.example.internal
      User nixremote
      IdentityFile /root/.ssh/nixremote
      StrictHostKeyChecking accept-new
  '';
}
