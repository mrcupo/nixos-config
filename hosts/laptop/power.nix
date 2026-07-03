{ ... }:

{
  # Power management — required by Noctalia for battery / power-profile features.
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Suspend on lid close.
  services.logind.settings.Login.HandleLidSwitch = "suspend";
}
