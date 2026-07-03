{ config, lib, pkgs, inputs, ... }:

# Noctalia greeter (laptop only). The upstream module auto-configures greetd, but
# only at mkDefault priority. The shared modules/login.nix sets the greetd command
# (tuigreet) at normal priority, which wins over that mkDefault — so we mkForce the
# greeter session here. desktop keeps tuigreet from the shared module untouched.
{
  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  programs.noctalia-greeter = {
    enable = true;
    greeter-args = "--session niri";
  };

  services.greetd.settings.default_session.command = lib.mkForce (
    "${config.programs.noctalia-greeter.package}/bin/noctalia-greeter-session -- --session niri"
  );
}
