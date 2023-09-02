# default.nix for debrid service
{ config, pkgs, ... }:
{
  imports = [
    ./cloud-apps/media/default.nix
    # Add other cloud app integrations here
  ];
  options = {
    services.cloudApps.media.debrid.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable debrid cloud apps in media";
    };
  };
  
  config = mkIf config.services.cloudApps.media.debrid.enable {
    # Your configurations
  };
}