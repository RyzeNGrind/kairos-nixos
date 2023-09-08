{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./devices/default.nix
    # Add other cloud app integrations here
  ];
    # Toggle for enabling/disabling cloud infra
  options = {
    services.cloudInfra.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable cloud-infra";
    };
  };
  
  config = mkIf config.services.cloudInfra.enable {
    # Your configurations
  };
}
