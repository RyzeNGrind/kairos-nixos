{
  nixnas0 =
    { config, pkgs, lib, ... }:
    {
      deployment.targetEnv = "virtualbox"; # Use VirtualBox for the VM 
    };
}