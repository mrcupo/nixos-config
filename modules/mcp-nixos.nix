{ inputs, pkgs, ... }:

# Shared agent tooling: expose mcp-nixos on every host so project-local MCP
# config can spawn the same server from /run/current-system/sw/bin.
{
  environment.systemPackages = [
    inputs.mcp-nixos.packages.${pkgs.stdenv.hostPlatform.system}.mcp-nixos
  ];
}
