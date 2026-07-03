{ pkgs, ... }:

let
  gameUser = "gamer";
in
{
  jovian.steam = {
    enable = true;
    autoStart = true;
    user = gameUser;

    # No desktop environment on this appliance. Keep Steam's "Switch to Desktop"
    # action inside the gaming-mode session instead of exposing a workstation UI.
    desktopSession = "gamescope-wayland";
  };

  # Jovian's Steam Deck-like path is best-supported on AMD GPUs.
  jovian.hardware.has.amd.gpu = true;

  # Load amdgpu in initrd so HDMI comes up cleanly/flicker-free at boot — this
  # is a TV box, not a monitor with a desktop DM to paper over a late mode set.
  # (Jovian already defaults this true when `has.amd.gpu` is set; kept explicit.)
  jovian.hardware.amd.gpu.enableEarlyModesetting = true;

  # Steam Deck Plugin Loader. On a headless living-room box this is how you add
  # HDMI-CEC / audio / power plugins without SSHing in. Jovian runs the loader as
  # a root system service with UNPRIVILEGED_USER set to `user` below, so plugins
  # execute as the game user; the loader binary is packaged (pinned), not fetched
  # at runtime.
  jovian.decky-loader = {
    enable = true;
    user = gameUser;
  };

  # The profile enables the Tailscale daemon. Drop a reusable/preauthorized key
  # here during install so first boot joins the tailnet without a local desktop.
  services.tailscale.authKeyFile = "/var/lib/secrets/tailscale-auth-key";

  users.users.${gameUser} = {
    isNormalUser = true;
    description = "Living Room Gaming User";
    extraGroups = [
      "networkmanager"
      "video"
      "audio"
      "input"
      "gamemode"
    ];
  };

  # NOTE: inside Jovian's gamescope session the compositor already owns game
  # scheduling/priority, so GameMode's renice/governor logic is largely inert
  # here — LACT + the SteamOS sysctls do the real work. Kept enabled for the
  # occasional desktop-launched (Switch to Desktop) game; harmless otherwise.
  programs.gamemode = {
    enable = true;
    settings = {
      general.renice = 10;
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };

  programs.steam = {
    # Jovian enables Steam by default; keep the living-room LAN behavior explicit.
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  environment.systemPackages = with pkgs; [
    openrgb
    steam-rom-manager
  ];
}
