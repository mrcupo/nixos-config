# treefmt-nix config: one formatter for the tree, wired to `nix fmt` and the dev
# shell via flake.nix. nixfmt (RFC 166 style) for all Nix files.
#
# NOTE: the existing tree is not yet nixfmt-formatted, so running `nix fmt` will
# produce one large reflow diff — do that in a dedicated commit. This is
# intentionally NOT wired into `nix flake check` so it never blocks a build.
{ ... }:
{
  projectRootFile = "flake.nix";
  programs.nixfmt.enable = true;
}
