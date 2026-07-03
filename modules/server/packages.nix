{ pkgs, ... }:

# Minimal operational toolset for the headless server. Push-deploys don't need
# these, but a provider rescue / VNC console (when push-deploy is unavailable)
# does — keep it small.
{
  environment.systemPackages = with pkgs; [
    git
    curl
    jq
    helix
  ];
}
