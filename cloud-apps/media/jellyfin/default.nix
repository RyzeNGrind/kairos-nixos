{ config, pkgs, ... }:
{
  imports = [
    ./cloud-apps/media/default.nix
    # Add other cloud app integrations here
  ];
  options = {
    services.cloudApps.media.jellyfin.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable jellyfin cloud apps in media";
    };
  };
  
  config = mkIf config.services.cloudApps.media.jellyfin.enable {
    # Your configurations
  };
}
