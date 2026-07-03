{ pkgs, ... }:

# Base user. Host-specific supplementary groups (e.g. the desktop's "input")
# are appended in hosts/<host>/.
{
  users.users.user = {
    isNormalUser = true;
    description = "Example User";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
  };
}
