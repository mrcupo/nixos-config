{ pkgs, inputs, ... }:

# System-wide programs and the few true system/admin packages. User-facing
# packages live in Home Manager (hosts/<host>/home.nix).
{
  # Firefox is kept as a fallback/compatibility browser; Helium is primary
  # (see modules/helium.nix).
  programs.firefox.enable = true;

  # nh (nix helper)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 7";
    flake = "/etc/nixos";
  };

  environment.systemPackages = [
    pkgs.keyd      # CLI for the keyd service (keyd monitor / reload)
    inputs.kopuz.packages.${pkgs.stdenv.hostPlatform.system}.default  # Kopuz music player
  ];
}
