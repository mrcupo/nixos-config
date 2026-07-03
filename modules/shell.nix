{ ... }:

{
  # System-level zsh enablement.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
  };
}
