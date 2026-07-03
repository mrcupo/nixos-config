{ ... }:

# Living-room gaming appliance profile: headless-admin basics plus audio and
# networking. Jovian owns the display-manager/session path for this profile, so
# do not import the shared desktop/login modules here.
{
  imports = [
    ../boot.nix
    ../networking.nix
    ../localization.nix
    ../users.nix
    ../audio.nix
    ../nix-settings.nix
    ../mcp-nixos.nix
    ../shell.nix
    ../server/ssh.nix
  ];
}
