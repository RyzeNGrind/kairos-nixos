{ config, pkgs, ... }:
{
  imports = [
    ./cloud-apps/default.nix
    # Add other cloud app integrations here
  ];
  # Toggle for enabling/disabling cloud apps
  options = {
    services.cloudApps.development.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable development cloud apps in media";
    };
  };
  
  config = mkIf config.services.cloudApps.development.enable {
    # Your configurations
  };
