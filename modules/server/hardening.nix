{ ... }:

# Minimal server hardening + housekeeping. Extend cautiously per the gameplan;
# the Server service unit gets its own systemd hardening separately.
{
  # Keep wheel sudo passworded. If push-deploys need non-interactive sudo later,
  # add a narrow deploy user/rule instead of making every wheel user passwordless.
  security.sudo.wheelNeedsPassword = true;

  # Bound journal disk usage on a small VPS.
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    SystemMaxFileSize=50M
  '';

  # Automatic GC + store optimisation keep the VPS disk from filling.
  # (auto-optimise-store is set in the shared nix-settings.nix.)
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  boot.tmp.cleanOnBoot = true;
}
