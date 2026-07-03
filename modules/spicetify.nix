{ pkgs, spicetify-nix, ... }:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ spicetify-nix.nixosModules.default ];

  # Declarative Spicetify: installs the wrapped Spotify package directly, with
  # no mutable ~/.local/share Spotify copy or Noctalia post-hook re-patching.
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };
}
