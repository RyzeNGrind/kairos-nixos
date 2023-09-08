{ config, pkgs, lib, ... }:
{
  imports = [
    ./cloud-infra/default.nix
    # Add other cloud app integrations here
  ];
  # Toggle for enabling/disabling cloud network
  options = {
    services.cloudInfra.network.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable or disable networking in cloud-infra";
    };
  };
  
  config = lib.mkIf config.services.cloudInfra.network.enable {
    # Your configurations
  };
