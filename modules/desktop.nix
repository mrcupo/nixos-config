{ pkgs, ... }:

# Shared graphical base: niri compositor + Wayland plumbing common to both
# hosts. The greetd/tuigreet login lives in modules/login.nix; gaming-specific
# compositor tools live in hosts/<host>/.
{
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Wayland sessions do not provide a PolicyKit authentication agent by
  # default. Noctalia Greeter's appearance sync uses pkexec, so keep an agent
  # running in the graphical user session.
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "PolicyKit GNOME authentication agent";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
    };
  };
  # File-manager plumbing for Nautilus: trash, network shares, MTP mounts, etc.
  services.gvfs.enable = true;
  hardware.bluetooth.enable = true;

  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;

  environment.variables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
  };
}
