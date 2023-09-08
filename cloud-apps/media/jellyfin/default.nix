{ config, pkgs, lib, ... }:
{
  imports = [
    ./cloud-apps/media/default.nix
    # Add other cloud app integrations here
  ];
  options = {
    services.cloudApps.media.jellyfin.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable jellyfin cloud apps in media";
    };
  };
  
  config = lib.mkIf config.services.cloudApps.media.jellyfin.enable {
    # Your configurations
  };
}
