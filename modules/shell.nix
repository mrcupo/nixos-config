{ ... }:

{
  # System-level zsh enablement only. Interactive zsh settings, keybindings
  # and aliases live in each host's Home Manager config.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };
}
