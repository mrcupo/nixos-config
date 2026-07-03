{ ... }:

# Server profile: only headless-safe shared modules + the server module set.
#
# Deliberately EXCLUDES the desktop shared set (boot, desktop, login, audio,
# fonts, keyboard, packages, syncthing, helium, spicetify, nas) and the shared
# networking.nix / users.nix — those assume NetworkManager and desktop groups
# (audio/video/networkmanager) that don't exist on a headless box. The host
# (hosts/<host>/) owns its bootloader + disk layout (via disko).
{
  imports = [
    ../localization.nix
    ../nix-settings.nix
    ../mcp-nixos.nix
    ../secrets.nix
    ../shell.nix
    ../server/users.nix
    ../server/packages.nix
    ../server/networking.nix
    ../server/ssh.nix
    ../server/hardening.nix
  ];
}
