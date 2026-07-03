# agenix recipient registry. `agenix -e <path>` reads THIS file (it must be named
# secrets.nix at the repo root) to know which keys each .age file is encrypted to.
#
# This is NOT a NixOS module and is not imported by the flake — it's tooling input
# for the agenix CLI only. Per-host `age.secrets.<name>` declarations live in the
# host modules (see hosts/server/), gated on the .age file actually existing.
#
# Bootstrap status: server is not deployed yet, so its SSH host key does not exist
# and it cannot be a recipient. Until then this registry is intentionally EMPTY
# (agenix accepts `{ }`). See hosts/server/secrets/README.md for the exact steps
# to enable the first secret after the host's first boot.
#
# To enable the first secret, uncomment the bindings + entry below:
#
#   let
#     # user's personal key — kept as a second recipient on every secret so a lost
#     # or rotated host key never orphans the data (recovery path). Mirrors
#     # globals.ssh.user; the two must stay in sync.
#     user = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKeyDoNotUse0000000000000000 user@example.com";
#     # server host pubkey — after first deploy: ssh server cat /etc/ssh/ssh_host_ed25519_key.pub
#     server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIExamplePublicKeyDoNotUse0000000000000000 user@example.com";
#   in
#   {
#     "hosts/server/secrets/server-agent-env.age".publicKeys = [ user server ];
#   }
{ }
