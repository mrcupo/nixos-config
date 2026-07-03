{ pkgs, ... }:

{
  # ============================================================
  # Steam
  # ============================================================
  programs.steam = {
    enable = true;
    # Opens firewall ports for Steam Remote Play and local network game transfers
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    localNetworkGameTransfers.openFirewall = true;

    # Extra packages available inside the Steam FHS environment
    extraPackages = with pkgs; [
      # Proton dependencies that some games need
      mangohud       # optional: remove if you don't want the overlay
      gamemode       # optional: remove if you don't want gamemode
    ];

    # Both available — pick per-game in Steam (Properties → Compatibility)
    #   Proton-GE: more game-specific patches, broader compatibility
    #   Proton-CachyOS: x86-64-v4 optimized build (Zen 5 / AVX-512), higher FPS on titles that already work
    extraCompatPackages = with pkgs; [ proton-ge-bin proton-cachyos ];
  };

  # Gamescope — Valve's micro-compositor for nested per-game sessions.
  # Needed on PATH for `gamescope -W … %command%` launch options.
  programs.gamescope = {
    enable = true;
    capSysNice = false;
  };
  programs.steam.gamescopeSession.enable = true;

  # Gamemode — lets Steam games request performance governor automatically
  # Games with Proton can use it via `gamemoderun %command%` in launch options
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
    };
  };

  # ============================================================
  # Sunshine — game streaming server (Moonlight client)
  # ============================================================
  services.sunshine = {
    enable = true;
    autoStart = true;
    # capSysAdmin = true wraps Sunshine with file capabilities, which makes
    # glibc treat it as a secure binary and ignore LD_LIBRARY_PATH — that
    # prevents NVENC's libcuda/libnvidia-encode from loading out of
    # /run/opengl-driver/lib, forcing a fallback to software x264 encoding.
    # Niri exposes capture via zwlr_screencopy_manager_v1 (not KMS), so the
    # cap isn't actually used here.
    capSysAdmin = false;
    # Opens firewall ports: 47984/47989/48010 TCP, 47998-48000/48002 UDP
    openFirewall = true;
  };

  # Sunshine first-time setup:
  # 1. Open https://localhost:47990 in Firefox
  # 2. Create admin username/password
  # 3. On your Moonlight client, connect to this machine's IP
  # 4. Enter the PIN shown on the Moonlight client into the Sunshine web UI
  # 5. Add apps: "Steam Big Picture" with command: steam -bigpicture

  # ============================================================
  # Supporting packages
  # ============================================================
  environment.systemPackages = with pkgs; [
    deadlock-mod-manager  # Mod manager for the Valve game Deadlock
  ];

  # ============================================================
  # HDR Gaming Workflow
  # ============================================================
  # Current desktop login is greetd -> niri. For HDR experiments, use gamescope
  # as a nested HDR compositor from inside niri:
  #   gamescope -W 2560 -H 1440 -r 240 -f --hdr-enabled -- steam -bigpicture
  # Per-game Steam launch option example:
  #   gamescope -W 2560 -H 1440 -r 240 --hdr-enabled -- %command%
  # Native compositor HDR would require adding a compositor/session with HDR
  # support; that is intentionally not configured right now.
}
