# default.nix for debrid service
{ config, pkgs, lib, ... }:
{
  imports = [
    ./cloud-apps/media/default.nix
    # Add other cloud app integrations here
  ];
  options = {
    services.cloudApps.media.debrid.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable debrid cloud apps in media";
    };
  };
  
  config = lib.mkIf config.services.cloudApps.media.debrid.enable {
    # Your configurations
  };
}