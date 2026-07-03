{ pkgs, ... }:

# Desktop-specific Home Manager config.
{
  # Desktop-only user packages.
  home.packages = with pkgs; [
    app2unit
    reddit-tui

    easyeffects
    pulseaudio  # provides pactl; Steam calls it even when PipeWire is the Pulse server
    chatterino7
    vesktop
    nvtopPackages.nvidia
  ];

  # GTK dark color scheme (desktop only — the shared gtk block has no colorScheme).
  gtk.colorScheme = "dark";

  # Steam audio crash workaround — PipeWire's PulseAudio server comes up in a
  # bad state at boot, which makes Steam's bundled libpulse client segfault on
  # launch. Restarting the audio stack once after login produces a clean
  # server. See ~/steam-crash-runbook.html.
  systemd.user.services.steam-audio-fix = {
    Unit = {
      Description = "Restart PipeWire stack after login (Steam crash workaround)";
      After = [ "pipewire.service" "pipewire-pulse.service" "wireplumber.service" ];
    };
    Service = {
      Type = "oneshot";
      # Stay "active (exited)" after the one run so Home Manager's sd-switch
      # doesn't re-trigger this (and thus restart audio) on every nswitch.
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user restart wireplumber pipewire pipewire-pulse";
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Steam's FHS/bwrap wrapper tries to enter the caller's current directory.
  # If Steam is launched from /etc/nixos (or another path not mounted in the
  # Steam sandbox), it exits immediately with:
  #   bwrap: Can't chdir to /etc/nixos: No such file or directory
  # Launch from $HOME and explicitly open the Library for no-arg app launches.
  home.file.".local/bin/steam-safe" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      cd "$HOME"
      if [ "$#" -eq 0 ]; then
        exec steam steam://open/games
      fi
      exec steam "$@"
    '';
  };

  # Steam normally treats window close as "hide to tray". Under niri we don't
  # have Steam's expected tray restore path, so keep Mod+Q semantics by making
  # it fully quit Steam while preserving normal close-window behavior elsewhere.
  home.file.".local/bin/niri-close-window-smart" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      focused_app="$(niri msg focused-window 2>/dev/null | ${pkgs.gawk}/bin/awk -F'"' '/App ID:/ { print $2; exit }')"
      if [ "$focused_app" = "steam" ]; then
        cd "$HOME"
        exec steam -shutdown
      fi

      exec niri msg action close-window
    '';
  };

  home.file.".local/share/applications/steam.desktop".text = ''
    [Desktop Entry]
    Name=Steam
    Comment=Application for managing and playing games on Steam
    Exec=/home/user/.local/bin/steam-safe %U
    Icon=steam
    Terminal=false
    Type=Application
    Categories=Network;FileTransfer;Game;
    MimeType=x-scheme-handler/steam;x-scheme-handler/steamlink;
    PrefersNonDefaultGPU=true
    X-KDE-RunOnDiscreteGpu=true
  '';

  home.file.".local/bin/noctalia-restart" = {
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      # noctalia-shell is a Quickshell config; the actual process name is
      # .quickshell-wra, so `pkill -x noctalia-shell` doesn't stop it.
      pkill -u "$USER" -x .quickshell-wra 2>/dev/null || true
      sleep 0.5
      rm -rf "$XDG_RUNTIME_DIR/quickshell"
      setsid -f noctalia-shell >/dev/null 2>&1
    '';
  };

  # Zsh interactive init.
  programs.zsh.initContent = ''
    export PATH="$HOME/.npm-global/bin:$PATH"

    bindkey -e
    bindkey '^ ' autosuggest-accept
  '';

  # Shell aliases
  home.shellAliases = {
    nswitch = "cd /etc/nixos && nh os switch && ~/.local/bin/noctalia-restart";
    nstage-switch = "cd /etc/nixos && git add . && nh os switch && ~/.local/bin/noctalia-restart";
    nupdate = "nix flake update --flake /etc/nixos && nh os switch";
    nupdate-pkgs = "nix flake update nixpkgs --flake /etc/nixos && nh os switch";
    nupdate-shell = "nix flake update noctalia --flake /etc/nixos && nh os switch && ~/.local/bin/noctalia-restart";
    nrestart = "~/.local/bin/noctalia-restart";
  };
}
