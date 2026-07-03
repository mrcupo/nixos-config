{ ... }:

# Shared desktop NixOS modules — imported by the desktop profile only.
# Note: home.nix is intentionally NOT listed here — it is a Home Manager
# module, wired in separately via home-manager.users.user in flake.nix.
{
  imports = [
    ./boot.nix
    ./networking.nix
    ./localization.nix
    ./users.nix
    ./keyboard.nix
    ./desktop.nix
    ./login.nix
    ./audio.nix
    ./fonts.nix
    ./nix-settings.nix
    ./mcp-nixos.nix
    ./shell.nix
    ./packages.nix
    ./syncthing.nix
    ./helium.nix
    ./spicetify.nix
    ./nas.nix
  ];
}
