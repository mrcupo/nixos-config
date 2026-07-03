{ ... }:

{
  # Primary browser. Firefox stays installed as a fallback (modules/packages.nix).
  # Host-specific flags — e.g. the desktop's "--use-gl=egl" NVIDIA fix — are
  # appended in hosts/<host>/.
  programs.helium = {
    enable = true;
    flags = [
      "--ozone-platform-hint=auto"
    ];
  };
}
