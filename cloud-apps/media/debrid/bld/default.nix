# default.nix flake for debrid
{ config, pkgs, stdenv, fetchFromGitHub, ... }:

{
  imports = [
    ./cloud-apps/media/default.nix
    ./cloud-apps/media/debrid/default.nix
  ];

  options = {
    services.cloudApps.media.debrid.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable or disable debrid cloud apps in media";
    };
  };

  config = mkIf config.services.cloudApps.media.debrid.enable {
    services.debrid = stdenv.mkDerivation rec {
      pname = "debrid";
      version = "0.1.0";

      src = fetchFromGitHub {
        owner = "manuGMG";
        repo = "debrid-scripts";
        rev = "master";
        
        sha256 = "7cfbac555ce450e0cd8a6bb6ad91d28a1ed60481"; 
      };

      buildInputs = [ pkgs.gcc ];  # Specify the build dependencies here

      buildPhase = ''
        gcc -o debrid debrid.c
      '';

      installPhase = ''
        install -D debrid $out/bin/debrid
      '';
    };
  };
}