{ ... }:

# Shared desktop NixOS modules — imported by the desktop profile only.
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
