{ config, pkgs, claude-code, eilmeldung, tuxedo, oh-my-pi-bin, ... }:

# Shared Home Manager config for user user — the parts that are identical on
# both hosts. Host-specific Home Manager config (package lists, zsh init,
# shell aliases, host-only program tweaks) lives in hosts/<host>/home.nix.

let
  rosePineYazi = pkgs.fetchFromGitHub {
    owner = "rose-pine";
    repo = "yazi";
    rev = "c89d745573d4fcfe0550fe6646f9f9ab1c0e51db";
    sha256 = "sha256-9e3dXViWl1rK9BPrGAFfs9ZL/tsG6Njz6ksuU6AIrFY=";
  };
  rosePineMicro = pkgs.fetchFromGitHub {
    owner = "SLUCHABLUB";
    repo = "rose-pine-micro";
    rev = "2f339cedb6d1d0344007ed5fa35c27fed221cacd";
    sha256 = "sha256-9eWzHLu/64F5oCz/Us2qkLaPJs2r9fgR9wI3eHreqsM=";
  };
  ohMyPi = pkgs.stdenvNoCC.mkDerivation {
    pname = "oh-my-pi";
    version = "16.1.16";
    src = oh-my-pi-bin;
    nativeBuildInputs = [ pkgs.patchelf ];
    dontUnpack = true;
    installPhase = ''
      runHook preInstall
      install -Dm755 "$src" "$out/bin/omp"
      patchelf --set-interpreter ${pkgs.stdenv.cc.bintools.dynamicLinker} "$out/bin/omp"
      runHook postInstall
    '';
  };
in
{
  imports = [ ./home/warp-themes.nix ];

  home.stateVersion = "25.05";

  # We run nixpkgs `nixos-unstable` + home-manager `master`. After a NixOS
  # release branches, HM master bumps its release string ahead of unstable,
  # triggering a cosmetic version-mismatch warning. The pairing is the
  # supported one, so silence the (unreliable on unstable) check.
  home.enableNixpkgsReleaseCheck = false;

  # Shared user packages. Host-specific extras live in hosts/<host>/home.nix.
  home.packages = (with pkgs; [
    # Runtimes for ~/.npm-global CLIs and agent tooling
    nodejs
    python3
    # CLI tools
    micro
    bat
    ripgrep
    fd
    tree
    jq
    eza
    git
    gh
    ohMyPi
    wget
    curl
    playerctl
    fastfetch
    htop
    nyaa
    eilmeldung
    zoxide
    poppler
    ffmpeg
    p7zip
    fzf
    resvg
    imagemagick
    lutgen

    # Wayland / niri essentials
    wl-clipboard
    grim
    slurp
    xwayland-satellite
    libnotify
    pywalfox-native

    # Desktop apps
    nautilus
    pavucontrol
    warp-oss
    zathura
    obsidian
  ]) ++ [
    claude-code
    tuxedo
  ];

  xdg.configFile."eilmeldung/config.toml".text = ''
    feed_list_focused_width = "33%"
    article_list_focused_width = "85%"
    article_list_focused_height = "66%"
    article_content_focused_height = "80%"
  '';

  # Pre-register the Syncthing-managed notes directory as an Obsidian vault.
  # This only writes Obsidian's app config; it does not touch ~/notes or
  # Syncthing's folder marker/state.
  home.file.".config/obsidian/obsidian.json".text = builtins.toJSON {
    vaults.notes = {
      path = "${config.home.homeDirectory}/notes";
      ts = 1780420000000;
      open = true;
    };
  };

  # User-local npm prefix so `npm install -g` persists in $HOME
  home.sessionPath = [ "$HOME/.npm-global/bin" ];
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  # Dark theme
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };
  gtk = {
    enable = true;
    theme.name = "Adwaita-dark";
    gtk4.theme = config.gtk.theme;
  };
  qt = {
    enable = true;
    style.name = "adwaita-dark";
  };

  # Cursor
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };

  # Helix editor. Colors are owned by Noctalia's helix template, which renders
  # ~/.config/helix/themes/noctalia.toml on every theme change. Point Helix at
  # that mutable theme file instead of hardcoding a static colorscheme here.
  programs.helix = {
    enable = true;
    defaultEditor = true;
    settings = {
      theme = "noctalia";
      editor = {
        line-number = "relative";
        cursor-shape.insert = "bar";
      };
    };
  };

  # Starship prompt. settings is left empty on purpose: Noctalia's starship
  # template owns ~/.config/starship.toml — it sets `palette = "noctalia"` and
  # injects a marker-delimited [palettes.noctalia] block with the live theme
  # colors on every theme change, leaving the rest of the file untouched. With
  # settings = {}, HM installs starship and adds the zsh init hook but does NOT
  # generate (and thus read-only-lock) starship.toml, so the two don't fight.
  # Customize the prompt format/modules by editing ~/.config/starship.toml.
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = { };
  };

  # Atuin (searchable command history)
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "compact";
      inline_height = 10;
    };
  };

  # Fastfetch config shared by both hosts.
  programs.fastfetch = {
    enable = true;
    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      # Built-in Nix snowflake logo on the left.
      logo = {
        source = "nixos";
        padding = { top = 1; right = 3; };
      };
      display = {
        separator = "   ";
        key = { width = 7; }; # aligns values to a fixed column past "disk"
        size = { ndigits = 0; binaryPrefix = "jedec"; }; # whole numbers, GB label
      };
      # Short lowercase keys, per-key theme colors, no box/title — and a
      # Pac-Man + ghosts color row (Nerd Font glyphs) in place of the usual
      # color blocks. Glyphs: U+F0BAA (pac-man), U+F02A0 (ghost).
      modules = [
        # format strings strip versions/freq/arch/brackets to keep values clean.
        { type = "os";       key = "os";   keyColor = "yellow"; format = "{2}"; }
        { type = "kernel";   key = "ker";  keyColor = "green"; }
        { type = "shell";    key = "sh";   keyColor = "blue";   format = "{1}"; }
        { type = "wm";       key = "wm";   keyColor = "red";    format = "{1}"; }
        { type = "uptime";   key = "up";   keyColor = "green"; }
        # CPU via /proc/cpuinfo so we can strip Intel's "(R)/(TM)/Nth Gen/Core"
        # and AMD's "N-Core Processor" cruft that fastfetch's format can't remove.
        {
          type = "command";
          key = "cpu";
          keyColor = "red";
          text = "grep -m1 'model name' /proc/cpuinfo | sed -E 's/^model name[[:space:]]*: //; s/\\(R\\)//g; s/\\(TM\\)//g; s/ @ [0-9.]+ ?GHz//; s/[0-9]+-Core Processor//; s/[0-9]+th Gen //; s/ Core / /; s/ +/ /g; s/ +$//'";
        }
        { type = "gpu";      key = "gpu";  keyColor = "cyan";   format = "{1} {2}"; }
        { type = "memory";   key = "ram";  keyColor = "yellow"; format = "{1} / {2}"; }
        { type = "disk";     key = "disk"; keyColor = "green"; folders = "/"; format = "{1} / {2}"; }
        "break"
        {
          type = "custom";
          format = "  {#yellow}󰮪  {#green}󰊠  {#blue}󰊠  {#red}󰊠  {#magenta}󰊠  {#cyan}󰊠  {#yellow}󰊠  {#white}󰊠{#}";
        }
      ];
    };
  };

  # Yazi file manager. Host-specific openers (the laptop's pdf/image rules)
  # are merged in from hosts/laptop/home.nix.
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "yy";
    settings = {
      manager = {
        show_hidden = false;
        sort_by = "natural";
        sort_dir_first = true;
      };
      preview = {
        tab_size = 2;
        max_width = 1000;
        max_height = 1000;
      };
    };
    keymap = {
      manager.prepend_keymap = [
        { on = "<C-h>"; run = "hidden"; desc = "Toggle hidden files"; }
      ];
    };
    flavors.rose-pine = "${rosePineYazi}/flavors/rose-pine.yazi";
  };

  xdg.configFile."yazi/theme.toml".text = ''
    [flavor]
    dark = "rose-pine"

  '' + builtins.readFile "${rosePineYazi}/themes/rose-pine.toml";

  # Micro editor — rose-pine colorscheme
  xdg.configFile."micro/colorschemes/rose-pine.micro".source =
    "${rosePineMicro}/dist/rose-pine.micro";
  xdg.configFile."micro/settings.json".text = builtins.toJSON {
    colorscheme = "rose-pine";
  };

  # Aliases shared by both hosts. Host-specific aliases merge in from
  # hosts/<host>/home.nix.
  home.shellAliases = {
    "ls" = "eza";
    "ll" = "eza -l";
    "la" = "eza -la";
    "lt" = "eza --tree";
    "cat" = "bat";
    grep = "rg";
    rss = "eilmeldung";
    todo = "tuxedo ~/notes/todo.txt";
    nconfig = "cd /etc/nixos && micro hosts/$(hostname)/default.nix";
    nflake = "cd /etc/nixos && micro flake.nix";
    ngit = "cd /etc/nixos && git status";
    ndiff = "cd /etc/nixos && git diff";
    nclaude = "cd /etc/nixos && claude";
    npull = "cd /etc/nixos && git pull --rebase";
    npush = "cd /etc/nixos && git push";
    ncommit = "cd /etc/nixos && git add . && git commit -m";
    nstorage = "sudo nix run nixpkgs#dysk";
  };

  # Zsh — shared options. Interactive init (programs.zsh.initContent) is set
  # per-host in hosts/<host>/home.nix.
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    autocd = true;
    historySubstringSearch.enable = true;
  };
}
