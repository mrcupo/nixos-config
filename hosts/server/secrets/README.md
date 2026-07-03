# server secrets (agenix)

`.age` secret files for server live in this folder. They are encrypted to
server's **SSH host key** plus user's key (recovery), per the recipient
registry in the repo-root `secrets.nix`.

## Why there are no secrets here yet

agenix can only encrypt to a host once that host's SSH host key exists. server
is installed fresh via **nixos-anywhere**, which generates the host key at
install time — so the encryption can only happen **after server' first boot**.
This is the bootstrap-order gotcha; do not try to create `.age` files before the
host exists.

## Enabling the first secret (post-deploy)

1. Deploy server (nixos-anywhere with `hosts/server/disko.nix`; the agenix
   scaffolding builds green with zero secrets, so this is safe).
2. Grab the host key:
   ```sh
   ssh server cat /etc/ssh/ssh_host_ed25519_key.pub
   ```
3. In the repo-root `secrets.nix`, uncomment the `let`/registry block, paste the
   key into `server = "...";`, and uncomment the
   `"hosts/server/secrets/server-agent-env.age"` entry.
4. Create/edit the secret (writes the encrypted file into this folder):
   ```sh
   EDITOR=nvim agenix -e hosts/server/secrets/server-agent-env.age
   ```
5. Declare it in `hosts/server/default.nix`:
   ```nix
   age.secrets.server-agent-env.file = ./secrets/server-agent-env.age;
   ```
   then consume `config.age.secrets.server-agent-env.path` from the
   server-agent service unit (Phase 3).

## Recovery

Every secret keeps user's key as a second recipient, so a lost/rotated
server host key never orphans the data — re-encrypt to the new host key with
`agenix -r` (rekey) after updating `secrets.nix`.
