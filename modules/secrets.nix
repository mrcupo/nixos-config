{ inputs, lib, ... }:

# Declarative secrets via agenix (plain — deliberately NOT agenix-rekey, which
# needs an impure nix-plugins extra-builtin). Each host decrypts with its own
# SSH host key; secrets are .age files encrypted to that host key plus user's
# user key (recovery). The repo-root secrets.nix is the recipient registry the
# `agenix -e` workflow reads; hosts/<host>/secrets/README.md documents the
# post-deploy bootstrap (a host can only become a recipient once its SSH host
# key exists).
#
# Imported by modules/profiles/server.nix (only server needs secrets today).
# Promote to the shared module set if a desktop host ever needs a secret.
{
  imports = [ inputs.agenix.nixosModules.default ];

  # Per-host convention: each host sets this to its own secrets folder. Defining
  # it here (rather than hardcoding paths) anchors the agenix usage so future
  # `age.secrets.<name>.file = config.node.secretsDir + "/<name>.age"` reads are
  # uniform across hosts.
  options.node.secretsDir = lib.mkOption {
    type = lib.types.path;
    description = "Path to this host's secrets directory (hosts/<host>/secrets).";
  };
}
