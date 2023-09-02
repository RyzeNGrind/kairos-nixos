
{
  # Building a kairos enabled nix flake to initialize nixnas0 with NixOS configuration and netboot from either a debootif not already initiliazed.
  # Importing necessary modules and packages
  { config, pkgs, lib, ... }:

  {
  # Defining the system
  system = "aarch64-linux";

  # Importing the necessary modules
  # divnix/std is a standard library for Nix
  # liminix is used for routers
  imports = [
    (github:divnix/std)
    (liminix)
  ];

  # Defining the build inputs
  # git is used for version control
  # nixFlakes is used for managing Nix packages
  buildInputs = with pkgs; [
    git
    nixFlakes
  ];

  # Defining the build outputs
  # "out" is the default output
  buildOutputs = [ "out" ];

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

  # Defining the file systems
  # Setting the root file system to be on the device with label "nixos"
  # Using ext4 as the file system type
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };

  # Defining the boot loader
  # Using GRUB version 2
  # Setting the boot device to "/dev/sda"
  boot.loader = {
    grub.enable = true;
    grub.version = 2;
    grub.device = "/dev/sda";
  };
}

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
scripts = fetchFromGitHub {
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
