{ pkgs, ... }:

# Base server user. No desktop groups (audio/video/networkmanager) — those
# don't exist on the headless server profile. SSH keys are wired in ssh.nix.
{
  users.users.user = {
    isNormalUser = true;
    description = "Example User";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };
}
