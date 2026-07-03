{ ... }:

{
  # CapsLock held = Ctrl, tapped = Esc (caps2esc mode 1 equivalent).
  # Left Alt: held = "hyper" layer (L_Alt+C -> Ctrl+Shift+C, L_Alt+V -> Ctrl+Shift+V),
  # any other Alt+key (Alt+Tab, etc.) still works because [lalt:alt] inherits the alt layer.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        main = {
          capslock = "overload(control, esc)";
          leftalt = "overload(lalt, leftalt)";
        };
        "lalt:alt" = {
          c = "C-S-c";
          v = "C-S-v";
        };
      };
    };
  };
}
