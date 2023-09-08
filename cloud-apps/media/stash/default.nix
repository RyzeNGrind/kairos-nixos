{ config, pkgs, lib, ... }:
{
  imports = [
    ./cloud-apps/media/default.nix
    # Add other cloud app integrations here
  ];
  options = {
    services.cloudApps.media.stash.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable stash cloud apps in media";
    };
  };
  
  config = lib.mkIf config.services.cloudApps.media.stash.enable {
    # Your configurations
  };
}
