{ config, pkgs, lib, ... }:
{
  imports = [
    ./cloud-apps/default.nix
    # Add other cloud app integrations here
  ];
  # Toggle for enabling/disabling cloud apps
  options = {
    services.cloudApps.development.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable development cloud apps in media";
    };
  };
  
  config = lib.mkIf config.services.cloudApps.development.enable {
    # Your configurations
  };
