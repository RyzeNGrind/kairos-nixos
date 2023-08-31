{ config, pkgs, ... }:
{
  imports = [
    ./cloud-infra/default.nix
    # Add other cloud app integrations here
  ];
  # Toggle for enabling/disabling cloud network
  options = {
    services.cloudInfra.network.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable networking in cloud-infra";
    };
  };
  
  config = mkIf config.services.cloudInfra.network.enable {
    # Your configurations
  };
