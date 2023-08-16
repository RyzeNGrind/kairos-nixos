{
  # Define system and packages
  system ? builtins.currentSystem,
  pkgs ? import nixpkgs { inherit system; },
  lib ? pkgs.lib,
  std ? pkgs.stdenv.lib,
  # Import divnix standard library from GitHub
  divnix ? import (pkgs.fetchFromGitHub {
    owner = "divnix";
    repo = "std";
    rev = "master";
    sha256 = "sha256:1k2i2z3s6v8wbi3wv6f33504xlaqgfci5n3w2f32zk0w2n2j2hlg";
  })
}:

let
  # Inherit limnix and nixosTests from divnix and pkgs respectively
  inherit (divnix) limnix;
  inherit (pkgs) nixosTests;
in
{
  # Define the test
  test = limnix.recurseIntoAttrs (limnix.hydraJobs (limnix.collect (n: n.lib.isNixosTest) {
    # Define the test name and nodes
    cloudStorageTest = nixosTests.makeTest {
      name = "cloud-storage-test";
      nodes = {
        machine = { pkgs, ... }: {
          environment.systemPackages = with pkgs; [ jq ];
          services.initCloudStorage = {
            enable = true;
            mountPoint = "/mnt/gdrive";
            secretsFile = ./secrets.nix;
          };
        };
      };
      testScript = ''
        startAll; # Start all nodes
        # Test logic
        machine.wait_for_unit("multi-user.target")
        machine.wait_until_succeeds("pgrep -f 'agetty.*tty1'")
        machine.screenshot("postboot")

        with subtest("cloud storage is mounted"):
            machine.succeed("mount | grep gdrive")
            machine.screenshot("assert_mount_exists")

        with subtest("cloud storage is accessible"):
            machine.succeed("ls /mnt/gdrive")
            machine.screenshot("assert_access")
      '';
    };
  }));
}
