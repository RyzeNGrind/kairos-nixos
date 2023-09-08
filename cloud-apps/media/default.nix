{ config, pkgs, lib, ... }:
{
  imports = [
    ./cloud-apps/default.nix
    ./cloud-infra/storage/default.nix  # Add this line to import the cloud storage module
    # Add other cloud app integrations here
  ];
  # Toggle for enabling/disabling media cloud apps
  options = {
    services.cloudApps.media.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable cloud apps in media";
    };
  };
  
  config = lib.mkIf config.services.cloudApps.media.enable {
    # Your configurations
  };
