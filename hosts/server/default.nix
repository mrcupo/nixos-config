{ inputs, ... }:

# Example Agent VPS. Uses the "server" profile (see flake.nix mkHost), NOT the
# desktop shared module set. Disk layout is declarative via disko, so there is
# no generated hardware-configuration.nix to maintain by hand.
#
# Phase 1 (current): bare server that evaluates/builds locally. The Server
# flake input + services.server-agent module are added in Phase 4 via
# mkHost's extraModules.
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
  ];

  # Secrets (agenix). node.secretsDir is the per-host convention from
  # modules/secrets.nix; actual .age files are created post-deploy once this
  # host's SSH host key exists (see ./secrets/README.md), so no age.secrets are
  # declared yet — the scaffolding evaluates green with zero secrets.
  node.secretsDir = ./secrets;

  # Fresh host installed mid-2026 under the 26.11 nixpkgs — no older stateful
  # defaults to preserve, so pin to the actual install-era release (unlike
  # laptop/desktop, which stay at their original 25.11).
  system.stateVersion = "26.11";

  # UEFI systemd-boot. canTouchEfiVariables = false because many cloud firmwares
  # can't (or shouldn't) have NVRAM written; the ESP is still installed at /boot.
  # If the provider is BIOS-only, switch disko.nix to a bios_grub layout and use
  # boot.loader.grub here instead.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 7;
  boot.loader.efi.canTouchEfiVariables = false;

  # Serial + VGA console so the provider's rescue / VNC console is usable.
  boot.kernelParams = [ "console=tty1" "console=ttyS0,115200" ];
}
