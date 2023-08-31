{ config, pkgs, ... }:
{
  imports = [
    ./cloud-infra/default.nix
    # Add other cloud app integrations here
  ];
    # Toggle for enabling/disabling cloud apps
  options = {
    services.cloudApps.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable cloud-apps";
    };
  };
  
  config = mkIf config.services.cloudApps.enable {
    # Your configurations
  };
}
