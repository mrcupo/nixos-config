{ pkgs, ... }:

{
  # Allow Sunshine to access uinput for gamepad/input emulation.
  services.udev.extraRules = ''
    KERNEL=="uinput", MODE="0660", GROUP="input", SYMLINK+="uinput"
  '';

  # ddcutil: lets Sunshine prep commands put the physical monitor to sleep
  # via DDC/CI without telling the compositor — keeps KMS scanout alive so
  # Sunshine's capture doesn't drop when streaming to Moonlight.
  environment.systemPackages = [ pkgs.ddcutil ];
  hardware.i2c.enable = true;
  users.users.user.extraGroups = [ "i2c" ];

  # Sunshine's systemd user unit doesn't inherit a graphics LD_LIBRARY_PATH,
  # so it can't find libnvidia-encode.so.1 and falls back to software x264 —
  # which can't keep up with 1440p and causes Moonlight clients to drop.
  systemd.user.services.sunshine.environment.LD_LIBRARY_PATH =
    "/run/opengl-driver/lib";
}
