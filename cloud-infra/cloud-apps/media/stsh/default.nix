{ config, pkgs, ... }:
{
  imports = [
    ./cloud-apps/media/default.nix
    # Add other cloud app integrations here
  ];
  services.stash = {
    enable = true;
    # Your configurations
  };
}
