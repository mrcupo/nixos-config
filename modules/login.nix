{ pkgs, ... }:

# Shared login/session: greetd + tuigreet launching niri-session, with
# gnome-keyring unlocked at login. Identical on both hosts, so it lives here
# rather than being duplicated per-host.
{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --greeting 'Welcome back!' --asterisks --cmd niri-session";
        user = "greeter";
      };
    };
  };
  security.pam.services.greetd.enableGnomeKeyring = true;
}
