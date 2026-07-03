{ pkgs, ... }:

# Laptop-specific Home Manager config.
{
  # The laptop's packages used to live in environment.systemPackages, whose
  # NixOS profile installs the `doc`/`info` outputs by default. Home Manager's
  # per-user profile does not — so install them explicitly here to keep the
  # post-merge laptop closure identical to the pre-merge one.
  home.extraOutputsToInstall = [ "doc" "info" ];

  # Laptop-only user packages.
  home.packages = with pkgs; [
    nps
    unrar
    glow
    circumflex
    bottom
    tldr
    caligula

    chatterino2
    imv
    brightnessctl
    equibop
    blueman
    zapzap
    localsend
  ];

  # Laptop-only yazi openers (merged into the shared programs.yazi block).
  programs.yazi.settings = {
    opener = {
      pdf = [
        { run = ''zathura "$@"''; orphan = true; desc = "Zathura"; }
      ];
      image = [
        { run = ''imv "$@"''; orphan = true; desc = "imv"; }
      ];
    };
    open = {
      prepend_rules = [
        { mime = "application/pdf"; use = "pdf"; }
        { mime = "image/*"; use = "image"; }
      ];
    };
  };

  # Zsh interactive init. The `bindkey -e` / `bindkey '^ '` lines were
  # previously set system-wide via modules/shell.nix interactiveShellInit;
  # they are moved here so the laptop's Ctrl+Space autosuggest-accept is
  # preserved after the shell.nix reconcile.
  programs.zsh.initContent = ''
    export PATH="$HOME/.npm-global/bin:$PATH"

    bindkey -e
    bindkey '^ ' autosuggest-accept

    nsave() {
      if [ -z "$1" ]; then
        echo "usage: nsave <commit message>" >&2
        return 1
      fi
      (cd /etc/nixos && git add . && nh os switch && git commit -m "$*" && git push)
    }

    # Update flake inputs and switch. Noctalia v5 is intentionally pinned in
    # flake.nix for laptop, so normal nupdate runs do not chase every upstream
    # beta commit or trigger a local Noctalia rebuild. Bump the noctalia input
    # in flake.nix intentionally when you want to test a newer Noctalia.
    nupdate() {
      nix flake update --flake /etc/nixos || return 1
      nh os switch
    }

    # Tab: accept autosuggestion if present, otherwise normal completion
    _tab_accept_or_complete() {
      if [[ -n $POSTDISPLAY ]]; then
        zle autosuggest-accept
      else
        zle expand-or-complete
      fi
    }
    zle -N _tab_accept_or_complete
    bindkey '^I' _tab_accept_or_complete
  '';

  # Shell aliases
  home.shellAliases = {
    nswitch = "cd /etc/nixos && nh os switch";
    nstage-switch = "cd /etc/nixos && git add . && nh os switch";
    nrestart = "pkill -x noctalia; while pgrep -x noctalia >/dev/null; do sleep 0.1; done; setsid noctalia >/dev/null 2>&1 < /dev/null &";
  };
}
