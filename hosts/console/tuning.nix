{ pkgs, ... }:

# console tuning: AMD GPU undervolt/power control + CPU/GPU monitoring.
# The 5800X's own undervolt (Curve Optimizer / Eco Mode) is a BIOS setting
# (see the install runbook) — ryzenadj does not support desktop Vermeer chips.
{
  # Let amdgpu accept custom power/clock/voltage tables. Required for any GPU
  # undervolt or power-limit change to take effect.
  hardware.amdgpu.overdrive.enable = true;

  # LACT runs as a system daemon and re-applies the saved GPU profile at every
  # boot — ideal for a headless console. Set the curve once after first boot via
  # `lact` (GUI) or `lact cli` over Tailscale SSH; the daemon persists it in
  # /etc/lact/config.yaml and re-applies on subsequent boots.
  services.lact.enable = true;

  environment.systemPackages = with pkgs; [
    lact # AMD GPU undervolt/monitor UI + CLI
    zenmonitor # 5800X per-core temps / clocks / voltage readout
    lm_sensors # generic sensor readout for SSH/scripts
  ];
}
