{ config, pkgs, ... }:
{
  imports = [
    ./devices/default.nix
    # Add other cloud app integrations here
  ];
  # Your configurations
}
