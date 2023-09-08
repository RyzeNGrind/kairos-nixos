{ config, pkgs, lib, ... }:
{
  imports = [
    ./cloud-infra/default.nix
    # Add other cloud app integrations here
  ];
    # Toggle for enabling/disabling cloud apps
  options = {
    services.cloudApps.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable cloud-apps";
    };
  };
  
  config = lib.mkIf config.services.cloudApps.enable {
    # Your configurations
  };
}
