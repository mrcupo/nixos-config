{ pkgs, inputs, ... }:

let
  appleFonts = inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-cjk-sans
      # Apple San Francisco (see the apple-fonts flake input). SF Pro for UI,
      # Nerd-patched SF Mono for the terminal so starship glyphs still render.
      appleFonts.sf-pro
      appleFonts.sf-mono-nerd
    ];
  };
}
