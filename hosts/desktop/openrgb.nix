{ pkgs, ... }:

# OpenRGB — used here only to *disable* RGB on motherboard / RAM / GPU.
# We don't run the OpenRGB server; a oneshot service shells out to the CLI
# at boot (and after resume) and sets every detected device to static black.
#
# The NZXT case controller is driven separately via liquidctl
# (nzxt-smart2 module in hosts/desktop/default.nix) — OpenRGB won't touch it.
let
  no-rgb = pkgs.writeShellScriptBin "no-rgb" ''
    NUM_DEVICES=$(${pkgs.openrgb}/bin/openrgb --noautoconnect --list-devices | grep -cE '^[0-9]+: ')

    for i in $(seq 0 $(($NUM_DEVICES - 1))); do
      ${pkgs.openrgb}/bin/openrgb --noautoconnect --device "$i" --mode static --color 000000
    done
  '';
in {
  config = {
    # udev rules for device access; i2c-dev exposes SMBus for mobo/RAM RGB
    services.udev.packages = [ pkgs.openrgb ];
    boot.kernelModules = [ "i2c-dev" "i2c-piix4" ];
    hardware.i2c.enable = true;

    # AMD 600-series chipsets hide the SMBus from i2c-piix4 unless ACPI is
    # told to release it — without this, RAM DIMMs aren't visible to OpenRGB
    # and stay lit at their last hardware-set color.
    boot.kernelParams = [ "acpi_enforce_resources=lax" ];

    # Keep the GUI/CLI around in case you want to inspect or tweak devices
    environment.systemPackages = [ pkgs.openrgb ];

    systemd.services.no-rgb = {
      description = "Turn off all RGB lighting via OpenRGB";
      serviceConfig = {
        ExecStart = "${no-rgb}/bin/no-rgb";
        Type = "oneshot";
      };
      # Run at boot and again after waking from suspend/hibernate
      wantedBy = [ "multi-user.target" "post-resume.target" ];
      after = [ "post-resume.target" ];
    };
  };
}
