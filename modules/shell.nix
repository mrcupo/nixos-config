{ ... }:

{
  # System-level zsh enablement only. Interactive zsh settings, keybindings
  # and aliases live in Home Manager (modules/home.nix + hosts/<host>/home.nix)
  # so user shell behavior has a single source of truth.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };
}
