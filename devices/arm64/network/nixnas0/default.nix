{ config, pkgs, lib, ... }:

{
  # Configuring the system
  # Setting the hostname to "nixnas0"
  # Disabling IPv6
  networking = {
    hostName = "nixnas0";
    network.enableIPv6 = false;
  };

  # Enabling the necessary services
  # nixos service is required for the NixOS operating system
  # netboot service is required for network booting
  services = {
    nixos.enable = true;
    netboot.enable = true;
  };

  # The build inputs will use hardware modules which will consist of Raspberry Pi 4B+ 8GB
  # and Argon EON Pi Case scripts that need to be converted to Nix to provide an idiomatic default.nix flake.
  hardware = {
    raspberryPi = {
      enable = true;
      model = "4B";
      memorySize = "8GB";
    };
    argonEONPiCase = {
      enable = true;
      scripts = pkgs.fetchFromGitHub {
        owner = "JeffCurless";
        repo = "argoneon";
        rev = "master";
        sha256 = "<insert sha256 here>";
      };
    };
  };

  # A kairos-nixos-wildland compatible raid configuration will be required to set up storage on this nixnas0 and manage 4 x WD Pro NAS 20TB HDDs.
  fileSystems."/mnt/raid" = {
    device = "/dev/md0";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "journal_data_writeback" "barrier=0" "data=writeback" ];
  };
  boot.initrd.mdadmConf = ''
    DEVICE /dev/sd*[a-z]
    ARRAY /dev/md0 level=raid5 num-devices=4 UUID=3b2e6c4a-ada7-4d3d-8f7b-238be0d42027
  '';
  boot.initrd.luks.devices = [
    {
      name = "raid";
      device = "/dev/md0";
      preLVM = true;
      allowDiscards = true;
    }
  ];

  # This flake should Allow toggling of cloud-infra/storage/default.nix flake to initCloudStorage and enable cloudStorage on this device.
  services.cloudStorage = {
    enable = true;
    initCloudStorage = true;
  };
}