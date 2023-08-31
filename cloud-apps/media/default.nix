{ config, pkgs, ... }:
{
  imports = [
    ./cloud-apps/default.nix
    # Add other cloud app integrations here
  ];
  # Toggle for enabling/disabling media cloud apps
  options = {
    services.cloudApps.media.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable cloud apps in media";
    };
  };
  
  config = mkIf config.services.cloudApps.media.enable {
    # Your configurations
  };
